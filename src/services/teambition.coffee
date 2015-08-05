_ = require 'lodash'
Promise = require 'bluebird'
request = require 'request'
moment = require 'moment-timezone'
marked = require 'marked'
crypto = require 'crypto'
requestAsync = Promise.promisify request

service = require '../service'

# Hack teambition host
if process.env.NODE_ENV in ['ga', 'prod']
  _tbHost = 'https://www.teambition.com'
else
  _tbHost = 'http://www.project.ci'

_supportEvents = [
  "project.rename", "project.archive", "project.unarchive", "project.member.create", "project.member.remove",
  "tasklist.create", "tasklist.remove", "tasklist.rename", "task.create", "task.update", "task.remove",
  "task.update.executor", "task.update.dueDate", "task.update.priority", "task.update.involveMembers", "task.rename",
  "task.move", "task.done", "subtask.create", "subtask.update.executor", "subtask.update.content", "subtask.done",
  "tag.create", "tag.remove", "post.create", "post.update", "post.update.involveMembers", "file.create",
  "file.remove", "file.move", "file.rename", "file.update.version", "file.update.involveMembers", "event.create", "event.remove",
  "event.update", "event.update.involveMembers", "stage.create", "stage.rename", "entry.create", "entry.update", "entry.update.involveMembers"
]

# Integration data schema
# data:
#   _projectId1:
#     hookId: xxx

###*
 * Validate the integration
 * @param  {Model} integration - Integration model
 * @return {Null}
###
_preValidate = (integration) ->
  unless integration.project?._id
    throw new Error('Missing project in teambition integration!')

  unless integration.token
    throw new Error('Missing token in teambition integration')

  unless integration.events
    throw new Error('Missing events in teambition integration')

  invalidEvents = integration.events.filter (event) -> event not in _supportEvents
  if invalidEvents.length
    throw new Error("Invalid events #{invalidEvents}")

_checkSign = (query = {}, clientSecret) ->
  {sign, timestamp, nonce} = query
  unless sign and timestamp and nonce
    err = new Error('Signature failed')
    err.status = 403
    throw err

  unless (Date.now() - Number(timestamp)) < 60000  # Less than 1 minute
    err = new Error('Expired')
    err.status = 403
    throw err

  values = [timestamp, nonce, clientSecret]

  unless sign is crypto.createHash('sha1').update(values.sort().join '').digest('hex')
    err = new Error('Signature failed')
    err.status = 403
    throw err

