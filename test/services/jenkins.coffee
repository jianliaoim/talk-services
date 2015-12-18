should = require 'should'
loader = require '../../src/loader'
{req} = require '../util'
$jenkins = loader.load 'jenkins'

describe 'Jenkins#Webhook', ->

  req.integration = _id: '123'

  it 'receive webhook', (done) ->

    req.body =
      authorName: '路人甲'
      title: '你好'
      text: '天气不错'
      redirectUrl: 'https://talk.ai/site'
      imageUrl: 'https://dn-talk.oss.aliyuncs.com/site/images/workspace-84060cfd.jpg'

    $jenkins.then (jenkins) -> jenkins.receiveEvent 'service.webhook', req
    .then (message) ->
      message.should.have.properties 'authorName'
      message.attachments[0].data.should.have.properties 'title', 'text', 'redirectUrl', 'imageUrl'
    .nodeify done
