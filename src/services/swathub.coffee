_ = require 'lodash'
service = require '../service'

_receiveWebhook = ({integration, query, body}) ->
  payload = _.assign {}
    , query or {}
    , body or {}

  {
    content
    authorName
    title
    text
    redirectUrl
    imageUrl
  } = payload

  throw new Error("Title and text can not be empty") unless title?.length or text?.length or content?.length

  message =
    integration: integration
    body: content
    attachments: [
      category: 'quote'
      data:
        authorName: authorName
        title: title
        text: text
        redirectUrl: redirectUrl
        imageUrl: imageUrl
    ]

  @sendMessage message

module.exports = service.register 'swathub', ->

  @title = 'SWATHub'

  @template = 'webhook'

  @summary = service.i18n
    zh: '简单、高效的云端自动化测试平台。'
    en: 'Simple and Efficient Test Automation on Cloud'

  @description = service.i18n
    zh: '无需学习任何编程语言，SWATHub让你在云端快速创建和实施自动化测试。添加SWATHub聚合服务之后，你可以在简聊中收取自动化测试的状态信息和结果报告。'
    en: 'SWATHub enables building automated test scenarios on cloud in a code-less way. You can receive the test automation status messages, and execution reports in Talk.ai, by means of this SWATHub integration.'

  @iconUrl = service.static 'images/icons/swathub@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readOnly: true
    description: service.i18n
      zh: 'Webhook url'
      en: 'Webhook url'

  @registerEvent 'service.webhook', _receiveWebhook
