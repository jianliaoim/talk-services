_ = require 'lodash'
Promise = require 'bluebird'

util = require '../util'

rssUrl = 'http://dev.gold.avosapps.com/jianliao/rss'

# 添加稀土掘金 Feed 为默认 Url
_addRSSUrl = ({integration}) ->
  integration.url = rssUrl
  return integration

module.exports = ->

  service = this

  @title = '稀土掘金日报'

  @template = 'form'

  @group = 'rss'

  @summary = util.i18n
    zh: '挖掘最优质的互联网技术'
    en: 'Digging the best of Internet technology'

  @description = util.i18n
    zh: '挖掘最优质的互联网技术'
    en: 'Digging the best of Internet technology'

  @iconUrl = util.static 'images/icons/goldxitudaily@2x.png'

  if process.env.NODE_ENV in ['ga', 'prod']
    @serviceUrl = 'http://apps.teambition.corp:7411'
  else
    @serviceUrl = 'http://localhost:7411'

  @registerEvent 'before.integration.create', _addRSSUrl

  events = ['integration.create', 'integration.remove', 'integration.update']

  events.forEach (event) ->
    service.registerEvent event, (req) ->
      service.httpPost service.serviceUrl,
        event: event
        data: req.integration
