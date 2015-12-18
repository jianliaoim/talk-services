util = require '../util'

_receiveWebhook = ({body, headers}) ->
  try
    [type, action] = headers['x-event-key'].split(":")
  catch
    throw new Error('Invalid event format')
  throw new Error('Invalid event type') unless type in ['repo', 'issue', 'pullrequest']

  message = {}
  attachment = category: 'quote', data: {}

  switch type
    when 'repo'
      throw new Error('Unsupported action') unless action in ['push', 'commit_comment_created']
      if action is 'push'
        attachment.data.title = "A new push for project #{body.repository.name}"
        attachment.data.text = "Committer: #{body.actor.display_name}"
        attachment.data.redirectUrl = body.repository.links.html.href
      else if action is 'commit_comment_created'
        attachment.data.title = "A new comment for #{body.repository.name}"
        attachment.data.text = body.comment.content.raw
        attachment.data.redirectUrl = body.comment.links.html.href

    when 'issue'
      throw new Error('Unsupported action') unless action in ['created', 'updated', 'comment_created']
      if action is 'created'
        attachment.data.title = "#{body.actor.display_name} created an issue for project #{body.repository.full_name}"
        attachment.data.text = body.issue.content.raw
        attachment.data.redirectUrl = body.issue.links.html.href
      else if action is 'updated'
        attachment.data.title = "#{body.actor.display_name} updated an issue for project #{body.repository.full_name}"
        attachment.data.text = body.changes.content.new
        attachment.data.redirectUrl = body.issue.links.html.href
      else if action is 'comment_created'
        attachment.data.title = "#{body.actor.display_name} created a comment for project #{body.repository.full_name}"
        attachment.data.text = body.comment.content.raw
        attachment.data.redirectUrl = body.comment.links.html.href

    when 'pullrequest'
      throw new Error('Unsupported action') unless action in ['created', 'updated', 'comment_created', 'comment_deleted', 'fulfilled', 'rejected']
      if action is 'created'
        attachment.data.title = "#{body.actor.display_name} created a pull request for #{body.repository.name}"
        attachment.data.text = body.pullrequest.title
        attachment.data.redirectUrl = body.pullrequest.links.html.href
      else if action is 'updated'
        attachment.data.title = "#{body.actor.display_name} updated a pull request for #{body.repository.name}"
        attachment.data.text = body.pullrequest.title
        attachment.data.redirectUrl = body.pullrequest.links.html.href
      else if action is 'comment_created'
        attachment.data.title = "#{body.actor.display_name} created a comment for pull request #{body.pullrequest.title}"
        attachment.data.text = body.comment.pullrequest.title
        attachment.data.redirectUrl = body.pullrequest.links.html.href
      else if action is 'comment_deleted'
        attachment.data.title = "#{body.actor.display_name} deleted a comment for pull request #{body.pullrequest.title}"
        attachment.data.text = body.comment.pullrequest.title
        attachment.data.redirectUrl = body.pullrequest.links.html.href
      else if action is 'fulfilled'
        attachment.data.title = "#{body.actor.display_name} fulfilled the pull request #{body.pullrequest.title}"
        attachment.data.text = ""
        attachment.data.redirectUrl = body.pullrequest.links.html.href
      else if action is 'rejected'
        attachment.data.title = "#{body.actor.display_name} rejected the pull request #{body.pullrequest.title}"
        attachment.data.text = ""
        attachment.data.redirectUrl = body.pullrequest.links.html.href

  message.attachments = [attachment]
  message

module.exports = ->

  @title = 'Bitbucket'

  @template = 'webhook'

  @summary = util.i18n
    zh: '免费的代码托管服务'
    en: 'Free code management service.'

  @description = util.i18n
    zh: 'BitBucket 是一家采用Mercurial和Git作为分布式版本控制系统源代码托管云服务'
    en: 'Bitbucket is a Git and Mercurial based source code management and collaboration solution in the cloud.'

  @iconUrl = util.static 'images/icons/bitbucket@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readonly: true
    description: util.i18n
      zh: '复制 webhook 地址到 bitbucket.org 中使用'
      en: 'Copy this webhook to your bitbucket.org to use it.'

  @registerEvent 'service.webhook', _receiveWebhook
