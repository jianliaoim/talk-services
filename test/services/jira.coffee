should = require 'should'
requireDir = require 'require-dir'

loader = require '../../src/loader'
{req} = require '../util'
$jira = loader.load 'jira'

payloads = requireDir './jira_assets'

describe 'Jira#Webhook', ->

  req.integration =
    _id: 'xxx'
    _teamId: '123'
    _roomId: '456'

  it 'receive unknown type webhook', (done) ->

    req = payloads['empty-event']

    $jira.then (jira) -> jira.receiveEvent 'service.webhook', req
    .then -> done new Error 'Should not pass'
    .catch (err) ->
      err.message.should.eql 'Unknown Jira event type'
      done()

  it 'receive create type webhook', (done) ->

    req = payloads['create-issue']

    $jira.then (jira) -> jira.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql 'Destec Zhang [Administrator] created an issue for project test project'
      message.attachments[0].data.text.should.eql 'Summary: test bug'
    .nodeify done

  it 'receive update type webhook', (done) ->

    req = payloads['update-issue']

    $jira.then (jira) -> jira.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql 'Destec Zhang [Administrator] updated an issue for project test project'
      message.attachments[0].data.text.should.eql 'Summary: test bug'
    .nodeify done
