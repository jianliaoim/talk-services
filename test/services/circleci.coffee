should = require 'should'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
circleci = service.load 'circleci'

describe 'CircleCI#Webhook', ->

  before prepare

  it 'build success', ->
    circleci.sendMessage = (message) ->
      message.quote.title.should.eql "[drips] Build success: add test"
      message.quote.redirectUrl.should.eql 'https://circleci.com/gh/sailxjx/drips/5'

    req.body = require './circleci_assets/success'
    req.integration = _id: 1

    circleci.receiveEvent 'service.webhook', req

  it 'build fail', ->
    circleci.sendMessage = (message) ->
      message.quote.title.should.eql '[drips] Build fail: no_tests'
      message.quote.text.should.eql "It looks like we couldn't infer test settings for your project. Refer to our \"<a href='https://circleci.com/docs/manually'>Setting your build up manually</a>\" document to get started. It should only take a few minutes."
      message.quote.redirectUrl.should.eql 'https://circleci.com/gh/sailxjx/drips/2'

    req.body = require './circleci_assets/fail'
    req.integration = _id: 1

    circleci.receiveEvent 'service.webhook', req

  after cleanup
