should = require 'should'
service = require '../../src/service'
{prepare, cleanup, req, res} = require '../util'
jiankongbao = service.load 'jiankongbao'

payload =
  msg_id: 1
  task_id: 2
  task_type: 'http'
  fault_time: 1421050275
  content: '测试消息'
  token: 'a821dc01d5eb3056fddbccf21cc24966'

describe 'Jiankongbao#Webhook', ->

  req.integration = _id: 123

  before prepare

  it 'should create new message when receive jiankongbao webhook', (done) ->
    jiankongbao.sendMessage = (message) ->
      message.quote.text.should.eql payload.content
      message.quote.redirectUrl.should.eql 'https://qiye.jiankongbao.com/task/http/2'

    req.body = payload

    jiankongbao.receiveEvent 'service.webhook', req, res
    .then -> done()
    .catch done

  after cleanup
