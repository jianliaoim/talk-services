_ = require 'lodash'
lexer = require 'talk-lexer'
Promise = require 'bluebird'
validator = require 'validator'
service = require '../service'

_postMessage = (message) ->
  # Ignore private chat messages
  return unless message._roomId
  {limbo} = service.components
  {IntegrationModel} = limbo.use 'talk'

  self = this

  IntegrationModel.findAsync
    room: message._roomId
    category: 'outgoing'
    errorInfo: null

  .map (integration) ->
    {url, token} = integration

    msg = _.clone message
    msg.token = token if token?.length

    self.httpPost url, msg, retryTimes: 5

    .then (body) ->
      return unless body?.text
      # Send replyMessage to user
      replyMessage =
        quote: body
        integration: integration
      self.sendMessage replyMessage

    .catch (err) ->
      integration.errorTimes += 1
      integration.lastErrorInfo = err.message
      integration.errorInfo = err.message if integration.errorTimes > 3
      new Promise (resolve, reject) ->
        integration.save (err, integration) ->
          return reject(err) if err
          resolve()

_checkIntegration = (integration) ->
  unless validator.isURL(integration.url)
    throw new Error('Invalid url field')

module.exports = service.register 'outgoing', ->

  @title = 'Outgoing Webhook'

  @template = 'form'

  @isCustomized = true

  @summary = service.i18n
    zh: 'Outgoing Webhook 以 JSON 格式将消息数据推送给你的服务'
    en: 'Outgoing Webhook send messages to your service with a JSON formatted payload.'

  @description = service.i18n
    zh: 'Outgoing Webhook 通过 POST 请求将话题中的消息数据推送给你，你可以在配置中修改接受请求的服务地址。'
    en: 'Outgoing Webhook makes use of normal HTTP requests with a JSON payload. Let use know your service url and wait for the messages.'

  @iconUrl = service.static 'images/icons/outgoing@2x.png'

  @_fields.push
    key: 'url'
    type: 'text'
    description: service.i18n
      zh: '请填写你的 Webhook url'
      en: 'Webhook url of your application'

  @_fields.push
    key: 'token'
    type: 'text'
    autoGen: true
    description: service.i18n
      zh: 'Token 会被包含在发送给你的消息中'
      en: 'Token will include in the received message'

  @registerEvent 'message.create', _postMessage

  @registerEvent 'before.integration.create', _checkIntegration
