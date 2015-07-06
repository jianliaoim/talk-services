service = require '../service'

_receiveWebhook = ({integration, body}) ->
  payload = body

  message =
    integration: integration
    quote: {}

  JIRA_CREATE_EVENT = "jira:issue_created"
  JIRA_UPDATE_EVENT = "jira:issue_updated"

  if body.webhookEvent is JIRA_CREATE_EVENT
    message.quote.title = "#{body.user.displayName} created an issue for project #{body.issue.fields.project.name}"
    message.quote.text = "Summary: #{body.issue.fields.summary}"
  else if body.webhookEvent is JIRA_UPDATE_EVENT
    message.quote.title = "#{body.user.displayName} updated an issue for project #{body.issue.fields.project.name}"
    message.quote.text = "Summary: #{body.issue.fields.summary}"
  else
    throw new Error("Unknown Jira event type")

  @sendMessage message

module.exports = service.register 'jira', ->

  @title = 'Jira'

  @template = 'webhook'

  @summary = service.i18n
    zh: '项目管理和事务追踪'
    en: 'The flexible and scalable issue tracker for software teams.'

  @description = service.i18n
    zh: 'JIRA是Atlassian公司出品的项目与事务跟踪工具，被广泛应用于缺陷跟踪、客户服务、需求收集、流程审批、任务跟踪、项目跟踪和敏捷管理等工作领域。'
    en: 'Track and manage everything with JIRA project and issue tracking software by Atlassian.'

  @iconUrl = service.static 'images/icons/jira@2x.jpg'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readonly: true
    description: service.i18n
      zh: '复制 webhook 地址到你的 Jira 的项目配置当中使用。'
      en: 'Copy this webhook to your Jira project setting to use it.'

  @registerEvent 'service.webhook', _receiveWebhook
