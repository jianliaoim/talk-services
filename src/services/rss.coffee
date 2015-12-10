_ = require 'lodash'
request = require 'request'
Promise = require 'bluebird'
charset = require 'charset'
iconv = require 'iconv-lite'
jschardet = require 'jschardet'
FeedParser = require 'feedparser'
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
      headers: 'User-Agent': util.userAgent
      encoding: null
    , (err, res, body) ->
      unless res?.statusCode >= 200 and res?.statusCode < 300
        err = new Error("Invalid feed #{url}")
        err.status = 400
        err.phrase = 'INVALID_RSS_URL'
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

module.exports = ->

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

  if process.env.NODE_ENV in ['ga', 'prod']
    @serviceUrl = 'http://apps.teambition.corp:7411'
  else
    @serviceUrl = 'http://localhost:7411'

  @registerApi 'checkRSS', _checkRSS

  @registerEvents ['integration.create', 'integration.remove', 'integration.update']
