Promise = require 'bluebird'
marked = require 'marked'
_ = require 'lodash'
request = require 'request'
requestAsync = Promise.promisify request

util = require '../util'

_getGitHubApiHost = -> util.config.github?.apiHost or 'https://api.github.com'

###*
 * Create github hook
 * @param  {String} repos - Repos name
 * @param  {String} token - Token
 * @param  {Array} events - Events of hook
 * @param  {String} hashId - HashId of integration
 * @return {Promise} Response body
###
_createHook = (repos, token, events, hashId) ->
  requestAsync
    method: 'POST'
    url: "#{_getGitHubApiHost()}/repos/#{repos}/hooks"
    headers:
      'User-Agent': util.getUserAgent()
      'Authorization': "token #{token}"
    json: true
    body:
      name: 'web'
      active: true,
      events: events
      config:
        url: "#{util.config.apiHost}/services/webhook/#{hashId}"
        content_type: 'json'

  .then (res) ->
    unless res.statusCode >= 200 and res.statusCode < 300
      err = new Error("Bad request #{res.statusCode}")
    throw err if err
    res.body

###*
 * Remove github hook
 * @param  {String} repos - Repos name
 * @param  {String} hookId - The github hook id
 * @param  {String} token - Github user token
 * @return {Promise}
###
_removeHook = (repos, hookId, token) ->
  requestAsync
    method: 'DELETE'
    url: "#{_getGitHubApiHost()}/repos/#{repos}/hooks/#{hookId}"
    headers:
      'User-Agent': util.getUserAgent()
      'Authorization': "token #{token}"
    json: true

  .then (res) ->
    unless res.statusCode >= 200 and res.statusCode < 300
      err = new Error("bad request #{res.statusCode}")
    throw err if err

  # Ignore github errors
  .catch (err) -> return false

###*
 * Update github hook
 * @param  {String} repos - Repos name
 * @param  {String} hookId - Github hook id
 * @param  {String} token - Token
 * @param  {Array} events - Events of hook
 * @param  {String} hashId - hashId of integration
 * @return {Promise} Response body
###
_updateHook = (repos, hookId, token, events, hashId) ->
  requestAsync
    method: 'PATCH'
    url: "#{_getGitHubApiHost()}/repos/#{repos}/hooks/#{hookId}"
    headers:
      'User-Agent': util.getUserAgent()
      'Authorization': "token #{token}"
    json: true
    body:
      name: 'web'
      active: true,
      events: events
      config:
        url: "#{util.config.apiHost}/services/webhook/#{hashId}"
        content_type: 'json'

  .then (res) ->
    unless res.statusCode >= 200 and res.statusCode < 300
      err = new Error("bad request #{res.statusCode}")
    throw err if err
    res.body

_createWebhook = ({integration}) ->
  self = this
  data = {}

  return if integration.url

  Promise.resolve integration.repos

  .map (repos) ->

    _createHook repos
    , integration.token
    , integration.events
    , integration.hashId

    .then (body) ->
      # Replace the dot in keys
      _repos = repos.split('.').join('_')
      data[_repos] = hookId: body?.id

  .then ->
    integration.data = data
    integration

_removeWebhook = ({integration}) ->
  self = this
  return if integration.url

  reposes = integration.repos
  data = integration.data or {}
  Promise.resolve reposes
  .map (repos) ->
    _repos = repos.split('.').join('_')
    hookId = data[_repos]?.hookId
    # Skip this when repos in not exist in data
    return unless hookId
    _removeHook repos
    , hookId
    , integration.token

_updateWebhook = (req) ->
  {integration} = req
  return if integration.url

  {events, repos} = req.get()
  return unless events?.length and repos?.length

  data = integration.data or {}
  if repos and not _.isEqual repos, integration.repos
    $removeOldRepos = Promise.resolve integration.repos
    .map (repos) ->
      return if repos in reposes  # Do not remove when the repos exist in the new array
      _repos = repos.split('.').join('_')
      hookId = data[_repos]?.hookId
      return delete data[_repos] unless hookId  # remove the original hookId when repos not exist
      _removeWebhook repos
      , hookId
      , integration.token
  else $removeOldRepos = Promise.resolve()

  $updateNewRepos = Promise.resolve integration.repos
  .map (repos) ->
    _repos = repos.split('.').join('_')
    # Update exist hook
    if _.isEqual integration.repos, repos
      # Do not update when notifications is not modified
      return if _.isEqual events, integration.events
      hookId = data[_repos]?.hookId
      throw new Error('Github hook not found') unless hookId  # Stop the update process when hookId not found
      _updateHook repos
      , hookId
      , integration.token
      , events
      , integration.hashId
    else  # Create new hook
      _createHook repos
      , integration.token
      , events
      , integration.hashId

      .then (body) -> data[_repos] = hookId: body?.id

  Promise.all [$removeOldRepos, $updateNewRepos]
  .then -> integration.data = data

