_ = require 'lodash'
Promise = require 'bluebird'

util = require '../util'

###*
 * Define handler when receive incoming webhook from new relic
 * @param  {Object}   req      Express request object
 * @param  {Object}   res      Express response object
 * @param  {Function} callback
 * @return {Promise}
###

_receiveWebhook = ({ integration, body }) ->
  payload = body

  return unless payload

  title = []
  title.push payload.event_type, ': '
  if payload.condition_name isnt ''
    title.push payload.condition_name

  text = []
  if payload.owner isnt ''
    text.push 'Owner: ', payload.owner, '\n'
  if payload.details isnt ''
    text.push 'Incident: ', payload.details

  message =
    attachments: [
      category: 'quote'
      data:
        redirectUrl: payload.incident_url
        title: title.join ''
        text: text.join ''
    ]

  message

module.exports = ->

  @title = 'New Relic'

  @template = 'webhook'

  @summary = util.i18n
    zh: 'New Relic 是应用分析和监控平台。'
    en: 'New Relic is an APM platform.'

  @description = util.i18n
    zh: 'New Relic 是应用分析和监控平台。接入后可以收到应用和服务错误报警的实时通知。'
    en: 'New Relic is an APM platform. High-performing apps. Delightful customer experiences. Better business results. Discover the power of Software Analytics.'

  @iconUrl = util.static 'images/icons/newrelic@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readonly: true
    description: util.i18n
      zh: '复制 web hook 地址到你的 New Relic 中使用。'
      en: 'Copy this web hook to your New Relic account to use it.'

  # Apply function on `webhook` event
  @registerEvent 'service.webhook', _receiveWebhook
