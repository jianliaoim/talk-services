should = require 'should'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
firim = service.load 'firim'

describe 'Firim#Webhook', ->

  before prepare

  it 'receive webhook', (done) ->
    firim.sendMessage = (message) ->
      message.quote.text.should.eql 'Fir.im: 你好'
      message.quote.redirectUrl.should.eql 'http://fir.im/'

    req.body =
      msg: '你好'
      link: 'http://fir.im/'
    req.integration = _id: 1
    firim.receiveEvent 'service.webhook', req
    .then -> done()
    .catch done

  after cleanup
