_ = require 'lodash'
Promise = require 'bluebird'

util = require '../util'

###*
 * Define handler when receive incoming webhook from heroku
 * @param  {Object}   req      Express request object
 * @param  {Object}   res      Express response object
 * @param  {Function} callback
 * @return {Promise}
###

_receiveWebhook = ({ integration, body }) ->
  payload = body

  return unless payload

  message =
    integration: integration
    attachments: [
      category: 'quote'
      data:
        redirectUrl: payload.url
        text: """
              #{ payload.user } deployed version #{ payload.head },
              git log: #{ payload.git_log }
              """
        title: "#{ payload.app }"
    ]

  @sendMessage message

module.exports = ->

  @title = 'Heroku'

  @template = 'webhook'

  @summary = util.i18n
    zh: '支持多种编程语言的云平台即服务。'
    en: 'A cloud platform as a service (PaaS).'

  @description = util.i18n
    zh: 'Heroku 是支持多种编程语言的云平台即服务（PaaS）。接入后可以收到部署的通知。'
    en: 'Heroku is a cloud platform as a service (PaaS) supporting several programming languages.'

  @iconUrl = util.static 'images/icons/heroku@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readonly: true
    description: util.i18n
      zh: '复制 web hook 地址到你的 Heroku 中使用。'
      en: 'Copy this web hook to your Heroku account to use it.'

  # Apply function on `webhook` event
  @registerEvent 'service.webhook', _receiveWebhook
