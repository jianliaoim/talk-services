should = require 'should'
loader = require '../../src/loader'
{req} = require '../util'
$circleci = loader.load 'circleci'

describe 'CircleCI#Webhook', ->

  it 'build success', ->
    req.body = require './circleci_assets/success'
    req.integration = _id: 1

    $circleci.then (circleci) -> circleci.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql "[drips] Build success: add test"
      message.attachments[0].data.redirectUrl.should.eql 'https://circleci.com/gh/sailxjx/drips/5'

  it 'build fail', ->
    req.body = require './circleci_assets/fail'
    req.integration = _id: 1

    $circleci.then (circleci) -> circleci.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql '[drips] Build fail: no_tests'
      message.attachments[0].data.text.should.eql "It looks like we couldn't infer test settings for your project. Refer to our \"<a href='https://circleci.com/docs/manually'>Setting your build up manually</a>\" document to get started. It should only take a few minutes."
      message.attachments[0].data.redirectUrl.should.eql 'https://circleci.com/gh/sailxjx/drips/2'
