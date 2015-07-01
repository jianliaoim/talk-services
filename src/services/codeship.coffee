# {
#   "headers": {
#     "x-real-ip": "54.91.114.69",
#     "x-forwarded-for": "54.91.114.69",
#     "host": "talk.ai",
#     "x-nginx-proxy": "true",
#     "connection": "Upgrade",
#     "content-length": "451",
#     "content-type": "application/json",
#     "user-agent": "Codeship Webhook",
#     "x-newrelic-id": "XQUEWVZACQQDVQ==",
#     "x-newrelic-transaction": "PxQFAF9RXVIDBVFSB1MAAFdXFB8EBw8RVU4aUFkBBldSVlhRAVFRVQIFUUNKQQlWVgEHUwUHFTs="
#   },
#   "query": {},
#   "body": {
#     "build": {
#       "build_url": "https://codeship.com/projects/88500/builds/6639402",
#       "commit_url": "https://github.com/lee715/easy-hotkey/commit/fda4ca3ee0a4d2d92b68a11c8cdc6d319fbe7c19",
#       "project_id": 88500,
#       "build_id": 6639402,
#       "status": "success",
#       "project_name": "lee715/easy-hotkey",
#       "project_full_name": "lee715/easy-hotkey",
#       "commit_id": "fda4ca3ee0a4d2d92b68a11c8cdc6d319fbe7c19",
#       "short_commit_id": "fda4c",
#       "message": "add new",
#       "committer": "lee715",
#       "branch": "master"
#     }
#   }
# }

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
      message.quote.title = "#{projectName}上有新的提交，处于testing阶段"
    when 'success'
      message.quote.title = "#{projectName}上有新的提交，处于success阶段"
  
  message.quote.text = 
    """
    <a href="#{commitUrl}" target="_blank"><code>#{build.commit_id[...6]}:</code></a> #{build.message}<br>
    """
  message.quote.redirectUrl = projectUrl

  @sendMessage message

module.exports = service.register 'csdn', ->
  @title = 'codeship'

  @template = 'webhook'

  @summary = service.i18n
    zh: ''
    en: 'Codeship is a fast and secure hosted Continuous Delivery platform that scales with your needs.'

  @description = service.i18n
    zh: ''
    en: 'Codeship is a fast and secure hosted Continuous Delivery platform that scales with your needs.'

  @iconUrl = service.static 'images/icons/csdn@2x.jpg'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readOnly: true
    description: service.i18n
      zh: '复制 web hook 地址到你的 Jenkins 当中使用。你也可以在管理界面当中找到这个 web hook 地址。'
      en: 'Copy this web hook to your Jenkins server to use it. You may also find this url in the manager tab.'

  # Apply function on `webhook` event
  @registerEvent 'service.webhook', _receiveWebhook
