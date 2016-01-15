util = require '../util'
serviceLoader = require '../loader'

module.exports = ->
  self = this

  $service = serviceLoader.load 'github'
  .then (service) ->

    self.title = "Github Webhook"
    self.template = 'webhook'
    self.summary = service.summary
    self.description = service.description
    self.iconUrl = service.iconUrl
    self.display = false

    self._fields.push
      key: 'webhookUrl'
      type: 'text'
      readOnly: true
      description: util.i18n
        zh: '复制 web hook 地址到你的 github 当中使用。你也可以在管理界面当中找到这个 web hook 地址。'
        en: 'Copy this web hook to your github to use it. You may also find this url in the manager tab。'

    _receiveWebhook = service._events['service.webhook']
    self.registerEvent 'service.webhook', _receiveWebhook
