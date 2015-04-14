Promise = require 'bluebird'
service = require '../service'

_receiveWebhook = (req, res, callback) ->
  {integration} = req.get()
  payload = req.body

  # When the token of integration is settled
  # Compare it with the payload.token
  if integration.token and integration.token isnt payload.token
    return callback(new Error("Invalid token"))

  # Prepare to send the message
  if payload.before?[...6] is '000000'
    text = "在项目 #{payload.repository.name} 中新建分支 #{payload.ref}"
  else if payload.after?[...6] is '000000'
    text = "在项目 #{payload.repository.name} 中删除分支 #{payload.ref}"
  else
    text = "在项目 #{payload.repository.name} 中提交了新的代码<br>"
    if payload.commits?.length
      commitArr = payload.commits.map (commit) ->
        commitUrl = "#{payload.repository.url}/commit/#{commit.sha}"
        """
        <a href="#{commitUrl}" target="_blank">
        <code>#{commit.sha[...6]}:</code></a> #{commit.short_message}<br>
        """
      text += commitArr.join ''

  message =
    quote:
      title: "来自 Coding 的事件"
      text: text
      redirectUrl: payload.repository.url

  @sendMessage message, callback

# Register the coding service
module.exports = service.register 'coding', ->

  @title = 'Coding'

  @template = ''

  @summary = service.i18n
    en: 'Coding.net is a developer-oriented cloud development platform, provides a running space, quality control, providing code hosting, project management, and other functions.'
    zh: '面向开发者的云端开发平台。'

  @description = service.i18n
    en: "Coding.net is a developer-oriented cloud development platform, provides a running space, quality control, providing code hosting, project management, and other functions. When you Git version of the repository on the Coding.net when there is a new Push, you'll catch up on Talk received this Push on and information about the repository."
    zh: 'Coding.net 是面向开发者的云端开发平台，提供了提供代码托管、运行空间、质量控制、项目管理等功能。当您在 Coding.net 上的 Git 版本仓库有新的 Push 的时候，你会在简聊上收到本次 Push 以及本仓库的相关信息。'

  @iconUrl = service.static('images/icons/coding@2x.png')

  @setField 'url', type: 'text', readOnly: true, autoGen: true

  @registerEvent 'webhook', _receiveWebhook
