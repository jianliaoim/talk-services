_ = require 'lodash'

util = require '../util'

_receiveWebhook = ({integration, body}) ->
  payload = body

  return integration.token unless payload.resource

  title = ''
  resource = payload.resource.replace(/(')|(u\')/g, '"')
  resource_json = JSON.parse resource

  rules = payload.rules.replace(/'/g, '"')
  rules_json = JSON.parse rules

  if resource_json.resource_name isnt ''
    title += "QingCloud: #{resource_json.resource_id} #{resource_json.resource_name} #{resource_json.resource_type}"
  else
    title += "QingCloud: #{resource_json.resource_id} #{resource_json.resource_type}"

  text = []
  _.forIn rules_json, (rule) ->
    if rule.alarm_policy_rule_name isnt ''
      text.push "RULE_ID: #{rule.alarm_policy_rule_id} RULE_NAME: #{rule.alarm_policy_rule_name} STATUS: #{rule.status}"
    else
      text.push "RULE_ID: #{rule.alarm_policy_rule_id} STATUS: #{rule.status}"

  text = text.join '\n'

  message =
    attachments: [
      category: 'quote'
      data:
        title: title
        text: text
    ]

  message

module.exports = ->

  @title = '青云'

  @template = 'webhook'

  @summary = util.i18n
    zh: '基础设施即服务(IaaS)云平台'
    en: 'IaaS Cloud Platform'

  @description = util.i18n
    zh: '青云 QingCloud 可在秒级时间内获取计算资源，并通过 SDN 实现虚拟路由器和交换机功能，为您提供按需分配、弹性可伸缩的计算及组网能力。在基础设施层提供完整的云化解决方案。'
    en: 'QingCloud can acquire the computing resource within the second time, realize the function of virtual router and switch, and provide the distribution according to demands, the flexible calculation and networking ability.'

  @iconUrl = util.static 'images/icons/qingcloud@2x.png'

  @_fields.push
    key: 'token'
    type: 'text'
    description: util.i18n
      zh: '第一次添加聚合时必填'
      en: 'Required for creating a integration'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readonly: true
    description: util.i18n
      zh: '复制 web hook 地址到你的青云中使用。'
      en: 'Copy this web hook to your Qing Cloud account to use it.'

  @registerEvent 'service.webhook', _receiveWebhook
