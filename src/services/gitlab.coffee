Promise = require 'bluebird'
service = require '../service'

module.exports = service.register 'gitlab', ->
  @title = 'GitLab'

  @summary = service.i18n
    zh: '用于仓库管理系统的开源项目。'
    en: 'GitLab is a web-based Git repository manager with wiki and issue tracking features.'

  @description = service.i18n
    zh: 'GitLab 是一个用于仓库管理系统的开源项目，添加后可以收到来自 GitLab 的推送。'
    en: 'GitLab is a software repository manager. You may connect webhooks of GitLab repos.'

  @iconUrl = service.static('images/icons/gitlab@2x.png')

  @setField 'url', type: 'text', readOnly: true, autoGen: true

  # Apply function on `webhook` event
  @registerEvent 'webhook', _receiveWebhook

###*
 * Define handler when receive incoming webhook from gitlab
 * @param  {Object}   req      Express request object
 * @param  {Object}   res      Express response object
 * @param  {Function} callback
 * @return {Promise}
###
_receiveWebhook = (req, res, callback) ->
  # Wrap the handler with promise
  # The errors should be catched and transmit to callback
  Promise.resolve()

  .then ->

    # Use components from talkai service
    {redis, limbo} = service.components
    {MessageModel} = limbo.use 'talk'
    # Load robot from service
    {robot} = this
    {integration} = req.get()

    payload = req.body

    switch payload.object_kind
      when 'merge_request' then payload.event = 'merge_request'
      when 'issue' then payload.event = 'issues'
      else payload.event = 'push'

    {repository, commits, object_attributes} = payload

    commits or= []

    message = new MessageModel
      _creatorId: robot._id
      _integrationId: integration._id

    message.quote = title: "New event from gitlab: #{payload.event}"

    switch payload.event
      when 'push'
        message.quote.text = """
        <a href="#{repository?.homepage}" target="_blank">#{repository?.name}</a>
        """
        if payload.before is '0000000000000000000000000000000000000000'
          message.quote.text += " create branch #{payload.ref}<br>"
        else if payload.after is '0000000000000000000000000000000000000000'
          message.quote.text += " remove branch #{payload.ref}<br>"
        else
          message.quote.text += " new commits<br>"
        commitArr = commits.map (commit) ->
          commitUrl = util.attachFromUrl commit.url
          """
          <a href="#{commitUrl}" target="_blank"><code>#{commit?.id?[0...6]}:</code></a> #{commit?.message}<br>
          """
        message.quote.text += commitArr.join ''
        message.quote.redirectUrl = repository?.homepage
      when 'merge_request'
        message.quote.text = """
        <a href="#{object_attributes?.last_commit?.url}" target="_blank">#{object_attributes?.title}</a> [#{object_attributes?.state}]<br>
        #{marked(object_attributes?.description or '')}
        """
      when 'issues'
        message.quote.text = """
        <a href="#{object_attributes?.url}" target="_blank">#{object_attributes?.title}</a> [#{object_attributes?.state}]<br>
        #{marked(object_attributes?.description or '')}
        """

    lockKey = "lock:gitlab:#{integration._roomId}:#{integration._teamId}:#{integration._id}:#{payload.event}"

    redis.multi()
    .getset lockKey, 1
    .expire lockKey, 20  # Do not resave in 2 seconds
    .exec (err, [isLocked]) ->
      return if isLocked
      message.save()

  .then -> callback null, ok: 1

  .catch callback
