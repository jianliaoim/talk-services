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
      message.attachments[0].data.title.should.eql "付款成功 Your Subject"
      message.attachments[0].data.text.indexOf '''
      订单号：123456789
      金额：1 CNY
      商品描述：Your Body
      '''
      .should.eql 0
      message.attachments[0].data.redirectUrl.should.eql 'https://dashboard.pingxx.com/app/detail?app_id=app_1234567890abcDEF'
      done()

    req.body = payloads['charge.succeeded']
    req.integration = _id: 1

    pingxx.receiveEvent 'service.webhook', req
    .catch done

  it 'receive summary.daily.available', (done) ->
    pingxx.sendMessage = (message) ->
      message.attachments[0].data.title.should.eql "日统计 Company Name"
      message.attachments[0].data.text.indexOf '''
      交易金额：10 元
      交易量：100 笔
      '''
      .should.eql 0
      done()

    req.body = payloads['summary.daily.available']
    req.integration = _id: 1
    pingxx.receiveEvent 'service.webhook', req
    .catch done

  after cleanup
