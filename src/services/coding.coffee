service = require '../service'
Moment = require 'moment'

_receiveWebhook = ({integration, body, headers}) ->
  payload = body
  event = headers["x-coding-event"]

  # When the token of integration is settled
  # Compare it with the payload.token
  if integration.token and integration.token isnt payload.token
    throw new Error("Invalid token")

  message =
    _integrationId: integration._id
    quote: {}


  switch event
    when 'push'
      # Prepare to send the message
      if payload.before?[...6] is '000000'
        message.quote.title = "项目 #{payload.repository.name} 中新建了分支 #{payload.ref}"
      else if payload.after?[...6] is '000000'
        message.quote.title = "项目 #{payload.repository.name} 中删除了分支 #{payload.ref}"
      else
        message.quote.title = "项目 #{payload.repository.name} 中提交了新的代码"
        if payload.commits?.length
          commitArr = payload.commits.map (commit) ->
            commitUrl = "#{payload.repository.web_url}/git/commit/#{commit.sha}"
            """
            <a href="#{commitUrl}" target="_blank"><code>#{commit.sha[...6]}:</code></a> #{commit.short_message}<br>
            """
          text = commitArr.join ''
          message.quote.text = text
      message.quote.redirectUrl = payload.repository.web_url
    when 'member'
      switch payload.action
        when 'create'
          message.quote.title = "项目 #{payload.repository.name} 中添加了新的成员 #{payload.target_user.name}"
          message.quote.redirectUrl = "#{payload.repository.web_url}/members/#{payload.target_user.global_key}"
        else return false
    when 'task'
      message.quote.redirectUrl = "#{payload.repository.web_url}/tasks"
      switch payload.action
        when 'create'
          message.quote.title = "项目 #{payload.repository.name} 中添加了新的任务"
          message.quote.text = payload.task.content
        when 'update_deadline'
          message.quote.title = "项目 #{payload.repository.name} 中更新了任务的截止日期 #{Moment(payload.task.deadline).format('YYYY-MM-DD')}"
          message.quote.text = payload.task.content
        when 'update_priority'
          prioritys = ['有空再看', '正常处理', '优先处理', '十万火急']
          message.quote.title = "项目 #{payload.repository.name} 中更新了任务的优先级 #{prioritys[payload.task.priority] or ''}"
          message.quote.text = payload.task.content
        else return false
    else return false

  @sendMessage message

# Register the coding service
module.exports = service.register 'coding', ->

  @title = 'Coding'

  @template = 'webhook'

  @summary = service.i18n
    en: 'Coding.net is a developer-oriented cloud development platform, provides a running space, quality control, providing code hosting, project management, and other functions.'
    zh: '面向开发者的云端开发平台。'

  @description = service.i18n
    en: "Coding.net is a developer-oriented cloud development platform, provides a running space, quality control, providing code hosting, project management, and other functions. When you Git version of the repository on the Coding.net when there is a new Push, you'll catch up on Talk received this Push on and information about the repository."
    zh: 'Coding.net 是面向开发者的云端开发平台，提供了提供代码托管、运行空间、质量控制、项目管理等功能。当您在 Coding.net 上的 Git 版本仓库有新的 Push 的时候，你会在简聊上收到本次 Push 以及本仓库的相关信息。'

  @iconUrl = service.static 'images/icons/coding@2x.png'

  @setField 'url', type: 'text', readOnly: true, autoGen: true

  @registerEvent 'service.webhook', _receiveWebhook
