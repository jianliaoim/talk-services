Promise = require 'bluebird'
marked = require 'marked'
service = require '../service'

###*
 * Define handler when receive incoming webhook from gitlab
 * @param  {Object}   req      Express request object
 * @param  {Object}   res      Express response object
 * @param  {Function} callback
 * @return {Promise}
###
_receiveWebhook = ({integration, body, headers}) ->
  # The errors should be catched and transmit to callback
  self = this
  throw new Error("Unknown GitCafe event type") unless headers and headers['x-gitcafe-event']

  message = integration: integration

  message.quote = {}

  switch headers['x-gitcafe-event']
    when 'commit_comment'
      message.quote.title = "#{body.comment.sender.username} 评论了提交 #{body.commit.message_subject}"
      message.quote.text = "#{marked(body.comment.content)}"
      message.quote.redirectUrl = "#{body.project.html_url}/commit/#{body.commit.sha}#comment-#{body.comment.id}"

    when 'pull_request'
      message.quote.title = "#{body.sender.username} 向 #{body.pull_request.head_project.name} 项目发起了 Pull Request 请求"
      message.quote.text = "#{marked(body.pull_request.subject or '')} (#{marked(body.pull_request.content or '')})"
      message.quote.redirectUrl = "#{body.pull_request.head_project.html_url}/pull/#{body.pull_request.number}"

    when 'pull_request_comment'
      message.quote.title = "#{body.comment.sender.username} 评论了 #{body.pull_request.head_project.name} 项目的 Pull Request 请求"
      message.quote.text = "#{marked(body.comment.content or '')}"
      message.quote.redirectUrl = "#{body.project.html_url}/pull/#{body.pull_request.number}#comment-#{body.comment.id}"

    when 'push'
      message.quote.title = "#{body.sender.username} 向 #{body.project.name} 项目提交了代码"
      if body.commits?.length
        commitArr = body.commits.map (commit) ->
          commitUrl = "#{body.project.html_url}/commit/#{commit.sha}"
          """
          <a href="#{commitUrl}" target="_blank"><code>#{commit.sha[...6]}:</code></a> #{commit.message_subject}<br>
          """
        text = commitArr.join ''
      message.quote.text = text
      message.quote.redirectUrl = "#{body.project.html_url}/commits/#{body.project.default_branch}"

    when 'ticket'
      message.quote.title = "#{body.sender.username} 在 #{body.project.name} 项目创建了工单"
      message.quote.text = "#{marked(body.ticket.subject or '')} (#{marked(body.ticket.content or '')})"
      message.quote.redirectUrl = body.ticket.html_url

    when 'ticket_comment'
      message.quote.title = "#{body.comment.sender.username} 评论了工单 #{body.ticket.subject}"
      message.quote.text = "#{marked(body.comment.content)}"
      message.quote.redirectUrl = "#{body.ticket.html_url}#comment-#{body.comment.id}"

    else return false

  self.sendMessage message

module.exports = service.register 'gitcafe', ->
  @title = 'GitCafe'

  @template = 'webhook'

  @summary = service.i18n
    zh: 'GitCafe 是一个基于 git 的在线托管软件项目的服务平台。'
    en: 'GitCafe is a source code hosting service based on version control system Git.'

  @description = service.i18n
    zh: 'GitCafe 是一个基于 git 的在线托管软件项目的服务平台。'
    en: 'GitCafe is a source code hosting service based on version control system Git.'

  @iconUrl = service.static 'images/icons/gitlcafe@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readOnly: true
    description: service.i18n
      zh: '复制 web hook 地址到你的 GitCafe 仓库当中使用。你也可以在管理界面当中找到这个 web hook 地址。'
      en: 'Copy this web hook to your GitCafe repo to use it. You may also find this url in the manager tab.'

  # Apply function on `webhook` event
  @registerEvent 'service.webhook', _receiveWebhook
