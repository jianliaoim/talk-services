util = require '../util'

_receiveWebhook = ({body}) ->
  payload = body

  message = {}
  attachment = category: 'quote', data: {}

  JIRA_CREATE_EVENT = "jira:issue_created"
  JIRA_UPDATE_EVENT = "jira:issue_updated"

  if body.webhookEvent is JIRA_CREATE_EVENT
    attachment.data.title = "#{body.user.displayName} created an issue for project #{body.issue.fields.project.name}"
    attachment.data.text = "Summary: #{body.issue.fields.summary}"
  else if body.webhookEvent is JIRA_UPDATE_EVENT
    attachment.data.title = "#{body.user.displayName} updated an issue for project #{body.issue.fields.project.name}"
    attachment.data.text = "Summary: #{body.issue.fields.summary}"
  else
    throw new Error("Unknown Jira event type")

  message.attachments = [attachment]
  message

module.exports = ->

  @title = 'Jira'

  @template = 'webhook'

  @summary = util.i18n
    zh: '项目管理和事务追踪'
    en: 'The flexible and scalable issue tracker for software teams.'

  @description = util.i18n
    zh: 'JIRA是Atlassian公司出品的项目与事务跟踪工具，被广泛应用于缺陷跟踪、客户服务、需求收集、流程审批、任务跟踪、项目跟踪和敏捷管理等工作领域。'
    en: 'Track and manage everything with JIRA project and issue tracking software by Atlassian.'

  @iconUrl = util.static 'images/icons/jira@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readonly: true
    description: util.i18n
      zh: '复制 webhook 地址到你的 Jira 的项目配置当中使用。'
      en: 'Copy this webhook to your Jira project setting to use it.'

  @registerEvent 'service.webhook', _receiveWebhook
