service = require '../service'

_receiveWebhook = (req, res) ->

  {integration} = req
  payload = req.body

  message =
    _integrationId: integration._id
    quote:
      text: "Fir.im: #{payload.msg}"
      redirectUrl: payload.link

  @sendMessage message

module.exports = service.register 'firim', ->

  @title = 'Firim'

  @summary = service.i18n
    zh: 'App 免费内测托管平台。'
    en: 'FIR.im is a beta testing platform that distribute beta versions of your apps and get feedback from users.'

  @description = service.i18n
    zh: 'FIR.im 是一个 app 免费内测托管平台。为某个话题添加 FIR.im 聚合后，你就能够在简聊上收取与绑定应用相关的系统消息。'
    en: 'FIR.im is a beta testing platform that distribute beta versions of your apps and get feedback from users. This integration allows you receive notifications from FIR.im.'

  @iconUrl = service.static 'images/icons/firim@2x.jpg'

  @registerEvent 'service.webhook', _receiveWebhook
