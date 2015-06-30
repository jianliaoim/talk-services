service = require '../service'

_receiveWebhook = ({integration, body}) ->
  payload = body?.payload

  return unless payload

  message =
    integration: integration
    quote: {}

  if payload?.outcome is 'success'
    message.quote.title = "[#{payload.reponame}] Build success: #{payload.subject}"
  else
    message.quote.title = "[#{payload.reponame}] Build fail: #{payload.outcome}"
    if toString.call(payload.messages) is '[object Array]'
      message.quote.text = payload.messages?.map (message) -> message?.message or ''
        .join '<br>'

  message.quote.redirectUrl = payload.build_url

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
      zh: '复制 web hook 地址到你的 Circle CI 中使用。'
      en: 'Copy this web hook to your Circle CI account to use it.'

  @registerEvent 'service.webhook', _receiveWebhook
