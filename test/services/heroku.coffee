should = require 'should'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
heroku = service.load 'heroku'

payload =
  app: "test-app"
  user: "test_user@heroku.com"
  url: "http://test-app.herokuapp.com"
  head: "0b5fb19"
  head_long: "0b5fb19f982713183e27abb3a7231018169a150d"
  git_log: "*Sample commit message"

describe 'Heroku#Webhook', ->

  req.integration = _id: '123'

  before prepare

  it 'receive webhook', (done) ->
    heroku.sendMessage = (message) ->
      message.should.have.properties 'integration'
      message.attachments[0].data.redirectUrl.should.eql payload.url
      message.attachments[0].data.should.have.properties 'title', 'text', 'redirectUrl'

    req.body = payload

    heroku.receiveEvent 'service.webhook', req
    .then -> done()
    .catch done
