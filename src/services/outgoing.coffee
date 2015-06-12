_ = require 'lodash'
lexer = require 'talk-lexer'
Promise = require 'bluebird'
validator = require 'validator'
service = require '../service'

_trySendMessage = (url, message) ->
  tryTimes = 0
  maxTryTimes = 5
  delay = 1000
  self = this

  _sendMessage = ->
    self.httpPost url, message

    .catch (err) ->
      tryTimes += 1
      throw err if tryTimes > maxTryTimes
      Promise.delay delay
      .then ->
        delay *= 3
        _sendMessage()

  _sendMessage()

_postMessage = (message) ->
  _message = _.pick message, '_id', 'room', 'creator', 'createdAt', 'updatedAt', "_teamId"
  # Ignore system messages
  return unless message.isManual
  # Ignore integration messages
  return if message.quote?.category and message.quote.category isnt 'url'
  # Ignore file upload messages
  return if message.file?.fileKey
  # Ignore private chat messages
  return unless message._roomId
  _message.content = message.text or lexer(message.content).text()
  {limbo} = service.components
  {IntegrationModel} = limbo.use 'talk'

  self = this

  IntegrationModel.findAsync
    room: message._roomId
    category: 'outgoing'
    errorInfo: null

  .map (integration) ->
    {url, token} = integration

    msg = _.clone _message
    msg.token = token if token?.length

    _trySendMessage.call self, url, msg

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
