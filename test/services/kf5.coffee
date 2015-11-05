should = require 'should'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
kf5 = service.load 'kf5'

describe 'Kf5#Webhook', ->

  req.integration = _id: '123'

  it 'receive webhook', (done) ->
    kf5.sendMessage = (message) ->
      message.should.have.properties 'integration', 'authorName'
      message.attachments[0].data.should.have.properties 'title', 'text', 'redirectUrl', 'imageUrl'

    req.body =
      authorName: '路人甲'
      title: '你好'
      text: '天气不错'
      redirectUrl: 'https://talk.ai/site'
      imageUrl: 'https://dn-talk.oss.aliyuncs.com/site/images/workspace-84060cfd.jpg'

    kf5.receiveEvent 'service.webhook', req
    .then -> done()
    .catch done
