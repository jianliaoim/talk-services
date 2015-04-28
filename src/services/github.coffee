Promise = require 'bluebird'
marked = require 'marked'
_ = require 'lodash'
request = require 'request'
requestAsync = Promise.promisify request
service = require '../service'

_apiHost = 'https://api.github.com'
_pageHost = 'https://github.com'

###*
 * Create github hook
 * @param  {String} repos - Repos name
 * @param  {String} token - Token
 * @param  {Object} notifications - Events of hook
 * @param  {String} hashId - HashId of integration
 * @return {Promise} Response body
###
_createHook = (repos, token, notifications, hashId) ->
  requestAsync
    method: 'POST'
    url: "#{_apiHost}/repos/#{repos}/hooks"
    headers:
      'User-Agent': service.userAgent
      'Authorization': "token #{token}"
    json: true
    body:
      name: 'web'
      active: true,
      events: _.keys(notifications)
      config:
        url: "#{service.apiHost}/services/webhook/#{hashId}"
        content_type: 'json'

  .spread (res, body) ->
    unless res.statusCode >= 200 and res.statusCode < 300
      err = new Error("Bad request #{res.statusCode}")
    throw err if err
    body

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
    url: "#{_apiHost}/repos/#{repos}/hooks/#{hookId}"
    headers:
      'User-Agent': service.userAgent
      'Authorization': "token #{token}"
    json: true
  .spread (res, body) ->
    unless res.statusCode >= 200 and res.statusCode < 300
      err = new Error("bad request #{res.statusCode}")
    throw err if err

###*
 * Update github hook
 * @param  {String} repos - Repos name
 * @param  {String} hookId - Github hook id
 * @param  {String} token - Token
 * @param  {Object} notifications - Events of hook
 * @param  {String} hashId - hashId of integration
 * @return {Promise} Response body
###
_updateHook = (repos, hookId, token, notifications, hashId) ->
  requestAsync
    method: 'PATCH'
    url: "#{_apiHost}/repos/#{repos}/hooks/#{hookId}"
    headers:
      'User-Agent': service.userAgent
      'Authorization': "token #{token}"
    json: true
    body:
      name: 'web'
      active: true,
      events: _.keys(notifications)
      config:
        url: "#{service.apiHost}/services/webhook/#{hashId}"
        content_type: 'json'

  .spread (res, body) ->
    unless res.statusCode >= 200 and res.statusCode < 300
      err = new Error("bad request #{res.statusCode}")
    throw err if err
    body

_createWebhook = (integration) ->
  self = this
  data = {}

  Promise.resolve integration.repos

  .map (repos) ->

    _createHook repos
    , integration.token
    , integration.notifications
    , integration.hashId

    .then (body) ->
      # Replace the dot in keys
      _repos = repos.split('.').join('_')
      data[_repos] = hookId: body?.id

  .then ->
    integration.data = data
    integration

_removeWebhook = (integration) ->
  self = this
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

_updateWebhook = (integration) ->
  self = this
  return unless ['repos', 'notifications'].some (field) -> integration.isDirectModified field
  {_originalRepos, _originalNotifications, data} = integration
  data or= {}
  reposes = integration.repos

  $removeOldRepos = Promise.resolve(_originalRepos)

  .map (repos) ->
    return if repos in reposes  # Do not remove when the repos exist in the new array
    _repos = repos.split('.').join('_')
    hookId = data[_repos]?.hookId
    return delete data[_repos] unless hookId  # remove the original hookId when repos not exist
    _removeWebhook repos
    , hookId
    , integration.token

  $updateNewRepos = Promise.resolve(reposes)

  .map (repos) ->
    _repos = repos.split('.').join('_')
    # Update exist hook
    if (repos in _originalRepos) or not integration.isDirectModified 'repos'
      # Do not update when notifications is not modified
      return unless integration.isDirectModified 'notifications'
      hookId = data[_repos]?.hookId
      throw new Error('Github hook not found') unless hookId  # Stop the update process when hookId not found
      _updateHook repos
      , hookId
      , integration.token
      , integration.notifications
      , integration.hashId
    else  # Create new hook
      _createHook repos
      , integration.token
      , integration.notifications
      , integration.hashId

      .then (body) ->
        data[_repos] = hookId: body?.id

  Promise.all [$removeOldRepos, $updateNewRepos]
  .then -> integration.data = data

_receiveWebhook = ({headers, body, integration}) ->
  self = this
  event = headers['x-github-event']
  payload = body
  {sender, issue, action, comment, repository, forkee, head_commit, commits, pull_request} = payload

  message =
    _integrationId: integration._id
    quote:
      userName: sender.login
      userAvatarUrl: sender.avatar_url

  switch event
    when 'commit_comment'
      message.quote.title = "#{repository.full_name} commit comment by #{sender?.login}"
      message.quote.text = "#{marked(comment?.body or '')}"
      message.quote.redirectUrl = comment?.html_url
    when 'create'
      message.quote.title = "#{repository.full_name} #{payload.ref_type} #{payload.ref} created by #{sender?.login}"
      message.quote.redirectUrl = repository?.html_url
    when 'delete'
      message.quote.title = "#{repository.full_name} #{payload.ref_type} #{payload.ref} deleted by #{sender?.login}"
      message.quote.redirectUrl = repository?.html_url
    when 'fork'
      message.quote.title = "#{repository.full_name} forked to #{forkee?.full_name}"
      message.quote.redirectUrl = forkee?.html_url
    when 'issue_comment'
      message.quote.title = "#{repository.full_name} issue comment by #{sender?.login}"
      message.quote.text = "#{marked(comment?.body or '')}"
      message.quote.redirectUrl = comment?.html_url
    when 'issues'
      message.quote.title = "#{repository.full_name} issue #{action or ''} #{issue?.title}"
      message.quote.text = marked(issue?.body or '')
      message.quote.redirectUrl = issue?.html_url
    when 'pull_request'
      message.quote.title = "#{repository.full_name} pull request #{pull_request?.title}"
      message.quote.text = marked(pull_request?.body or '')
      message.quote.redirectUrl = pull_request?.html_url
    when 'pull_request_review_comment'
      message.quote.title = "#{repository.full_name} review comment by #{sender?.login}"
      message.quote.text = marked(comment?.body or '')
      message.quote.redirectUrl = comment?.html_url
    when 'push'
      return false unless commits?.length
      message.quote.title = "#{repository.full_name} commits to #{payload.ref}"
      commitArr = commits.map (commit) ->
        """
        <a href="#{commit.url}" target="_blank"><code>#{commit?.id?[0...6]}:</code></a> #{commit?.message}<br>
        """
      message.quote.text = commitArr.join ''
      message.quote.redirectUrl = head_commit.url
    else
      return false

  @sendMessage message

module.exports = service.register 'github', ->

  @title = 'GitHub'

  @summary = service.i18n
    zh: '分布式的版本控制系统。'
    en: 'GitHub offers online source code hosting for Git projects.'

  @description = service.i18n
    zh: 'GitHub 是一个分布式的版本控制系统。选择一个话题添加 GitHub 聚合后，你就可以在被评论、创建或删除分支、仓库被 fork 等情形下收到简聊通知。'
    en: 'GitHub offers online source code hosting for Git projects. This integration allows you receive GitHub comments, pull request, etc. '

  @iconUrl = service.static 'images/icons/github@2x.png'

  @registerEvent 'before.integration.create', _createWebhook

  @registerEvent 'before.integration.update', _updateWebhook

  @registerEvent 'before.integration.remove', _removeWebhook

  @registerEvent 'service.webhook', _receiveWebhook
