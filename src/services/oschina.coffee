Promise = require 'bluebird'
marked = require 'marked'
service = require '../service'

###*
 * Define handler when receive incoming webhook from oschina
 * @param  {Object}   req      Express request object
 * @param  {Object}   res      Express response object
 * @param  {Function} callback
 * @return {Promise}
###
_receiveWebhook = ({integration, body}) ->
  payloadStr = body?.hook or null
  return unless payloadStr

  try
    payload = JSON.parse(payloadStr).push_data
  catch e
    return

  message = integration: integration
  attachment = category: 'quote', data: {}

  projectName = if payload.repository?.name then "[#{payload.repository.name}] " else ''
  projectUrl = payload.repository?.homepage
  author = payload.commits[0]?.author?.name
  authorName = if author then "#{author} " else ''

  # Prepare to send the message
  if payload.before?[...6] is '000000'
    attachment.data.title = "#{projectName}新建了分支 #{payload.ref}"
  else if payload.after?[...6] is '000000'
    attachment.data.title = "#{projectName}删除了分支 #{payload.ref}"
  else
    attachment.data.title = "#{projectName}提交了新的代码"
    if payload.commits?.length
      commitArr = payload.commits.map (commit) ->
        commitUrl = commit.url
        """
        <a href="#{commitUrl}" target="_blank"><code>#{commit.id[...6]}:</code></a> #{commit.message}<br>
        """
      text = commitArr.join ''
      attachment.data.text = text
  attachment.data.redirectUrl = projectUrl
  attachment.data.category = 'oschina'
  message.attachments = [attachment]
  @sendMessage message

module.exports = service.register 'oschina', ->
  @title = 'oschina'

  @template = 'webhook'

  @summary = service.i18n
    zh: '中国最大的开源技术社区'
    en: "China's largest open source community"

  @description = service.i18n
    zh: '开源中国 www.oschina.net 是目前中国最大的开源技术社区。'
    en: 'www.oschina.net is the largest open source community in china now.'

  @iconUrl = service.static 'images/icons/oschina@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readOnly: true
    description: service.i18n
      zh: '复制 web hook 地址到你的 oschina 当中使用。'
      en: 'Copy this web hook to your oschina server to use it. '

  # Apply function on `webhook` event
  @registerEvent 'service.webhook', _receiveWebhook
