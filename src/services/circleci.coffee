service = require '../service'

_receiveWebhook = ({integration, body}) ->
  payload = body?.payload

  return unless payload

  message = integration: integration
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
  @sendMessage message

module.exports = service.register 'circleci', ->

  @title = 'Circle CI'

  @template = 'webhook'

  @summary = service.i18n
    zh: '持续集成平台'
    en: 'Hosted Continuous Integration for web applications.'

  @description = service.i18n
    zh: '持续集成平台'
    en: 'Hosted Continuous Integration for web applications. Set up your application for testing in one click, on the fastest testing platform on the internet.'

  @iconUrl = service.static 'images/icons/circleci@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readonly: true
    description: service.i18n
      zh: '复制 web hook 地址到 .circle.yml 中使用。'
      en: 'Copy this web hook to .circle.yml to use it.'

  @registerEvent 'service.webhook', _receiveWebhook