_receiveWebhook = ({integration, body, query, method}) ->
  _checkSign query, @clientSecret

  return ok: 1 if method is 'HEAD'

  {event, data} = body

  message = integration: integration
  attachment = category: 'quote', data: {}

  [scope] = event?.split('.')

  throw new Error("Invalid event of teambition integration") unless scope

  # Set the redirect url by specific scope name
  switch scope
    when 'subtask'
      attachment.data.redirectUrl = data.subtask.task?.url
    when 'file'
      if toString.call(data.file) is '[object Array]'
        attachment.data.redirectUrl = data.file[0].url
      else
        attachment.data.redirectUrl = data.file.url
    when 'stage'
      attachment.data.redirectUrl = data.stage.tasklist?.url
    else attachment.data.redirectUrl = data[scope]?.url

  attachment.data.redirectUrl or= data.project.url

  switch event
    when 'project.rename', 'project.archive', 'project.unarchive'
      actions =
        'project.rename': "重命名了"
        'project.archive': "归档了"
        'project.unarchive': "恢复了"
      attachment.data.title = "#{actions[event]}项目 #{data.project.name}"

    when 'project.member.create', 'project.member.remove'
      members = if toString.call(data.member) is '[object Array]' then data.member else [data.member]
      memberNames = members
        .map (m) -> m.name
        .join '，'
      actions =
        'project.member.create': "邀请了"
        'project.member.remove': "移除了"
      attachment.data.title = "#{actions[event]}成员 #{memberNames}"

    when 'tasklist.create', 'tasklist.remove', 'tasklist.rename'
      actions =
        "tasklist.create": "创建了"
        "tasklist.remove": "删除了"
        "tasklist.rename": "修改了"
      attachment.data.title = "#{actions[event]}任务列表 #{data.tasklist.title}"

    when 'task.create', 'task.remove', 'task.rename', 'task.done'
      actions =
        'task.create': "创建了"
        "task.remove": "删除了"
        'task.rename': "重命名了"
        'task.done': "完成了"
      attachment.data.title = "#{actions[event]}任务 #{data.task.content}"

    when 'task.update.executor'
      if data.task.executor?.name
        attachment.data.title = "将任务 #{data.task.content} 指派给 #{data.task.executor.name}"
      else
        attachment.data.title = "移除了任务 #{data.task.content} 的执行者"

    when 'task.update.priority'
      priorities =
        'normal': '普通'
        'high': '紧急'
        'urgent': '非常紧急'
      attachment.data.title = "更新了任务 #{data.task.content} 的优先级 #{priorities[data.task.priority]}"

    when 'task.update.dueDate'
      if data.task.dueDate
        attachment.data.title = "更新了任务 #{data.task.content} 的截止日期 #{moment(data.task.dueDate).tz('Asia/Shanghai').format('MM月DD日')}"
      else
        attachment.data.title = "删除了任务 #{data.task.content} 的截止日期"

    when 'task.move'
      attachment.data.title = "将任务 #{data.task.content} 移动到 #{data.task.tasklist.title}列表，#{data.task.stage.name}阶段"

    when 'task.update.involveMembers'
      ###*
       * @todo Accomplish task.update.involveMembers
      ###
      return false

    when 'subtask.create', 'subtask.update.content', 'subtask.done'
      actions =
        'subtask.create': '创建了'
        'subtask.update.content': '更新了'
        'subtask.done': '完成了'
      attachment.data.title = "#{actions[event]}子任务 #{data.subtask.content}"

    when 'subtask.update.executor'
      if data.subtask.executor?.name
        attachment.data.title = "将子任务 #{data.subtask.content} 指派给 #{data.subtask.executor.name}"
      else
        attachment.data.title = "移除了子任务 #{data.subtask.content} 的执行者"

    when 'tag.create', 'tag.remove'
      actions =
        'tag.create': '创建了'
        'tag.remove': "删除了"
      attachment.data.title = "#{actions[event]}标签 #{data.tag.name}"

    when 'post.create', 'post.update'
      actions =
        'post.create': '发布了'
        'post.update': '更新了'
      attachment.data.title = "#{actions[event]}分享 #{data.post.title}"
      if data.post.postMode is 'md'
        attachment.data.text = marked(data.post.content)
      else
        attachment.data.text = data.post.content

    when 'post.update.involveMembers'
      ###*
       * @todo Accomplish post.update.involveMembers
      ###
      return false

    when 'file.create', 'file.rename', 'file.remove', 'file.update.version'
      actions =
        'file.create': '上传了'
        'file.rename': '重命名了'
        'file.remove': '删除了'
        'file.update.version': '更新了'
      if toString.call(data.file) is '[object Array]'
        fileNames = data.file
          .map (file) -> file.fileName
          .join '，'
        attachment.data.imageUrl = data.file[0].thumbnail
      else
        fileNames = data.file.fileName
        attachment.data.imageUrl = data.file.thumbnail
      attachment.data.title = "#{actions[event]}文件 #{fileNames}"

    when 'file.move'
      attachment.data.title = "将文件 #{data.file.fileName} 移动到 #{data.file.collection.title}"

    when 'event.create', 'event.update'
      actions =
        'event.create': '创建了'
        'event.update': '更新了'
      attachment.data.title = [
        "#{actions[event]}日程 #{data.event.title} "
        "地点：#{data.event.location}，"
        "开始时间：#{moment(data.event.startDate).tz('Asia/Shanghai').format('MM月DD日HH:mm:ss')}，"
        "结束时间：#{moment(data.event.endDate).tz('Asia/Shanghai').format('MM月DD日HH:mm:ss')}"
      ].join ''
      attachment.data.text = marked(data.event.content)

    when 'event.remove'
      attachment.data.title = "删除了日程 #{data.event.title}"

    when 'stage.create', 'stage.rename'
      actions =
        'stage.create': '创建了'
        'stage.rename': '重命名了'
      attachment.data.title = "#{actions[event]}阶段 #{data.stage.name}"

    when 'entry.create', 'entry.update'
      actions =
        'entry.create': '创建了'
        'entry.update': '更新了'
      incoming = if data.entry.type is 1 then "收入" else "支出"
      attachment.data.title = "#{actions[event]}账单 #{data.entry.content}，#{incoming} #{data.entry.amount} 元"

    else return false

  # Add project name and executor prefix
  attachment.data.title = "[#{data.project.name}] #{data.user.name} #{attachment.data.title}"
  message.attachments = [attachment]

  @sendMessage message

###*
 * Create teambition project hook
 * @param  {String} _projectId - Teambition project id
 * @param  {String} token - Token
 * @param  {Array} events - Events
 * @param  {String} hashId - Hashed id of integration
 * @return {Promise} Response body
