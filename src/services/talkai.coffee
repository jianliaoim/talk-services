service = require '../service'
qs = require 'qs'
Promise = require 'bluebird'
request = require 'request'
requestAsync = Promise.promisify request

_sendToRobot = (message) ->

  self = this

  return unless talkai.config.apikey and talkai.config.devid

  _getTuringCallback message

  .catch (err) ->
    return # Mute

  .then (body) ->
    return unless body?.content or body?.text or body?.title
    ['content', 'title', 'text'].forEach (key) ->
      return unless body[key]
      body[key] = body[key].replace? /图灵机器人/g, '小艾'
    replyMessage =
      _creatorId: self.robot._id
      _teamId: message._teamId
      _toId: message._creatorId
    replyMessage.content = body.content if body.content
    if body.text or body.title
      replyMessage.quote = body
      replyMessage.quote.category = 'talkai'
    self.sendMessage replyMessage

_errorHandler = (req) ->
  code = parseInt(req.code)
  return talkai.config.errorCodes[req.code]

_getTuringCallback = (message) ->

  query =
    key: talkai.config.apikey
    info: message.content

  requestAsync
    method: 'GET'
    url: "#{talkai.config.url}?#{qs.stringify(query)}"
    timeout: 20000
  .spread (res, resp) ->
    unless res.statusCode >= 200 and res.statusCode < 300
      throw new Error("bad request #{res.statusCode}")
    data = JSON.parse resp
    if data.code.toString() in Object.keys talkai.config.errorCodes
      throw new Error("bad response from Tuling123.com: #{_errorHandler(data)}")
    body = {}
    switch data.code
      when talkai.config.textCode
        re = new RegExp(/<br>/g)
        body.content = data.text.replace re, "\n"
      when talkai.config.urlCode
        body.title = data.text
        body.redirectUrl = data.url
      when talkai.config.newsCode
        body.title = data.text
        body.text = "<ul>"
        data.list.forEach (el) ->
          body.text += "<li><a href=" + el.detailurl + ">#{el.article}</a></li>"
        body.text += "</ul>"
      when talkai.config.trainCode
        body.title = data.text
        body.text = "<ul>"
        data.list.forEach (el) ->
          body.text += "<li><a href=" + el.detailurl + ">#{el.trainnum} #{el.start} - #{el.terminal} / 时间: #{el.starttime} - #{el.endtime}</a></li>"
        body.text += "</ul>"
      when talkai.config.flightCode
        body.title = data.text
        body.text = "<ul>"
        data.list.forEach (el) ->
          body.text += "<li><a href=" + el.detailurl + ">#{el.flight} #{el.route} / 时间: #{el.starttime} - #{el.endtime}</a></li>"
        body.text += "</ul>"
      when talkai.config.othersCode
        body.title = data.text
        body.text = "<ul>"
        data.list.forEach (el) ->
          body.text += "<li><a href=" + el.detailurl + ">#{el.name}</a></li>"
        body.text += "</ul>"

    return body

module.exports = talkai = service.register 'talkai', ->

  @title = '小艾'

  @robot.email = 'talkai@talk.ai'

  @iconUrl = service.static 'images/icons/talkai@2x.png'

  @config =

    url: "http://www.tuling123.com/openapi/api"
    errorCodes:
      40001: "key的长度错误"
      40002: "请求内容为空"
      40003: "key错误或帐号未激活"
      40004: "当天请求次数已用完"
      40005: "暂不支持该功能"
      40006: "服务器升级中"
      40007: "服务器数据格式异常"
    textCode: 100000
    urlCode: 200000
    newsCode: 302000
    trainCode: 305000
    flightCode: 306000
    othersCode: 308000

  @registerEvent 'message.create', _sendToRobot
