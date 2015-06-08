_ = require 'lodash'
service = require '../service'

_postMessage = (message) ->

module.exports = service.register 'outgoing', ->

  @title = 'Outgoing Webhook'

  @isCustomized = true

  @summary = service.i18n
    zh: 'Outgoing Webhook 以 JSON 格式将消息数据推送给你的服务'
    en: 'Outgoing Webhook send messages to your service with a JSON formatted payload.'

  @description = service.i18n
    zh: 'Outgoing Webhook 通过 POST 请求将话题中的消息数据推送给你，你可以在配置中修改接受请求的服务地址。'
    en: 'Outgoing Webhook makes use of normal HTTP requests with a JSON payload. Let use know your service url and wait for the messages.'

  @iconUrl = service.static 'images/icons/outgoing@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readOnly: true
    description: service.i18n
      zh: '复制 web hook 地址到你的应用中来启用 Outgoing Webhook。'
      en: 'To start using outgoing webhook, copy this url to your application'

  @registerEvent 'message.create', _postMessage
