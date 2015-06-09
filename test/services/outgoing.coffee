limbo = require 'limbo'
mongoose = require 'mongoose'
Promise = require 'bluebird'

service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
outgoing = service.load 'outgoing'
{IntegrationModel} = limbo.use 'talk'

describe 'Outgoing#Webhook', ->

  _roomId = mongoose.Types.ObjectId()

  message =
    content: 'Hello'
    creator: name: 'Talkuser'
    room: _id: _roomId, topic: 'OK'
    _roomId: _roomId
    team: name: 'Team'
    createdAt: new Date
    updatedAt: new Date
    isManual: true

  integration = new IntegrationModel
    room: _roomId
    url: "http://www.someurl.com"
    category: 'outgoing'

  # The first retry after failed request will waiting 1 seconds
  @timeout 2000

  before (done) ->
    integration.save (err, integration) ->
      req.integration = integration
      prepare done

  it 'should post the new message to integration url', (done) ->
    ###*
     * Service will post the message to the url of integration
     * And create a reply message from the response
    ###
    outgoing.httpPost = (url, payload) ->
      url.should.eql "http://www.someurl.com"
      payload.should.have.properties 'content', 'team', 'room', 'creator', 'createdAt', 'updatedAt'
      payload.creator.name.should.eql 'Talkuser'
      body =
        username: 'Stack'
        content: 'Winter is coming'
      Promise.resolve body

    # Over write the sendMessage
    outgoing.sendMessage = (message) ->
      message.integration._id.should.eql req.integration._id
      message.content.should.eql 'Winter is coming'
      message.quote.authorName.should.eql 'Stack'

    outgoing.receiveEvent 'message.create', message
    .then -> done()
    .catch done

  it 'try several times when fire an error response from third party server', (done) ->
    num = 0
    # Drop the messages
    outgoing.sendMessage = ->

    outgoing.httpPost = (url, payload) ->
      Promise.resolve()
      .then ->
        num += 1
        throw new Error("Try another time") if num is 1
        num.should.eql 2
        outgoing.httpPost = ->

    outgoing.receiveEvent 'message.create', message
    .then -> done()
    .catch done

  after cleanup

describe 'Outgoing#IntegrationHooks', ->

  before prepare

  integration = new IntegrationModel
    category: 'outgoing'
    url: 'invalidurl'

  it 'should throw an error when url is invalid', (done) ->
    outgoing.receiveEvent 'before.integration.create', integration
    .then -> done(new Error('Should emit error here'))
    .catch (err) ->
      err.message.should.eql 'Invalid url field'
      done()

  after cleanup
