Promise = require 'bluebird'
marked = require 'marked'

util = require '../util'

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

  message = integration: integration
  attachment = category: 'quote', data: {}

  projectName = if build.project_name then "[#{build.project_name}] " else ''
  projectUrl = build.build_url
  author = build.committer
  authorName = if author then "#{author} " else ''
  commitUrl = build.commit_url
  status = build.status

  switch status
    when 'testing'
      attachment.data.title = "#{projectName}new commits on testing stage"
    when 'success'
      attachment.data.title = "#{projectName}new commits on success stage"
    else return false

  attachment.data.text =
    """
    <a href="#{commitUrl}" target="_blank"><code>#{build.commit_id[...6]}:</code></a> #{build.message}<br>
    """
  attachment.data.redirectUrl = projectUrl
  message.attachments = [attachment]
  @sendMessage message

module.exports = ->
  @title = 'codeship'

  @template = 'webhook'

  @summary = util.i18n
    zh: '持续集成与部署平台'
    en: 'Codeship is a fast and secure hosted Continuous Delivery platform that scales with your needs.'

  @description = util.i18n
    zh: 'Codeship 是一个持续集成与部署平台，为你的代码提供一站式测试部署服务'
    en: 'Codeship is a fast and secure hosted Continuous Delivery platform that scales with your needs.'

  @iconUrl = util.static 'images/icons/codeship@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readOnly: true
    description: util.i18n
      zh: '复制 web hook 地址到你的 Codeship 当中使用。'
      en: 'Copy this web hook to your Codeship server to use it.'

  # Apply function on `webhook` event
  @registerEvent 'service.webhook', _receiveWebhook
