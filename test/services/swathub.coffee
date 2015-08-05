should = require 'should'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
swathub = service.load 'swathub'

describe 'SWATHub#Webhook', ->

  req.integration = _id: '123'

  it 'receive webhook', (done) ->
    swathub.sendMessage = (message) ->
      message.attachments[0].data.should.have.properties 'authorName', 'title', 'text', 'redirectUrl', 'imageUrl'

    req.body =
      authorName: '路人甲'
      title: '你好'
      text: '天气不错'
      redirectUrl: 'https://talk.ai/site'
      imageUrl: 'https://dn-talk.oss.aliyuncs.com/site/images/workspace-84060cfd.jpg'

    swathub.receiveEvent 'service.webhook', req
    .then -> done()
    .catch done
