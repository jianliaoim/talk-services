_ = require 'lodash'
Promise = require 'bluebird'
validator = require 'validator'

util = require '../util'

_checkIntegration = ({integration}) ->
  unless validator.isURL(integration.url)
    throw new Error('Invalid url field')

module.exports = ->

  @title = 'Outgoing Webhook'

  @template = 'form'

  @isCustomized = true

  @summary = util.i18n
    zh: 'Outgoing Webhook 以 JSON 格式将消息数据推送给你的服务'
    en: 'Outgoing Webhook send messages to your service with a JSON formatted payload.'

  @description = util.i18n
    zh: 'Outgoing Webhook 通过 POST 请求将话题中的消息数据推送给你，你可以在配置中修改接受请求的服务地址。'
    en: 'Outgoing Webhook makes use of normal HTTP requests with a JSON payload. Let use know your service url and wait for the messages.'

  @iconUrl = util.static 'images/icons/outgoing@2x.png'

  @_fields.push
    key: 'url'
    type: 'text'
    required: true
    description: util.i18n
      zh: '请填写你的 Webhook url'
      en: 'Webhook url of your application'

  @_fields.push
    key: 'token'
    type: 'text'
    autoGen: true
    description: util.i18n
      zh: 'Token 会被包含在发送给你的消息中'
      en: 'Token will include in the received message'

  @registerEvent 'before.integration.create', _checkIntegration
