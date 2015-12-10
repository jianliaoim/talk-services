should = require 'should'
Promise = require 'bluebird'

loader = require '../../src/loader'
{req} = require '../util'
$incoming = loader.load 'incoming'

describe 'Incoming#Webhook', ->

  it 'receive webhook', (done) ->
    req.body =
      authorName: '路人甲'
      title: '你好'
      text: '天气不错'
      redirectUrl: 'https://talk.ai/site'
      imageUrl: 'https://dn-talk.oss.aliyuncs.com/site/images/workspace-84060cfd.jpg'

    $incoming.then (incoming) ->

      incoming.receiveEvent 'service.webhook', req

    .then (message) ->
      message.should.have.properties 'authorName'
      message.attachments[0].data.should.have.properties 'title', 'text', 'redirectUrl', 'imageUrl'

    .nodeify done
