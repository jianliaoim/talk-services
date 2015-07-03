should = require 'should'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
pingxx = service.load 'pingxx'
requireDir = require 'require-dir'

payloads = requireDir './pingxx_assets'

describe 'Pingxx#Webhook', ->

  before prepare

  it 'receive charge.succeeded', (done) ->
    pingxx.sendMessage = (message) ->
      message.quote.title.should.eql "付款成功 Your Subject"
      message.quote.text.should.eql '''
      订单号：123456789
      金额：1 CNY
      商品描述：Your Body
      付款时间：2015-03-28 11:05:01
      失效时间：2015-03-29 11:04:36
      '''
      message.quote.redirectUrl.should.eql 'https://dashboard.pingxx.com/app/detail?app_id=app_1234567890abcDEF'
      done()

    req.body = payloads['charge.succeeded']
    req.integration = _id: 1

    pingxx.receiveEvent 'service.webhook', req
    .catch done

  it 'receive summary.daily.available', (done) ->
    pingxx.sendMessage = (message) ->
      message.quote.title.should.eql "日统计 Company Name"
      message.quote.text.should.eql '''
      交易金额：10 元
      交易量：100 笔
      起始时间：2015-02-28 12:00:00
      终止时间：2015-02-28 11:59:59
      '''
      done()

    req.body = payloads['summary.daily.available']
    req.integration = _id: 1
    pingxx.receiveEvent 'service.webhook', req
    .catch done

  after cleanup
