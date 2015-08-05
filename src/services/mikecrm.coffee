service = require '../service'
_ = require 'lodash'

_receiveWebhook = ({integration, body}) ->
  payload = body
  return unless payload.headers
  title = "MikeCRM: #{payload.body.form.name} #{payload.body.form.title}"
  text = []
  _.forIn payload.body.component, (component) ->
    if component.title and component.value
      if typeof component.value is 'object' then text.push "#{component.title} : #{String(_.values component.value)}"
      else text.push "#{component.title} : #{component.value}"

  text = text.join '\n'

  message =
    integration: integration
    attachments: [
      category: 'quote'
      data:
        title: title
        text: text
        redirectUrl: payload.body.form.url
    ]
  @sendMessage message

module.exports = service.register 'mikecrm', ->

  @title = '麦客CRM'

  @template = 'webhook'

  @summary = service.i18n
    zh: '麦客CRM是一款轻量好用的表单和联系人管理工具。'
    en: 'MikeCRM is a light and useful tool for organizations or individuals to make, release and collect online-forms for all kind of reasons, mostly for marketing and customer management.'

  @description = service.i18n
    zh: '麦客CRM是一款轻量好用的表单和联系人管理工具。以表单收集信息、以联系人管理信息、再以邮件和短信为营销出口，使企业能够更好地将信息传达给最终客户，从而帮助企业更轻松地达成客户管理和市场营销目标。'
    en: 'MikeCRM is a light and useful tool for organizations or individuals to make, release and collect online-forms for all kinds of reasons, mostly for marketing and customer management. MikeCRM collects form feedback, extracts valuable information about customers, and afterwards, trying to reach them by e-mail or short messages in due course. Through this "feedback and touch" way, MikeCRM is supposed to build a short and direct path connecting customers and their own customers.'

  @iconUrl = service.static 'images/icons/mikecrm@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readonly: true
    description: service.i18n
      zh: '复制 web hook 地址到你的麦客中使用。'
      en: 'Copy this web hook to your MikeCRM account to use it.'

  @registerEvent 'service.webhook', _receiveWebhook
