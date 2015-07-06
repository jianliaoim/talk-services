should = require 'should'
requireDir = require 'require-dir'

service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
jira = service.load 'jira'

payloads = requireDir './jira_assets'

describe 'Jira#Webhook', ->

  before prepare

  req.integration =
    _id: 'xxx'
    _teamId: '123'
    _roomId: '456'

  it 'receive unknown type webhook', (done) ->

    req = payloads['empty-event']

    jira.receiveEvent 'service.webhook', req
    .catch (err) ->
      err.message.should.eql 'Unknown Jira event type'
      done()

  it 'receive create type webhook', (done) ->
    jira.sendMessage = (message) ->
      message.quote.title.should.eql 'Destec Zhang [Administrator] created an issue for project test project'
      message.quote.text.should.eql 'Summary: test bug'
      done()

    req = payloads['create-issue']

    jira.receiveEvent 'service.webhook', req

  it 'receive update type webhook', (done) ->
    jira.sendMessage = (message) ->
      message.quote.title.should.eql 'Destec Zhang [Administrator] updated an issue for project test project'
      message.quote.text.should.eql 'Summary: test bug'
      done()

    req = payloads['update-issue']

    jira.receiveEvent 'service.webhook', req

  after cleanup
