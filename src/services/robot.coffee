service = require '../service'

###*
 * Post message to the bundled url
 * @param  {Model} message
 * @return {Promise}
###
_postMessage = (message) ->

###*
 * Remove this robot from bundled team
 * @param  {Model} integration
 * @return {Promise}
###
_removeRobot = (integration) ->

###*
 * Create a new robot and invite him to this team
 * Fork current robot as the bundle user of this integration
 * @param  {Model} integration
 * @return {Promise}
###
_createRobot = (integration) ->

module.exports = service.register 'robot', ->

  @title = '自定义机器人'

  @summary = service.i18n
    zh: '自定义的小艾'
    en: ''

  @description = service.i18n
    zh: '自定义的小艾'
    en: ''

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

  @registerEvent 'before.integration.create', _createRobot

  @registerEvent 'before.integration.remove', _removeRobot
