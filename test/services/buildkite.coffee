should = require 'should'
loader = require '../../src/loader'
{req} = require '../util'
$buildkite = loader.load 'buildkite'

describe 'Buildkite#Webhook', ->

  it 'receive webhook', (done) ->

    req.body = require './buildkite_assets/payload.json'
    req.headers =
      "X-Buildkite-Event": "build.scheduled"
      "X-Buildkite-Token": "02ddb822d4000975005c76484364f1ee"
      "X-Buildkite-Request": "65f07186-541f-41db-90dd-ca393070c170"
    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    $buildkite.then (buildkite) -> buildkite.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql '[scheduled] drips #4 (master - 91f48ae) by Xu Jingxin'
      message.attachments[0].data.text.should.eql 'Fix build'
      message.attachments[0].data.redirectUrl.should.eql 'https://buildkite.com/teambition/drips/builds/4'
    .nodeify done
