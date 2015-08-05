should = require 'should'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
jinshuju = service.load 'jinshuju'

payload = {
  "form": "PXmEGx",
  "entry": {
    "serial_number": 2,
    "field_1": "“学霸”6号",
    "field_2": [
      "“小姐”2号",
      "“导员”3号",
      "“阿呆“5号"
    ],
    "field_4": " “超人”1号",
    "field_5": " “小姐”2号",
    "field_6": "“导员”3号",
    "creator_name": "sailxjx",
    "created_at": "2015-01-06T02:36:44Z",
    "updated_at": "2015-01-06T02:36:44Z",
    "info_remote_ip": "101.231.114.44"
  }
}

describe 'Jinshuju#Webhook', ->

  req.integration = _id: 1

  before prepare

  it 'should create new message when receive jinshuju webhook', (done) ->
    jinshuju.sendMessage = (message) ->
      message.attachments[0].data.text.should.eql "sailxjx 添加了新的数据"
      message.attachments[0].data.redirectUrl.should.eql "https://jinshuju.net/forms/PXmEGx/entries"

    req.body = payload

    jinshuju.receiveEvent 'service.webhook', req
    .then -> done()
    .catch done

  after cleanup
