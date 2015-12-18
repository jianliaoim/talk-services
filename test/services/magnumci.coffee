should = require 'should'
loader = require '../../src/loader'
{req} = require '../util'
$magnumci = loader.load 'magnumci'

describe 'Magnumci#Webhook', ->

  it 'receive webhook', (done) ->
    req.body = require './magnumci_assets/fail.json'
    req.integration = _id: 1

    $magnumci.then (magnumci) -> magnumci.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql '[FAIL] drips #1 (master - master) by Magnum CI'
      message.attachments[0].data.text.should.eql 'Test build'
      message.attachments[0].data.redirectUrl.should.eql 'http://magnum-ci.com/projects/2986/builds/172696'
    .nodeify done
