_ = require 'lodash'
marked = require 'marked'
util = require '../util'

_receiveWebhook = ({headers, body, integration}) ->
  event = headers['x-github-event']
  payload = body
  {sender, issue, action, comment, repository, forkee, head_commit, commits, pull_request} = payload

  message = {}
  attachment =
    category: 'quote'
    data:
      userName: sender.login
      userAvatarUrl: sender.avatar_url

  switch event
    when 'commit_comment'
      attachment.data.title = "#{repository.full_name} commit comment by #{sender?.login}"
      attachment.data.text = "#{marked(comment?.body or '')}"
      attachment.data.redirectUrl = comment?.html_url
    when 'create'
      attachment.data.title = "#{repository.full_name} #{payload.ref_type} #{payload.ref} created by #{sender?.login}"
      attachment.data.redirectUrl = repository?.html_url
    when 'delete'
      attachment.data.title = "#{repository.full_name} #{payload.ref_type} #{payload.ref} deleted by #{sender?.login}"
      attachment.data.redirectUrl = repository?.html_url
    when 'fork'
      attachment.data.title = "#{repository.full_name} forked to #{forkee?.full_name}"
      attachment.data.redirectUrl = forkee?.html_url
    when 'issue_comment'
      attachment.data.title = "#{repository.full_name} issue comment by #{sender?.login}"
      attachment.data.text = "#{marked(comment?.body or '')}"
      attachment.data.redirectUrl = comment?.html_url
    when 'issues'
      attachment.data.title = "#{repository.full_name} issue #{action or ''} #{issue?.title}"
      attachment.data.text = marked(issue?.body or '')
      attachment.data.redirectUrl = issue?.html_url
    when 'pull_request'
      attachment.data.title = "#{repository.full_name} pull request #{pull_request?.title}"
      attachment.data.text = marked(pull_request?.body or '')
      attachment.data.redirectUrl = pull_request?.html_url
    when 'pull_request_review_comment'
      attachment.data.title = "#{repository.full_name} review comment by #{sender?.login}"
      attachment.data.text = marked(comment?.body or '')
      attachment.data.redirectUrl = comment?.html_url
    when 'push'
      return false unless commits?.length
      attachment.data.title = "#{repository.full_name} commits to #{payload.ref}"
      commitArr = commits.map (commit) ->
        authorPrefix = if commit?.committer?.name then " [#{commit.committer.name}] " else " "
        """
        <a href="#{commit.url}" target="_blank"><code>#{commit?.id?[0...6]}:</code></a>#{authorPrefix}#{commit?.message}<br>
        """
      attachment.data.text = commitArr.join ''
      attachment.data.redirectUrl = head_commit.url
    else return false

  message.attachments = [attachment]
  message

module.exports = ->

  @title = 'GitHub Webhook'

  @template = 'webhook'

  @summary = util.i18n
    zh: '分布式的版本控制系统。'
    en: 'GitHub offers online source code hosting for Git projects.'

  @description = util.i18n
    zh: 'GitHub 是一个分布式的版本控制系统。选择一个话题添加 GitHub 聚合后，你就可以在被评论、创建或删除分支、仓库被 fork 等情形下收到简聊通知。'
    en: 'GitHub offers online source code hosting for Git projects. This integration allows you receive GitHub comments, pull request, etc. '

  @iconUrl = util.static 'images/icons/github@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readOnly: true
    description: util.i18n
      zh: '复制 web hook 地址到你的 github 当中使用。你也可以在管理界面当中找到这个 web hook 地址。'
      en: 'Copy this web hook to your github to use it. You may also find this url in the manager tab。'

  @registerEvent 'service.webhook', _receiveWebhook
