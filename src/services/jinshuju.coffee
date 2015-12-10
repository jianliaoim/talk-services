util = require '../util'

_receiveWebhook = ({integration, body}) ->
  payload = body

  message =
    integration: integration
    attachments: [
      category: 'quote'
      data:
        text: "#{payload.entry?.creator_name} 添加了新的数据"
        redirectUrl: "https://jinshuju.net/forms/#{payload.form}/entries"
    ]
  @sendMessage message

module.exports = ->

  @title = '金数据'

  @template = 'webhook'

  @summary = util.i18n
    zh: '在线表单设计、数据收集、统计和分享工具。'
    en: 'Jinshuju.net is an online form design, data collection, statistics and sharing tools.'

  @description = util.i18n
    zh: '金数据是一款在线表单设计、数据收集、统计和分享工具。在金数据表单设置中填写 Webhook 地址后，你就可以在简聊话题内收取表单新的填写记录通知。<a href="https://jinshuju.net/auth/teambition" target="_blank">使用 Teambition 账号登录金数据</a>'
    en: 'Jinshuju.net is an online form design, data collection, statistics and sharing tools. Fill in the data form setting Webhook address, you can simply receive new topics within a form to fill out log notification in Talk.<a href="https://jinshuju.net/auth/teambition" target="_blank">Log in Jinshuju with Teambition account</a>'

  @iconUrl = util.static 'images/icons/jinshuju@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readonly: true
    description: util.i18n
      zh: '您可以在表单的"设置 —— 数据提交"页面的底部找到"将数据以 JSON 格式发送给第三方"，填写 webhook 地址即可接收推送通知。'
      en: 'At the bottom of the page "Settings -- Data" you may find "Sends the data in JSON format to third parties", fill out the webhook address to receive push notifications.'

  @registerEvent 'service.webhook', _receiveWebhook
