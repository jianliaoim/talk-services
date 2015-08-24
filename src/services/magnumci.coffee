service = require '../service'

_receiveWebhook = ({integration, body}) ->
  payload = body?.payload

  try
    if toString.call(payload) is '[object String]'
      payload = JSON.parse payload
    return false unless toString.call(payload) is '[object Object]'
  catch err
    return false

  throw new Error('Params missing') unless payload.title

  message =
    integration: integration
    attachments: [
      category: 'quote'
      data:
        title: payload.title
        text: payload.message
        redirectUrl: payload.build_url
    ]
  @sendMessage message

module.exports = service.register 'magnumci', ->

  @title = 'Magnum CI'

  @template = 'webhook'

  @summary = service.i18n
    zh: '可用于私有项目的持续集成平台'
    en: 'Hosted Continuous Integration Platform for Private Repositories'

  @description = service.i18n
    zh: '可用于私有项目的持续集成平台'
    en: 'Hosted Continuous Integration Platform for Private Repositories'

  @iconUrl = service.static 'images/icons/magnumci@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readonly: true
    description: service.i18n
      zh: '复制 web hook 地址到你的 Magnum CI 中使用。'
      en: 'Copy this web hook to your Magnum CI account to use it.'

  @registerEvent 'service.webhook', _receiveWebhook
