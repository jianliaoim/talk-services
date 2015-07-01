# {
#   "headers": {
#     "x-real-ip": "42.121.112.219",
#     "x-forwarded-for": "42.121.112.219",
#     "host": "talk.ai",
#     "x-nginx-proxy": "true",
#     "connection": "Upgrade",
#     "content-length": "1128",
#     "content-type": "application/json"
#   },
#   "query": {},
#   "body": {
#     "before": "5dff974d0fb8cbfd8d8c063050866e0e6593ea70",
#     "after": "59acbad155b77f3d03412094aab3877a1ff2887c",
#     "ref": "refs/heads/master",
#     "commits": [
#       {
#         "id": "59acbad155b77f3d03412094aab3877a1ff2887c",
#         "message": "c\n",
#         "timestamp": "2015-06-30T11:24:48+08:00",
#         "url": "https://code.csdn.net/white715/webcnn/commit/59acbad155b77f3d03412094aab3877a1ff2887c",
#         "author": {
#           "name": "lee715",
#           "email": "li.l@huiyi-tech.com"
#         }
#       },
#       {
#         "id": "e32a60eccbb10f434ed498c0a9b77f366e91a8dc",
#         "message": "b\n",
#         "timestamp": "2015-06-30T11:24:41+08:00",
#         "url": "https://code.csdn.net/white715/webcnn/commit/e32a60eccbb10f434ed498c0a9b77f366e91a8dc",
#         "author": {
#           "name": "lee715",
#           "email": "li.l@huiyi-tech.com"
#         }
#       },
#       {
#         "id": "a2938248b1fe94b173815636cd0ec756a526018e",
#         "message": "a\n",
#         "timestamp": "2015-06-30T11:24:31+08:00",
#         "url": "https://code.csdn.net/white715/webcnn/commit/a2938248b1fe94b173815636cd0ec756a526018e",
#         "author": {
#           "name": "lee715",
#           "email": "li.l@huiyi-tech.com"
#         }
#       }
#     ],
#     "user_id": 134214,
#     "user_name": "white715",
#     "repository": {
#       "name": "webcnn",
#       "url": "git@code.csdn.net:white715/webcnn.git",
#       "description": "webcnn",
#       "homepage": "https://code.csdn.net/white715/webcnn"
#     },
#     "total_commits_count": 3
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
  payload = body or null
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
  @title = 'Csdn'

  @template = 'webhook'

  @summary = service.i18n
    zh: '全球最大中文IT社区'
    en: ''

  @description = service.i18n
    zh: 'csdn是中国最大的IT社区和服务平台，为中国的软件开发者和IT从业者提供知识传播、职业发展、软件开发等全生命周期服务'
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
