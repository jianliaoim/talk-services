should = require 'should'
loader = require '../../src/loader'
{req} = require '../util'
$jiankongbao = loader.load 'jiankongbao'

payload =
  msg_id: 1
  task_id: 2
  task_type: 'http'
  fault_time: 1421050275
  content: '测试消息'
  token: 'a821dc01d5eb3056fddbccf21cc24966'

describe 'Jiankongbao#Webhook', ->

  req.integration = _id: 123

  it 'should create new message when receive jiankongbao webhook', (done) ->
    req.body = payload

    $jiankongbao.then (jiankongbao) -> jiankongbao.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.text.should.eql payload.content
      message.attachments[0].data.redirectUrl.should.eql 'https://qiye.jiankongbao.com/task/http/2'
    .nodeify done
