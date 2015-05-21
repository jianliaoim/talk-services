service = require '../service'

_getEvents = ->
  [
    key: 'mention'
    label: service.i18n
      zh: '@我'
      en: '@me'
  ,
    key: 'repost'
    label: service.i18n
      zh: '转发'
      en: 'Repost'
  ,
    key: 'comment'
    label: service.i18n
      zh: '评论'
      en: 'Comment'
  ]

module.exports = service.register 'weibo', ->

  @title = '微博'

  @template = 'webhook'

  @summary = service.i18n
    zh: '通过关注机制分享简短实时信息的社交网络平台。'
    en: 'Weibo is one of the most popular social network in China.'

  @description = service.i18n
    zh: '微博是中国最流行的社交媒体平台之一。通过添加微博聚合，你可以设置将绑定账号的提及、转发和评论消息推送到你所选择的简聊话题中。'
    en: 'Weibo is one of the most popular social network in China. This integration allows you recieve mentions, reposts and replies.'

  @iconUrl = service.static('images/icons/weibo@2x.png')

  @serviceUrl = 'http://localhost:7410'

  @addField key: 'events', items: _getEvents.apply this

  @registerEvents ['integration.create', 'integration.remove', 'integration.update']
