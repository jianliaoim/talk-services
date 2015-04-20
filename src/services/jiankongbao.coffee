service = require '../service'

jkbUrl = 'https://qiye.jiankongbao.com'

_receiveWebhook = (req, res) ->
  {integration} = req

  if req.method is 'GET' then payload = req.query else payload = req.body

  {msg_id, task_id, task_type, fault_time, token, content} = payload

  if integration.token and
     crypto.createHash('md5').update("#{msg_id}#{task_id}#{fault_time}#{integration.token}").digest('hex') isnt token
    throw new Error("Invalid jiankongbao token #{token}, msg_id: #{msg_id}")

  unless task_type and task_id
    throw new Error('Invalid jiankongbao payload')

  message =
    _integrationId: integration._id
    quote:
      text: content
      redirectUrl: "#{jkbUrl}/task/#{task_type}/#{task_id}"

  @sendMessage message

module.exports = service.register 'jiankongbao', ->

  @title = '监控宝'

  @template = 'webhook'

  @summary = service.i18n
    zh: '端到端一体化云监控。'
    en: 'Jiankongbao is able to monitor website, servers, network, database, API, applications, performance, etc.'

  @description = service.i18n
    zh: '监控宝能够实时监控网站、服务器、网络、数据库、API、应用程序、页面性能等。为话题添加监控宝聚合后，你就可以在简聊上收取相关的告警通知。'
    en: 'Jiankongbao is able to monitor website, servers, network, database, API, applications, performance, etc. Add after Jiankongbao aggregation for a topic, you can catch up on Talk received the warning notice.'

  @iconUrl = service.static 'images/icons/jiankongbao@2x.png'

  @showToken = true

  @registerEvent 'webhook', _receiveWebhook
