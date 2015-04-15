Promise = require 'bluebird'
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
 * @param  {String} hashId - hashId of integration
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
      err = new Error("bad request #{res.statusCode}")
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

_createWebhook = (req, res) ->
  self = this
  {integration} = req
  data = {}

  Promise.resolve integration.repos

  .each (repos) ->

    _createHook repos
    , integration.token
    , integration.notifications
    , integration.hashId

    .then (body) -> data[repos] = hookId: body?.id

  .then ->
    integration.data = data
    integration

_removeWebhook = (req, res) ->
  self = this
  {integration} = req
  reposes = integration.repos
  data = integration.data or {}
  Promise.resolve reposes
  .each (repos) ->
    hookId = data[repos]?.hookId
    # Skip this when repos in not exist in data
    return unless hookId
    _removeHook repos
    , hookId
    , integration.token

_updateWebhook = (req, res) ->
  self = this
  {integration} = req
  return unless ['repos', 'notifications'].some (field) -> integration.isDirectModified field
  {_originalRepos, _originalNotifications, data} = integration
  data or= {}
  reposes = integration.repos

  $removeOldRepos = Promise.resolve(_originalRepos)

  .each (repos) ->
    return if repos in reposes  # Do not remove when the repos exist in the new array
    hookId = data[repos]?.hookId
    unless hookId  # remove the original hookId when repos not exist
      return delete data[repos]
    _removeWebhook repos
    , hookId
    , integration.token

  $updateNewRepos = Promise.resolve(reposes)

  .each (repos) ->
    # Update exist hook
    if (repos in _originalRepos) or not integration.isDirectModified 'repos'
      # Do not update when notifications is not modified
      return unless integration.isDirectModified 'notifications'
      hookId = data[repos]?.hookId
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
        data[repos] = hookId: body?.id

  Promise.all [$removeOldRepos, $updateNewRepos]
  .then -> integration.data = data

_receiveWebhook = (req, res) ->

module.exports = service.register 'github', ->

  @title = 'GitHub'

  @summary = service.i18n
    zh: '分布式的版本控制系统。'
    en: 'GitHub offers online source code hosting for Git projects.'

  @description = service.i18n
    zh: 'GitHub 是一个分布式的版本控制系统。选择一个话题添加 GitHub 聚合后，你就可以在被评论、创建或删除分支、仓库被 fork 等情形下收到简聊通知。'
    en: 'GitHub offers online source code hosting for Git projects. This integration allows you receive GitHub comments, pull request, etc. '

  @iconUrl = service.static 'images/icons/github@2x.png'

  @registerEvent 'integration.create', _createWebhook

  @registerEvent 'integration.update', _updateWebhook

  @registerEvent 'integration.remove', _removeWebhook

  @registerEvent 'webhook', _receiveWebhook
