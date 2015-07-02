service = require '../service'

_receiveWebhook = ({integration, body, headers}) ->
  try
    [type, action] = headers['x-event-key'].split(":")
  catch
    throw new Error('Invalid event format')
  throw new Error('Invalid event type') unless type in ['repo', 'issue', 'pullrequest']

  message =
    integration: integration
    quote: {}

  switch type
    when 'repo'
      throw new Error('Unsupported action') unless action in ['push', 'commit_comment_created']
      if action is 'push'
        message.quote.title = "A new push for project #{body.repository.name}"
        message.quote.text = "Committer: #{body.actor.display_name}"
        message.quote.redirectUrl = body.repository.links.html.href
      else if action is 'commit_comment_created'
        message.quote.title = "A new comment for #{body.repository.name}"
        message.quote.text = body.comment.content.raw
        message.quote.redirectUrl = body.comment.links.html.href

    when 'issue'
      throw new Error('Unsupported action') unless action in ['created', 'updated', 'comment_created']
      if action is 'created'
        message.quote.title = "#{body.actor.display_name} created an issue for project #{body.repository.full_name}"
        message.quote.text = body.issue.content.raw
        message.quote.redirectUrl = body.issue.links.html.href
      else if action is 'updated'
        message.quote.title = "#{body.actor.display_name} updated an issue for project #{body.repository.full_name}"
        message.quote.text = body.changes.content.new
        message.quote.redirectUrl = body.issue.links.html.href
      else if action is 'comment_created'
        message.quote.title = "#{body.actor.display_name} created a comment for project #{body.repository.full_name}"
        message.quote.text = body.comment.content.raw
        message.quote.redirectUrl = body.comment.links.html.href

    when 'pullrequest'
      throw new Error('Unsupported action') unless action in ['created', 'updated', 'comment_created', 'comment_deleted', 'fulfilled', 'rejected']
      if action is 'created'
        message.quote.title = "#{body.actor.display_name} created a pull request for #{body.repository.name}"
        message.quote.text = body.pullrequest.title
        message.quote.redirectUrl = body.pullrequest.links.html.href
      else if action is 'updated'
        message.quote.title = "#{body.actor.display_name} updated a pull request for #{body.repository.name}"
        message.quote.text = body.pullrequest.title
        message.quote.redirectUrl = body.pullrequest.links.html.href
      else if action is 'comment_created'
        message.quote.title = "#{body.actor.display_name} created a comment for pull request #{body.pullrequest.title}"
        message.quote.text = body.comment.pullrequest.title
        message.quote.redirectUrl = body.pullrequest.links.html.href
      else if action is 'comment_deleted'
        message.quote.title = "#{body.actor.display_name} deleted a comment for pull request #{body.pullrequest.title}"
        message.quote.text = body.comment.pullrequest.title
        message.quote.redirectUrl = body.pullrequest.links.html.href
      else if action is 'fulfilled'
        message.quote.title = "#{body.actor.display_name} fulfilled the pull request #{body.pullrequest.title}"
        message.quote.text = ""
        message.quote.redirectUrl = body.pullrequest.links.html.href
      else if action is 'rejected'
        message.quote.title = "#{body.actor.display_name} rejected the pull request #{body.pullrequest.title}"
        message.quote.text = ""
        message.quote.redirectUrl = body.pullrequest.links.html.href

  @sendMessage message

module.exports = service.register 'bitbucket', ->

  @title = 'Bitbucket'

  @template = 'webhook'

  @summary = service.i18n
    zh: '免费的代码托管服务'
    en: 'Free code management service.'

  @description = service.i18n
    zh: 'BitBucket 是一家采用Mercurial和Git作为分布式版本控制系统源代码托管云服务'
    en: 'Bitbucket is a Git and Mercurial based source code management and collaboration solution in the cloud.'

  @iconUrl = service.static 'images/icons/bitbucket@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readonly: true
    description: service.i18n
      zh: '复制 webhook 地址到 bitbucket.org 中使用'
      en: 'Copy this webhook to your bitbucket.org to use it.'

  @registerEvent 'service.webhook', _receiveWebhook
