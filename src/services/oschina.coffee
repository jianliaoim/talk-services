# {
#   "headers": {
#     "x-real-ip": "124.202.141.60",
#     "x-forwarded-for": "124.202.141.60",
#     "host": "talk.ai",
#     "x-nginx-proxy": "true",
#     "connection": "Upgrade",
#     "content-length": "994",
#     "accept": "*/*; q=0.5, application/xml",
#     "accept-encoding": "gzip, deflate",
#     "content-type": "application/x-www-form-urlencoded",
#     "user-agent": "Ruby"
#   },
#   "query": {},
#   "body": {
#     "hook": {
#       "password": "tb123",
#       "push_data": {
#         "before": "fae5f9ec25e1424a733986c2ae0d241fd28556cc",
#         "after": "cdc6e27f9b156a9693cb05369cee6a5686dd8f43",
#         "ref": "master",
#         "user_id": 39550,
#         "user_name": "garrett",
#         "repository": {
#           "name": "webcnn",
#           "url": "git@git.oschina.net:344958185/webcnn.git",
#           "description": "webcnn",
#           "homepage": "http://git.oschina.net/344958185/webcnn"
#         },
#         "commits": [
#           {
#             "id": "cdc6e27f9b156a9693cb05369cee6a5686dd8f43",
#             "message": "updated readme",
#             "timestamp": "2015-07-01T10:14:51+08:00",
#             "url": "http://git.oschina.net/344958185/webcnn/commit/cdc6e27f9b156a9693cb05369cee6a5686dd8f43",
#             "author": {
#               "name": "garrett",
#               "email": "344958185@qq.com",
#               "time": "2015-07-01T10:14:51+08:00"
#             }
#           }
#         ],
#         "total_commits_count": 1
#       }
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
  payload = body?.hook?.push_data or null
  return unless payload

  message =
    integration: integration
    quote: {}

  projectName = if payload.repository?.name then "[#{payload.repository.name}] " else ''
  projectUrl = payload.repository?.homepage
  author = payload.commits[0]?.author?.name
  authorName = if author then "#{author} " else ''

  # Prepare to send the message
  if payload.before?[...6] is '000000'
    message.quote.title = "#{projectName}新建了分支 #{payload.ref}"
  else if payload.after?[...6] is '000000'
    message.quote.title = "#{projectName}删除了分支 #{payload.ref}"
  else
    message.quote.title = "#{projectName}提交了新的代码"
    if payload.commits?.length
      commitArr = payload.commits.map (commit) ->
        commitUrl = commit.url
        """
        <a href="#{commitUrl}" target="_blank"><code>#{commit.id[...6]}:</code></a> #{commit.message}<br>
        """
      text = commitArr.join ''
      message.quote.text = text
  message.quote.redirectUrl = projectUrl

  @sendMessage message

module.exports = service.register 'csdn', ->
  @title = 'oschina'

  @template = 'webhook'

  @summary = service.i18n
    zh: '中国最大的开源技术社区'
    en: "China's largest open source community"

  @description = service.i18n
    zh: '开源中国 www.oschina.net 是目前中国最大的开源技术社区。'
    en: ''

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
