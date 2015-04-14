should = require 'should'
service = require '../service'
coding = service.loadAll().coding
{prepare, cleanup} = service.util

describe 'Coding#Webhook', ->

  before prepare

  it 'should create new message when receive a webhook request', (done) ->
    done()
    # coding.receiveEvent 'webhook', req, res, done

  after cleanup
