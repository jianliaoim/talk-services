service = require '../service'

module.exports = service.register 'rss', ->

  @title = 'RSS'

  @summary = service.i18n
    zh: '添加订阅地址，帮助你获取网站内容的最新更新。'
    en: 'RSS automatically syncs the latest site contents.'

  @description = service.i18n
    zh: '你可以为某一个话题添加来自其他网站的 RSS 订阅，这能够帮助你即时获取网站的最新内容。你可以在简聊上阅读来自 RSS 订阅的文章，甚至无需离开页面。'
    en: 'RSS automatically syncs the latest site contents. This integration allows you read RSS feed without leaving Talk.'

  @iconUrl = service.static('images/rss@2x.png')

  @setField 'url', onChange: 'checkRSS'
  @setField 'notification', type: 'text'

  @needCustomName false
  @needCustomDescription false
  @needCustomIcon false

  @registerApi 'checkRSS', (req, res, callback) ->

  @registerEvent 'integration.create'

  @registerEvent 'integration.remove'

  @registerEvent 'integration.update'
