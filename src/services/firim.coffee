service = require '../service'

_receiveWebhook = ({integration, body}) ->
  payload = body
  message =
    integration: integration
    quote:
      text: "fir.im: #{payload.msg}"
      redirectUrl: payload.link

  @sendMessage message

module.exports = service.register 'firim', ->

  @title = 'fir.im'

  @template = 'webhook'

  @summary = service.i18n
    zh: 'App 免费内测托管平台。'
    en: 'fir.im is a beta testing platform that distribute beta versions of your apps and get feedback from users.'

  @description = service.i18n
    zh: 'fir.im 是一个 app 免费内测托管平台。为某个话题添加 fir.im 聚合后，你就能够在简聊上收取与绑定应用相关的系统消息。'
    en: 'fir.im is a beta testing platform that distribute beta versions of your apps and get feedback from users. This integration allows you receive notifications from fir.im.'

  @iconUrl = service.static 'images/icons/firim@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readonly: true
    description: service.i18n
      zh: '复制 web hook 地址到你的 fir.im 的配置当中使用。你也可以在管理界面当中找到这个 web hook 地址。'
      en: 'Copy this web hook to your fir.im account to use it. You may also find this url in the manager tab.'

  @registerEvent 'service.webhook', _receiveWebhook
