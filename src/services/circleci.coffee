util = require '../util'

_receiveWebhook = ({body}) ->
  payload = body?.payload

  return unless payload

  message = {}
  attachment = category: 'quote', data: {}

  if payload?.outcome is 'success'
    attachment.data.title = "[#{payload.reponame}] Build success: #{payload.subject}"
  else
    attachment.data.title = "[#{payload.reponame}] Build fail: #{payload.outcome}"
    if toString.call(payload.messages) is '[object Array]'
      attachment.data.text = payload.messages?.map (message) -> message?.message or ''
        .join '<br>'

  attachment.data.redirectUrl = payload.build_url
  message.attachments = [attachment]
  message

module.exports = ->

  @title = 'Circle CI'

  @template = 'webhook'

  @summary = util.i18n
    zh: '持续集成平台'
    en: 'Hosted Continuous Integration for web applications.'

  @description = util.i18n
    zh: '持续集成平台'
    en: 'Hosted Continuous Integration for web applications. Set up your application for testing in one click, on the fastest testing platform on the internet.'

  @iconUrl = util.static 'images/icons/circleci@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readonly: true
    description: util.i18n
      zh: '复制 web hook 地址到 .circle.yml 中使用。'
      en: 'Copy this web hook to .circle.yml to use it.'

  @registerEvent 'service.webhook', _receiveWebhook