###
_createProjectHook = (_projectId, token, events, hashId) ->
  requestAsync
    method: 'POST'
    headers:
      "User-Agent": service.userAgent
      "Authorization": "OAuth2 #{token}"
    url: "#{_tbHost}/api/projects/#{_projectId}/hooks"
    json: true
    body:
      callbackURL: "#{service.apiHost}/services/webhook/#{hashId}"
      events: events

  .spread (res, body) ->
    unless res.statusCode >= 200 and res.statusCode < 300
      err = new Error("Bad request #{res.statusCode}")
    throw err if err
    body

_updateProjectHook = (_projectId, hookId, token, events, hashId) ->
  requestAsync
    method: 'PUT'
    headers:
      "User-Agent": service.userAgent
      "Authorization": "OAuth2 #{token}"
    url: "#{_tbHost}/api/projects/#{_projectId}/hooks/#{hookId}"
    json: true
    body:
      callbackURL: "#{service.apiHost}/services/webhook/#{hashId}"
      events: events

  .spread (res, body) ->
    unless res.statusCode >= 200 and res.statusCode < 300
      err = new Error("Bad request #{res.statusCode}")
    throw err if err
    body

_removeProjectHook = (_projectId, hookId, token) ->
  requestAsync
    method: 'DELETE'
    url: "#{_tbHost}/api/projects/#{_projectId}/hooks/#{hookId}"
    headers:
      "User-Agent": service.userAgent
      "Authorization": "OAuth2 #{token}"
    json: true

  .spread (res, body) ->
    unless res.statusCode >= 200 and res.statusCode < 300
      err = new Error("Bad request #{res.statusCode}")
    throw err if err
    body

_createWebhook = (integration) ->
  _preValidate integration

  _createProjectHook integration.project._id
  , integration.token
  , integration.events
  , integration.hashId

  .then (body) ->
    integration.data or= {}
    integration.data[integration.project._id] = hookId: body._id
    # Mark the mixed field as modified
    integration.markModified 'data'
    integration

_updateWebhook = (integration) ->
  return unless ['project._id', 'events'].some (field) -> integration.isDirectModified field

  _preValidate integration

  {_original} = integration
  if integration.isDirectModified 'project._id'
    _originalProjectId = _original.project._id

    $removeOldProjectHook = _removeProjectHook _originalProjectId
    , _original.data[_originalProjectId].hookId
    , integration.token

    .then (body) ->
      delete integration.data[_originalProjectId]
      integration

    $createNewProjectHook = _createProjectHook integration.project._id
    , integration.token
    , integration.events
    , integration.hashId

    .then (body) ->
      integration.data or= {}
      integration.data[integration.project._id] = hookId: body._id
      integration.markModified 'data'
      integration

    $integration = Promise.all [$removeOldProjectHook, $createNewProjectHook]
    .then -> integration

  else if integration.isDirectModified 'events'
    _projectId = integration.project._id

    $integration = _updateProjectHook _projectId
    , integration.data[_projectId].hookId
    , integration.token
    , integration.events
    , integration.hashId

    .then (body) -> integration

  $integration

_removeWebhook = (integration) ->
  _preValidate integration

  _projectId = integration.project._id

  return unless integration.data

  Promise.resolve(Object.keys(integration.data))
  .map (_projectId) ->
    _removeProjectHook integration.project._id
    , integration.data[_projectId].hookId
    , integration.token

###*
 * Get project list of user
 * @param  {Request} req
 * @param  {Response} res
 * @return {Promise} projects
###
_getProjects = (req, res) ->
  {token} = req.get()
  throw new Error('Missing token') unless token
  requestAsync
    method: 'GET'
    headers:
      "User-Agent": service.userAgent
      "Authorization": "OAuth2 #{token}"
    url: "#{_tbHost}/api/projects"
    json: true
  .spread (res, projects) ->
    unless res.statusCode >= 200 and res.statusCode < 300
      err = new Error("Bad request #{res.statusCode}")
    throw err if err
    projects.map (project) -> _.pick project, '_id', 'name'

