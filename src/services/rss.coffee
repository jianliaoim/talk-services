_ = require 'lodash'
request = require 'request'
Promise = require 'bluebird'
charset = require 'charset'
iconv = require 'iconv-lite'
jschardet = require 'jschardet'
FeedParser = require 'feedparser'
Err = require 'err1st'
stream = require 'stream'
he = require 'he'

util = require '../util'

_checkRSS = (req, res) ->
  {url} = req.get()
  url = url.trim()

  new Promise (resolve, reject) ->
    request
      url: url
      method: 'GET'
      headers: 'User-Agent': util.getUserAgent()
      encoding: null
    , (err, res, body) ->
      unless res?.statusCode >= 200 and res?.statusCode < 300
        return reject new Error('Invalid feed')

      return reject(err) if err

      encoding = charset res.headers, body
      encoding = encoding or jschardet.detect(body)?.encoding?.toLowerCase() or 'utf-8'
      body = iconv.decode body, encoding

      return reject(new Error('Invalid feed')) unless body

      resolve(body)

  .then (body) ->
    new Promise (resolve, reject) ->
      feedParser = new FeedParser()
      readableStream = new stream.Readable()
      readableStream._read = ->

      feedParser
      .on 'error', reject
      .on 'meta', (meta) -> resolve meta

      readableStream.pipe feedParser
      readableStream.push body
      readableStream.push null

  .then (meta) ->
    data = {}
    ['title', 'description'].forEach (key) ->
      data[key] = he.decode(meta[key]) if meta[key]
    data

  .catch (err) -> throw new Err "INVALID_RSS_URL", url

module.exports = ->

  service = this

  @title = 'RSS'

  @summary = util.i18n
    zh: '添加订阅地址，帮助你获取网站内容的最新更新。'
    en: 'RSS automatically syncs the latest site contents.'

  @description = util.i18n
    zh: '你可以为某一个话题添加来自其他网站的 RSS 订阅，这能够帮助你即时获取网站的最新内容。你可以在简聊上阅读来自 RSS 订阅的文章，甚至无需离开页面。'
    en: 'RSS automatically syncs the latest site contents. This integration allows you read RSS feed without leaving Talk.'

  @iconUrl = util.static 'images/icons/rss@2x.png'

  @_fields.push
    key: 'url'
    onChange: 'checkRSS'

  @serviceUrl = util.config.rss.serviceUrl

  @registerApi 'checkRSS', _checkRSS

  events = ['integration.create', 'integration.remove', 'integration.update']

  events.forEach (event) ->
    service.registerEvent event, (req) ->
      service.httpPost service.serviceUrl,
        event: event
        data: req.integration
