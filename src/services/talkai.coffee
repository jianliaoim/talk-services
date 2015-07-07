service = require '../service'
qs = require 'qs'
Promise = require 'bluebird'
request = require 'request'
requestAsync = Promise.promisify request

turing =
  url: "http://www.tuling123.com/openapi/api"
  apikey: "a7c31056d4533f576447d3719e5434b3"
  devid: "105634"
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

_sendToRobot = (message) ->

  self = this

  _getTuringCallback message

  .catch (err) ->
    return # Mute

  .then (body) ->
    return unless body?.content or body?.text or body?.title
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
  return turing.errorCodes[req.code]

_getTuringCallback = (message) ->

  query =
    key: turing.apikey
    info: message.content

  requestAsync
    method: 'GET'
    url: "#{turing.url}?#{qs.stringify(query)}"
    timeout: 20000
  .spread (res, resp) ->
    unless res.statusCode >= 200 and res.statusCode < 300
      throw new Error("bad request #{res.statusCode}")
    data = JSON.parse resp
    if data.code.toString() in Object.keys turing.errorCodes
      throw new Error("bad response from Tuling123.com: #{_errorHandler(data)}")
    body = {}
    switch data.code
      when turing.textCode
        body.content = data.text
      when turing.urlCode
        body.title = data.text
        body.redirectUrl = data.url
      when turing.newsCode
        body.title = data.text
        body.text = "<ul>"
        data.list.forEach (el) ->
          body.text += "<li><a href=" + el.detailurl + ">#{el.article}</a></li>"
        body.text += "</ul>"
      when turing.trainCode
        body.title = data.text
        body.text = "<ul>"
        data.list.forEach (el) ->
          body.text += "<li><a href=" + el.detailurl + ">#{el.trainnum} #{el.start} - #{el.terminal} / 时间: #{el.starttime} - #{el.endtime}</a></li>"
        body.text += "</ul>"
      when turing.flightCode
        body.title = data.text
        body.text = "<ul>"
        data.list.forEach (el) ->
          body.text += "<li><a href=" + el.detailurl + ">#{el.flight} #{el.route} / 时间: #{el.starttime} - #{el.endtime}</a></li>"
        body.text += "</ul>"
      when turing.othersCode
        body.title = data.text
        body.text = "<ul>"
        data.list.forEach (el) ->
          body.text += "<li><a href=" + el.detailurl + ">#{el.name}</a></li>"
        body.text += "</ul>"

    return body

module.exports = talkai = service.register 'talkai', ->

  @title = '小艾'

  @robot.email = 'talkai@talk.ai'

  @iconUrl = service.static 'images/icons/talkai@2x.jpg'

  @isHidden = true

  @registerEvent 'message.create', _sendToRobot
