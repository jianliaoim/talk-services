should = require 'should'
Promise = require 'bluebird'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
talkai = service.load 'talkai'

describe 'Talkai#MessageCreate', ->

  before prepare

  it 'receive message.create', (done) ->
    talkai.sendMessage = (message) ->
      message.should.have.properties '_creatorId', '_toId', 'content', '_teamId'
      message.content.should.eql 'Winter is coming'
      done()

    talkai.httpPost = (url, payload) ->
      payload.content.should.eql message.content
      body = content: 'Winter is coming'
      Promise.resolve body

    message =
      _toId: talkai.robot._id
      _creatorId: 1
      _teamId: 2
      content: 'For the watch'

    talkai.receiveEvent 'message.create', message

  after cleanup
