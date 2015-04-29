_ = require 'lodash'
Promise = require 'bluebird'
request = require 'request'
requestAsync = Promise.promisify request

service = require '../service'

# Hack teambition host
if process.env.NODE_ENV is 'test'
  _tbHost = 'http://www.project.ci'
else
  _tbHost = 'https://www.teambition.com'

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

_receiveWebhook = ({integration, body}) ->
  payload = body

  message =
    _integrationId: integration._id
    quote:
      title: ""
      text: ""
      redirectUrl: ""

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

  _removeProjectHook integration.project._id
  , integration.data[_projectId].hookId
  , integration.token

module.exports = service.register 'teambition', ->

  @title = 'Teambition'

  @template = 'webhook'

  @summary = service.i18n
    zh: '配置 Teambition 聚合，实时接收来自 Teambition 的任务，日程，分享等消息'
    en: 'This integration helps you receive real-time tasks, schedules and posts from Teambition'

  @description = service.i18n
    zh: '配置 Teambition 聚合，实时接收来自 Teambition 的任务，日程，分享等消息'
    en: 'This integration helps you receive real-time tasks, schedules and posts from Teambition'

  @iconUrl = service.static 'images/icons/teambition@2x.png'

  @registerEvent 'service.webhook', _receiveWebhook

  @registerEvent 'before.integration.create', _createWebhook

  @registerEvent 'before.integration.update', _updateWebhook

  @registerEvent 'before.integration.remove', _removeWebhook
