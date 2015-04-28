Promise = require 'bluebird'
request = require 'request'
requestAsync = Promise.promisify request

service = require '../service'

_tbHost = 'https://www.teambition.com'

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
 * Create teambition hook
 * @param  {String} _projectId - Teambition project id
 * @param  {String} token - Token
 * @param  {Object} notifications - Object hash
 * @param  {String} hashId - Hashed id of integration
 * @return {Promise} Response body
###
_createHook = (_projectId, token, notifications, hashId) ->
  requestAsync
    method: 'POST'
    headers: 'User-Agent': service.userAgent
    url: "#{_apiHost}/api/projects/#{_projectId}/hooks"
    json: true
    body:
      access_token: token
      callbackURL: "#{service.apiHost}/services/webhook/#{hashId}"
      events: _.keys(notifications)

  .spread (res, body) ->
    unless res.statusCode >= 200 and res.statusCode < 300
      err = new Error("Bad request #{res.statusCode}")
    throw err if err
    body

_createWebhook = (integration) ->

_updateWebhook = (integration) ->

_removeWebhook = (integration) ->

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
