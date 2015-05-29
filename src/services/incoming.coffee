_ = require 'lodash'
service = require '../service'

_receiveWebhook = ({integration, query, body}) ->
  payload = _.assign {}
    , query or {}
    , body or {}

  {
    authorName
    title
    text
    redirectUrl
    imageUrl
  } = payload

  throw new Error("Title and text can not be empty") unless title?.length or text?.length

  message =
    _integrationId: integration._id
    quote:
      authorName: authorName
      title: title
      text: text
      redirectUrl: redirectUrl
      thumbnailPicUrl: imageUrl
      originalPicUrl: imageUrl

  @sendMessage message

module.exports = service.register 'incoming', ->

  @title = 'Incoming Webhook'

  @template = 'webhook'

  @isCustomized = true

  @summary = service.i18n
    zh: 'Incoming Webhook 是使用普通的 HTTP 请求与 JSON 数据从外部向简聊发送消息的简单方案。'
    en: 'Incoming Webhook makes use of normal HTTP requests with a JSON payload.'

  @description = service.i18n
    zh: 'Incoming Webhook 是使用普通的 HTTP 请求与 JSON 数据从外部向简聊发送消息的简单方案。你可以将 Webook 地址复制到第三方服务，通过简单配置来自定义收取相应的推送消息。'
    en: 'Incoming Webhook makes use of normal HTTP requests with a JSON payload. Copy your webhook address to third-party services to configure push notifications.'

  @iconUrl = service.static 'images/icons/incoming@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readOnly: true
    description: service.i18n
      zh: '复制 web hook 地址到你的应用中来启用 Incoming Webhook。'
      en: 'To start using incoming webhook, copy this url to your application'

  @registerEvent 'service.webhook', _receiveWebhook
