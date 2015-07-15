should = require 'should'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
bughd = service.load 'bughd'

describe 'BugHD#Webhook', ->

  before prepare

  it 'receive webhook', (done) ->
    bughd.sendMessage = (message) ->
      message.quote.title.should.eql 'SDKTestApp 1.1.6(Build 1)'
      message.quote.text.should.eql '''
      TITLE: *** -[__NSArrayI objectAtIndex:]: index 5 beyond bounds [0 .. 1]
      STACK: 0 CoreFoundation 0x0000000187391e64 <redacted> + 160
      CREATED_AT: 2015-02-11 12:02:58
      '''
      done()


    req.body = {
      "user_name": "BugHD",
      "datas": [
        {
          'project_name': 'SDKTestApp',
          'project_version': '1.1.6(Build 1)',
          'issue_title': '*** -[__NSArrayI objectAtIndex:]: index 5 beyond bounds [0 .. 1]',
          'issue_stack': '0 CoreFoundation 0x0000000187391e64 <redacted> + 160',
          'created_at': '1423584178'
        }
      ]
    }

    req.integration = _id: 1

    bughd.receiveEvent 'service.webhook', req
    .catch done

  after cleanup
