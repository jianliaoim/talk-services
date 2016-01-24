Promise = require 'bluebird'
_ = require 'lodash'

util = require '../util'

module.exports = ->

  @title = '自定义机器人'

  @template = 'form'

  @isCustomized = true

  @showRobot = true

  @summary = util.i18n
    zh: '我们提供了开放的数据接口，你可以利用自定义机器人开发各种应用和服务。'
    en: 'A robot act as a real user'

  @description = util.i18n
    zh: '自定义机器人的功能不限，你可以利用我们提供的开放数据接口，开发更多简聊的相关应用和服务。'
    en: 'A robot act as a real user'

  @iconUrl = util.static 'images/icons/robot@2x.png'

  @headerFields = []

  @fields = [
    key: 'url'
    type: 'text'
    description: util.i18n
      zh: '（可选）你可以通过 Webhook URL 来接收用户发送给机器人的消息'
      en: '(Optional) Webhook url of your application'
  ,
    key: 'token'
    type: 'text'
    autoGen: true
    description: util.i18n
      zh: '（可选）Token 会被包含在发送给你的消息中'
      en: '(Optional) Token will include in the received message'
  ,
    key: 'webhookUrl'
    type: 'text'
    readonly: true
    showOnSaved: true
    description: util.i18n
      zh: '通过 Webhook URL 发送消息给话题或成员'
      en: 'Send messages to users or channels through webhook URL'
  ]
