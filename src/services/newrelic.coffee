_ = require 'lodash'
Promise = require 'bluebird'
service = require '../service'

_receiveWebhook = () ->

module.exports = service.register 'newrelic', ->
  @title = 'New Relic'

  @template = 'webhook'

  @summary = service.i18n
    zh: 'New Relic 是应用分析和监控平台。'
    en: 'New Relic is an APM platform.'

  @description = service.i18n
    zh: 'New Relic 是应用分析和监控平台。接入后可以收到应用和服务错误报警的实时通知。'
    en: 'New Relic is an APM platform. High-performing apps. Delightful customer experiences. Better business results. Discover the power of Software Analytics.'

  @iconUrl = service.static 'images/icons/newrelic@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readonly: true
    description: service.i18n
      zh: '复制 web hook 地址到你的 New Relic 中使用。'
      en: 'Copy this web hook to your New Relic account to use it.'

  # Apply function on `webhook` event
  @registerEvent 'service.webhook', _receiveWebhook
