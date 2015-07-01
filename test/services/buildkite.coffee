should = require 'should'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
buildkite = service.load 'buildkite'

describe 'Buildkite#Webhook', ->

  before prepare

  it 'receive webhook', (done) ->
    buildkite.sendMessage = (message) ->
      message.quote.title.should.eql '[scheduled] drips #4 (master - 91f48ae) by Xu Jingxin'
      message.quote.text.should.eql 'Fix build'
      message.quote.redirectUrl.should.eql 'https://buildkite.com/teambition/drips/builds/4'
      done()

    req.body = require './buildkite_assets/payload.json'
    req.headers =
      "X-Buildkite-Event": "build.scheduled"
      "X-Buildkite-Token": "02ddb822d4000975005c76484364f1ee"
      "X-Buildkite-Request": "65f07186-541f-41db-90dd-ca393070c170"
    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    buildkite.receiveEvent 'service.webhook', req
    .catch done

  after cleanup
