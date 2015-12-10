util = require '../util'

_receiveWebhook = ({integration, body, headers}) ->
  payload = body or {}
  build = payload.build or {}
  project = payload.project or {}

  return unless build.state and project.name

  if integration.token and headers["X-Buildkite-Token"] isnt integration.token
    throw new Error('Invalid token')

  title = "[#{build.state}] " +
          "#{project.name} ##{build.number} " +
          "(#{build.branch} - #{build.commit?[0...7]}) by #{payload.sender?.name}"

  message =
    integration: integration
    attachments: [
      category: 'quote'
      data:
        title: title
        text: build.message
        redirectUrl: build.web_url
    ]

  @sendMessage message

module.exports = ->

  @title = 'Buildkite'

  @template = 'webhook'

  @summary = util.i18n
    zh: '持续集成服务'
    en: 'A continuous integration service.'

  @description = util.i18n
    zh: 'Buildkite 是一个在线的持续集成服务，用来构建及测试你的代码。'
    en: 'Buildkite is a continuous integration service.'

  @iconUrl = util.static 'images/icons/buildkite@2x.png'

  @_fields.push
    key: 'token'
    type: 'text'
    description: util.i18n
      zh: '可选'
      en: 'Optional'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readonly: true
    description: util.i18n
      zh: '复制 web hook 地址到 buildkite.com 中使用'
      en: 'Copy this web hook to your buildkite.com to use it.'

  @registerEvent 'service.webhook', _receiveWebhook
