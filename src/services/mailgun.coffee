_ = require 'lodash'
util = require '../util'

_receiveWebhook = ({body}) ->
  payload = body or {}

  switch payload.event
    when 'delivered'
      text = '''
      Delivered messages
      '''
    when 'dropped'
      text = """
      Dropped messages
      reason: #{payload.reason}
      """
    when 'bounced'
      text = """
      Hard bounces
      error: #{payload.error}
      """
    when 'complained'
      text = """
      Spam complaints
      """
    when 'unsubscribed'
      text = """
      Unsubscribes
      user-agent: #{payload['user-agent']}
      """
    when 'clicked'
      text = """
      Clicks
      url: #{payload['url']}
      user-agent: #{payload['user-agent']}
      """
    when 'opened'
      text = """
      Opens
      user-agent: #{payload['user-agent']}
      """
    else return

  if payload['message-headers']
    text += '\n\n' + JSON.parse(payload['message-headers']).map (header) ->
      header[0] + ': ' + header[1] if typeof header[1] is 'string'
    .filter (header) -> header
    .join '\n'

  message =
    attachments: [
      category: 'quote'
      data:
        text: text
    ]

  message

module.exports = ->

  @title = 'Mailgun'

  @template = 'webhook'

  @summary = util.i18n
    zh: '邮件发送服务'
    en: 'Email service'

  @description = util.i18n
    zh: '邮件发送服务'
    en: 'Email service'

  @iconUrl = util.static 'images/icons/mailgun@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readOnly: true
    description: util.i18n
      zh: '复制 web hook 地址到你的应用中来启用 Mailgun 聚合'
      en: 'To start using mailgun integration, copy this url to your application'

  @registerEvent 'service.webhook', _receiveWebhook
