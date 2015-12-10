Promise = require 'bluebird'
marked = require 'marked'

util = require '../util'

###*
 * Define handler when receive incoming webhook from csdn
 * @param  {Object}   req      Express request object
 * @param  {Object}   res      Express response object
 * @param  {Function} callback
 * @return {Promise}
###
_receiveWebhook = ({integration, body}) ->
  payload = body or null
  return unless payload

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
  message.attachments = [attachment]

  @sendMessage message

module.exports = ->
  @title = 'csdn'

  @template = 'webhook'

  @summary = util.i18n
    zh: '全球最大中文IT社区'
    en: "The world's largest Chinese IT community"

  @description = util.i18n
    zh: 'CSDN 是中国最大的IT社区和服务平台，为中国的软件开发者和IT从业者提供知识传播、职业发展、软件开发等全生命周期服务'
    en: "CSDN is China's largest IT community and service platform to provide knowledge dissemination for the Chinese software developers and IT practitioners, professional development , software development lifecycle services."

  @iconUrl = util.static 'images/icons/csdn@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readOnly: true
    description: util.i18n
      zh: '复制 web hook 地址到你的 csdn 当中使用。'
      en: 'Copy this web hook to your csdn server to use it.'

  # Apply function on `webhook` event
  @registerEvent 'service.webhook', _receiveWebhook
