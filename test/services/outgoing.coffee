Promise = require 'bluebird'

loader = require '../../src/loader'
{req} = require '../util'
$outgoing = loader.load 'outgoing'

describe 'Outgoing#Webhook', ->

  message = body: 'Hello'

  integration =
    url: "http://www.someurl.com"
    category: 'outgoing'

  req.integration = integration
  req.message = message

  # The first retry after failed request will waiting 1 seconds
  @timeout 2000

  it 'should post the new message to integration url', (done) ->

    $outgoing.then (outgoing) ->

      ###*
       * Service will post the message to the url of integration
       * And create a reply message from the response
      ###
      outgoing.httpPost = (url, payload) ->
        url.should.eql "http://www.someurl.com"
        payload.should.have.properties 'body'
        body =
          authorName: 'Stack'
          text: 'Winter is coming'
        outgoing.httpPost = ->
        Promise.resolve body

      outgoing.receiveEvent 'message.create', req

      .then (message) ->
        message.attachments[0].data.text.should.eql 'Winter is coming'
        message.authorName.should.eql 'Stack'

    .nodeify done

describe 'Outgoing#IntegrationHooks', ->

  _roomId = '566942469c1c80807d335293'

  integration =
    category: 'outgoing'
    url: 'invalidurl'

  message =
    body: 'Hello'
    creator: name: 'Talkuser'
    room: _id: _roomId, topic: 'OK'
    _roomId: _roomId
    _teamId: "123"
    team: name: 'Team'

  it 'should throw an error when url is invalid', (done) ->
    req.integration = integration
    req.message = message
    $outgoing.then (outgoing) ->
      outgoing.receiveEvent 'before.integration.create', req
      .then -> done(new Error('Should emit error here'))
      .catch (err) ->
        err.message.should.eql 'Invalid url field'
        done()