_getEvents = ->
  [
    key: 'project.member.create'
    group: 'project'
    label: service.i18n
      zh: '添加项目成员'
      en: 'Invite members to project'
  ,
    key: 'project.member.remove'
    group: 'project'
    label: service.i18n
      zh: '移除项目成员'
      en: 'Remove project members'
  ,
    key: 'project.rename'
    group: 'project'
    label: service.i18n
      zh: '修改项目名称'
      en: 'Rename project'
  ,
    key: 'task.create'
    group: 'task'
    label: service.i18n
      zh: '创建任务'
      en: 'Create task'
  ,
    key: 'task.update.executor'
    group: 'task'
    label: service.i18n
      zh: '分配执行者'
      en: 'Update executor of task'
  ,
    key: 'task.update.dueDate'
    group: 'task'
    label: service.i18n
      zh: '设置截止日期'
      en: 'Update due date of task'
  ,
    key: 'task.update.priority'
    group: 'task'
    label: service.i18n
      zh: '设置优先级'
      en: 'Update priority of task'
  ,
    key: 'task.rename'
    group: 'task'
    label: service.i18n
      zh: '重命名任务'
      en: 'Update name of task'
  ,
    key: 'task.move'
    group: 'task'
    label: service.i18n
      zh: '移动任务'
      en: 'Update stage of task'
  ,
    key: 'task.done'
    group: 'task'
    label: service.i18n
      zh: '完成任务'
      en: 'Finish the task'
  ,
    key: 'tasklist.create'
    group: 'task'
    label: service.i18n
      zh: '创建任务分组'
      en: 'Create tasklist'
  ,
    key: 'tasklist.rename'
    group: 'task'
    label: service.i18n
      zh: '重命名任务分组'
      en: 'Rename tasklist'
  ,
    key: 'stage.create'
    group: 'task'
    label: service.i18n
      zh: '添加新阶段'
      en: 'Create stage'
  ,
    key: 'stage.rename'
    group: 'task'
    label: service.i18n
      zh: '重命名任务阶段'
      en: 'Rename stage'
  ,
    key: 'subtask.create'
    group: 'task'
    label: service.i18n
      zh: '添加子任务'
      en: 'Create subtask'
  ,
    key: 'subtask.update.executor'
    group: 'task'
    label: service.i18n
      zh: '子任务分配了执行者'
      en: 'Update executor of subtask'
  ,
    key: 'subtask.update.content'
    group: 'task'
    label: service.i18n
      zh: '编辑子任务'
      en: 'Update content of subtask'
  ,
    key: 'subtask.done'
    group: 'task'
    label: service.i18n
      zh: '完成子任务'
      en: 'Finish the subtask'
  ,
    key: 'post.create'
    group: 'post'
    label: service.i18n
      zh: '添加分享'
      en: 'Create a post'
  ,
    key: 'post.update'
    group: 'post'
    label: service.i18n
      zh: '修改分享'
      en: 'Update a post'
  ,
    key: 'file.create'
    group: 'file'
    label: service.i18n
      zh: '上传文件'
      en: 'Upload a file'
  ,
    key: 'file.update.version'
    group: 'file'
    label: service.i18n
      zh: '更新文件'
      en: 'Update version of file'
  ,
    key: 'file.move'
    group: 'file'
    label: service.i18n
      zh: '移动文件'
      en: 'Move file to another directory'
  ,
    key: 'event.create'
    group: 'event'
    label: service.i18n
      zh: '创建日程'
      en: 'Create event'
  ,
    key: 'event.update'
    group: 'event'
    label: service.i18n
      zh: '更新日程'
      en: 'Update content of event'
  ,
    key: 'entry.create'
    group: 'entry'
    label: service.i18n
      zh: '记录账目'
      en: 'Create a entry'
  ,
    key: 'entry.update'
    group: 'entry'
    label: service.i18n
      zh: '修改记录'
      en: 'Update a entry'
  ]

_getGroups = ->
  [
    key: 'project'
    label: service.i18n
      zh: '项目'
      en: 'Project'
  ,
    key: 'task'
    label: service.i18n
      zh: '任务板'
      en: 'Task'
  ,
    key: 'post'
    label: service.i18n
      zh: '分享墙'
      en: 'Post'
  ,
    key: 'file'
    label: service.i18n
      zh: '文件库'
      en: 'File'
  ,
    key: 'event'
    label: service.i18n
      zh: '日程表'
      en: 'Event'
  ,
    key: 'entry'
    label: service.i18n
      zh: '记账'
      en: 'Entry'
  ]

module.exports = service.register 'teambition', ->

  @title = 'Teambition'

  @summary = service.i18n
    zh: '配置 Teambition 聚合，实时接收来自 Teambition 的任务，日程，分享等消息'
    en: 'This integration helps you receive real-time tasks, schedules and posts from Teambition'

  @description = service.i18n
    zh: '配置 Teambition 聚合，实时接收来自 Teambition 的任务，日程，分享等消息'
    en: 'This integration helps you receive real-time tasks, schedules and posts from Teambition'

  @iconUrl = service.static 'images/icons/teambition@2x.png'

  @_fields.push
    key: 'project'
    onLoad: get: @getApiUrl 'getProjects'

  @_fields.push
    key: 'events'
    items: _getEvents.apply this
    groups: _getGroups.apply this

  @registerEvent 'service.webhook', _receiveWebhook

  @registerEvent 'before.integration.create', _createWebhook

  @registerEvent 'before.integration.update', _updateWebhook

  @registerEvent 'before.integration.remove', _removeWebhook

  @registerApi 'getProjects', _getProjects
