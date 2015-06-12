crypto = require 'crypto'
service = require '../service'

jkbUrl = 'https://qiye.jiankongbao.com'

_receiveWebhook = ({integration, method, body, query}) ->
  if method is 'GET' then payload = query else payload = body
  {msg_id, task_id, task_type, fault_time, token, content} = payload

  if integration.token and
     crypto.createHash('md5').update("#{msg_id}#{task_id}#{fault_time}#{integration.token}").digest('hex') isnt token
    throw new Error("Invalid jiankongbao token #{token}, msg_id: #{msg_id}")

  unless task_type and task_id
    throw new Error('Invalid jiankongbao payload')

  message =
    integration: integration
    quote:
      text: decodeURIComponent content or ''
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

  @_fields.push
    key: 'token'
    type: 'text'
    description: service.i18n
      zh: '可选'
      en: 'Optional'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readonly: true
    description: service.i18n
      zh: '复制 web hook 地址到你的监控宝当中使用。你也可以在管理界面当中找到这个 web hook 地址。'
      en: 'Copy this web hook to your Jiankongbao to use it. You may also find this url in the manager tab.'

  @registerEvent 'service.webhook', _receiveWebhook
