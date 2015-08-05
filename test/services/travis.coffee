should = require 'should'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
travis = service.load 'travis'

describe 'Travis#Webhook', ->

  before prepare

  it 'receive webhook', (done) ->
    travis.sendMessage = (message) ->
      message.attachments.length.should.eql 1
      attachment = message.attachments[0]
      {category, data} = attachment
      category.should.eql 'quote'
      data.title.should.eql '[Broken] drips #8 (master - ab6cc90) by Xu Jingxin'
      data.text.should.eql 'Test fail'
      data.redirectUrl.should.eql 'https://travis-ci.org/sailxjx/drips/builds/69093771'
      done()

    req.body = require './travis_assets/fail.json'
    req.integration = _id: 1
    travis.receiveEvent 'service.webhook', req
    .catch done

  after cleanup
