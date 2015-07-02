Promise = require 'bluebird'
marked = require 'marked'
service = require '../service'

###*
 * Define handler when receive incoming webhook from jenkins
 * @param  {Object}   req      Express request object
 * @param  {Object}   res      Express response object
 * @param  {Function} callback
 * @return {Promise}
###
_receiveWebhook = ({integration, body}) ->
  build = body?.build
  return unless build

  message =
    integration: integration
    quote: {}

  projectName = if build.project_name then "[#{build.project_name}] " else ''
  projectUrl = build.build_url
  author = build.committer
  authorName = if author then "#{author} " else ''
  commitUrl = build.commit_url
  status = build.status

  switch status
    when 'testing'
      message.quote.title = "#{projectName}new commits on testing stage"
    when 'success'
      message.quote.title = "#{projectName}new commits on success stage"
    else return false

  message.quote.text =
    """
    <a href="#{commitUrl}" target="_blank"><code>#{build.commit_id[...6]}:</code></a> #{build.message}<br>
    """
  message.quote.redirectUrl = projectUrl

  @sendMessage message

module.exports = service.register 'codeship', ->
  @title = 'codeship'

  @template = 'webhook'

  @summary = service.i18n
    zh: '持续集成与部署平台'
    en: 'Codeship is a fast and secure hosted Continuous Delivery platform that scales with your needs.'

  @description = service.i18n
    zh: 'Codeship 是一个持续集成与部署平台，为你的代码提供一站式测试部署服务'
    en: 'Codeship is a fast and secure hosted Continuous Delivery platform that scales with your needs.'

  @iconUrl = service.static 'images/icons/codeship@2x.jpg'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readOnly: true
    description: service.i18n
      zh: '复制 web hook 地址到你的 Codeship 当中使用。'
      en: 'Copy this web hook to your Codeship server to use it.'

  # Apply function on `webhook` event
  @registerEvent 'service.webhook', _receiveWebhook
