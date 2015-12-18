should = require 'should'
loader = require '../../src/loader'
{req} = require '../util'
$heroku = loader.load 'heroku'

payload =
  app: "test-app"
  user: "test_user@heroku.com"
  url: "http://test-app.herokuapp.com"
  head: "0b5fb19"
  head_long: "0b5fb19f982713183e27abb3a7231018169a150d"
  git_log: "*Sample commit message"

describe 'Heroku#Webhook', ->

  req.integration = _id: '123'

  it 'receive webhook', (done) ->
    req.body = payload

    $heroku.then (heroku) -> heroku.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.redirectUrl.should.eql payload.url
      message.attachments[0].data.should.have.properties 'title', 'text', 'redirectUrl'
    .nodeify done
