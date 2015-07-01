should = require 'should'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
travis = service.load 'travis'

describe 'Travis#Webhook', ->

  before prepare

  it 'receive webhook', (done) ->
    travis.sendMessage = (message) ->
      message.quote.title.should.eql '[Broken] drips #8 (master - ab6cc90) by Xu Jingxin'
      message.quote.text.should.eql 'Test fail'
      message.quote.redirectUrl.should.eql 'https://travis-ci.org/sailxjx/drips/builds/69093771'
      done()

    req.body = require './travis_assets/fail.json'
    req.integration = _id: 1
    travis.receiveEvent 'service.webhook', req
    .catch done

  after cleanup