_receiveWebhook = ({headers, body, integration}) ->
  self = this
  event = headers['x-github-event']
  payload = body
  {sender, issue, action, comment, repository, forkee, head_commit, commits, pull_request} = payload

  message = {}
  attachment =
    category: 'quote'
    data:
      userName: sender.login
      userAvatarUrl: sender.avatar_url

  switch event
    when 'commit_comment'
      attachment.data.title = "#{repository.full_name} commit comment by #{sender?.login}"
      attachment.data.text = "#{marked(comment?.body or '')}"
      attachment.data.redirectUrl = comment?.html_url
    when 'create'
      attachment.data.title = "#{repository.full_name} #{payload.ref_type} #{payload.ref} created by #{sender?.login}"
      attachment.data.redirectUrl = repository?.html_url
    when 'delete'
      attachment.data.title = "#{repository.full_name} #{payload.ref_type} #{payload.ref} deleted by #{sender?.login}"
      attachment.data.redirectUrl = repository?.html_url
    when 'fork'
      attachment.data.title = "#{repository.full_name} forked to #{forkee?.full_name}"
      attachment.data.redirectUrl = forkee?.html_url
    when 'issue_comment'
      attachment.data.title = "#{repository.full_name} issue comment by #{sender?.login}"
      attachment.data.text = "#{marked(comment?.body or '')}"
      attachment.data.redirectUrl = comment?.html_url
    when 'issues'
      attachment.data.title = "#{repository.full_name} issue #{action or ''} #{issue?.title}"
      attachment.data.text = marked(issue?.body or '')
      attachment.data.redirectUrl = issue?.html_url
    when 'pull_request'
      attachment.data.title = "#{repository.full_name} pull request #{pull_request?.title}"
      attachment.data.text = marked(pull_request?.body or '')
      attachment.data.redirectUrl = pull_request?.html_url
    when 'pull_request_review_comment'
      attachment.data.title = "#{repository.full_name} review comment by #{sender?.login}"
      attachment.data.text = marked(comment?.body or '')
      attachment.data.redirectUrl = comment?.html_url
    when 'push'
      return false unless commits?.length
      attachment.data.title = "#{repository.full_name} commits to #{payload.ref}"
      commitArr = commits.map (commit) ->
        authorPrefix = if commit?.committer?.name then " [#{commit.committer.name}] " else " "
        """
        <a href="#{commit.url}" target="_blank"><code>#{commit?.id?[0...6]}:</code></a>#{authorPrefix}#{commit?.message}<br>
        """
      attachment.data.text = commitArr.join ''
      attachment.data.redirectUrl = head_commit.url
    else return false

  message.attachments = [attachment]
  message

_getEvents = ->
  [
    key: 'push'
    label: util.i18n
      zh: 'Push'
      en: 'Push'
    title: util.i18n
      zh: "仓库的 Push, 包括编辑 tag 或者分支. 通过 API 发布的改变了缩印的 commit 也包括在内. 这是默认事件"
      en: "Any Git push to a Repository, including editing tags or branches. Commits via API actions that update references are also counted. This is the default event"
    checked: true
  ,
    key: 'commit_comment'
    label: util.i18n
      zh: 'Commit 被评论'
      en: 'Comment on commit'
    title: util.i18n
      en: 'Any time a Commit is commented on'
  ,
    key: 'create'
    label: util.i18n
      zh: '创建分支或者 tag'
      en: 'Create branch or tag'
    title: util.i18n
      en: 'Any time a Branch or Tag is created'
  ,
    key: 'delete'
    label: util.i18n
      zh: '删除分支或者 tag'
      en: 'Delete branch or tag'
    title: util.i18n
      en: 'Any time a Branch or Tag is deleted'
  ,
    key: 'fork'
    label: util.i18n
      zh: '仓库被 Fork'
      en: 'Fork'
    title: util.i18n
      en: 'Any time a Repository is forked'
  ,
    key: 'issue_comment'
    label: util.i18n
      zh: 'Issue 被评论'
      en: 'Comment on issue'
    title: util.i18n
      en: 'Any time an Issue is commented on'
  ,
    key: 'issues'
    label: util.i18n
      zh: 'Issues'
      en: 'Issues'
    title: util.i18n
      zh: 'Issue 被指定, 取消指定, 标记, 取消标记, 创建, 关闭, 重新打开'
      en: 'Any time an Issue is assigned, unassigned, labeled, unlabeled, opened, closed, or reopened'
  ,
    key: 'pull_request_review_comment'
    label: util.i18n
      zh: 'PR 中增加 Commit'
      en: 'Commit in PR'
    title: util.i18n
      zh: 'Pull Request（的文件页面）当中的 Commit 被评论'
      en: 'Any time a Commit is commented on while inside a Pull Request review (the Files Changed tab)'
  ,
    key: 'pull_request'
    label: util.i18n
      zh: 'Pull request'
      en: 'Pull request'
    title: util.i18n
      zh: 'Pull Request 被指定, 取消指定, 标记, 取消标记, 打开, 关闭, 重新打开, 或者同步（pull request 正在追踪的分支上新的 Push 引起的更新）'
      en: 'Any time a Pull Request is assigned, unassigned, labeled, unlabeled, opened, closed, reopened, or synchronized (updated due to a new push in the branch that the pull request is tracking)'
  ]

module.exports = ->

  @title = 'GitHub'

  @summary = util.i18n
    zh: '分布式的版本控制系统。'
    en: 'GitHub offers online source code hosting for Git projects.'

  @description = util.i18n
    zh: 'GitHub 是一个分布式的版本控制系统。选择一个话题添加 GitHub 聚合后，你就可以在被评论、创建或删除分支、仓库被 fork 等情形下收到简聊通知。'
    en: 'GitHub offers online source code hosting for Git projects. This integration allows you receive GitHub comments, pull request, etc. '

  @iconUrl = util.static 'images/icons/github@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readOnly: true
    description: util.i18n
      zh: '请复制您的 Webhook 地址到 GitHub 中使用'
      en: 'Copy and paste your github webhook url'

  @_fields.push
    key: 'events'
    items: _getEvents.apply this

  @registerEvent 'before.integration.create', _createWebhook

  @registerEvent 'before.integration.update', _updateWebhook

  @registerEvent 'before.integration.remove', _removeWebhook

  @registerEvent 'service.webhook', _receiveWebhook
