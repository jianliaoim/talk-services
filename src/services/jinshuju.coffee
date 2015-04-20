service = require '../service'

_receiveWebhook = (req, res) ->
  {integration} = req

  payload = req.body
  message =
    _integrationId: integration._id
    quote:
      text: "#{payload.entry?.creator_name} 添加了新的数据"
      redirectUrl: "https://jinshuju.net/forms/#{payload.form}/entries"

  @sendMessage message

module.exports = service.register 'jinshuju', ->

  @title = '金数据'

  @template = 'webhook'

  @summary = service.i18n
    zh: '在线表单设计、数据收集、统计和分享工具。'
    en: 'Jinshuju.net is an online form design, data collection, statistics and sharing tools.'

  @description = service.i18n
    zh: '金数据是一款在线表单设计、数据收集、统计和分享工具。在金数据表单设置中填写 Webhook 地址后，你就可以在简聊话题内收取表单新的填写记录通知。'
    en: 'Jinshuju.net is an online form design, data collection, statistics and sharing tools. Fill in the data form setting Webhook address, you can simply receive new topics within a form to fill out log notification in Talk.'

  @registerEvent 'webhook', _receiveWebhook
