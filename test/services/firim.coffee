should = require 'should'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
firim = service.load 'firim'

describe 'Firim#Webhook', ->

  before prepare

  it 'receive webhook', (done) ->
    firim.sendMessage = (message) ->
      message.attachments[0].data.title.should.eql 'fir.im: 小叮当的梦想国-更新'
      message.attachments[0].data.text.should.eql '''
      BUILD 2
      PLATFORM Android
      CHANGELOG
      测试webhook\r\n测试内容：\r\n修改bug
      '''
      message.attachments[0].data.redirectUrl.should.eql 'http://fir.im/6gca'
      message.attachments[0].data.imageUrl.should.eql 'https://tools.teambition.net/qr.png?text=http%3A%2F%2Ffir.im%2F6gca'

    req.body = {
      "msg": "小叮当的梦想国-更新",
      "icon": "http://firicon.fir.im/3f8e9549b93029b9e18828f67af17b0d77525990",
      "link": "http://fir.im/6gca",
      "name": "小叮当的梦想国",
      "changelog": "测试webhook\r\n测试内容：\r\n修改bug",
      "platform": "Android",
      "build": "2"
    }
    req.integration = _id: 1
    firim.receiveEvent 'service.webhook', req
    .then -> done()
    .catch done

  after cleanup
