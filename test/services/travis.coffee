should = require 'should'
loader = require '../../src/loader'
{req} = require '../util'
$travis = loader.load 'travis'

describe 'Travis#Webhook', ->

  it 'receive webhook', (done) ->

    req.body = require './travis_assets/fail.json'
    req.integration = _id: 1

    $travis.then (travis) -> travis.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments.length.should.eql 1
      attachment = message.attachments[0]
      {category, data} = attachment
      category.should.eql 'quote'
      data.title.should.eql '[Broken] drips #8 (master - ab6cc90) by Xu Jingxin'
      data.text.should.eql 'Test fail'
      data.redirectUrl.should.eql 'https://travis-ci.org/sailxjx/drips/builds/69093771'
    .nodeify done
