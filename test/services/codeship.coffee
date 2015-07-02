should = require 'should'
requireDir = require 'require-dir'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
codeship = service.load 'codeship'

payload = {
  "headers": {
    "x-real-ip": "54.91.114.69",
    "x-forwarded-for": "54.91.114.69",
    "host": "talk.ai",
    "x-nginx-proxy": "true",
    "connection": "Upgrade",
    "content-length": "451",
    "content-type": "application/json",
    "user-agent": "Codeship Webhook",
    "x-newrelic-id": "XQUEWVZACQQDVQ==",
    "x-newrelic-transaction": "PxQFAF9RXVIDBVFSB1MAAFdXFB8EBw8RVU4aUFkBBldSVlhRAVFRVQIFUUNKQQlWVgEHUwUHFTs="
  },
  "query": {},
  "body": {
    "build": {
      "build_url": "https://codeship.com/projects/88500/builds/6639402",
      "commit_url": "https://github.com/lee715/easy-hotkey/commit/fda4ca3ee0a4d2d92b68a11c8cdc6d319fbe7c19",
      "project_id": 88500,
      "build_id": 6639402,
      "status": "success",
      "project_name": "lee715/easy-hotkey",
      "project_full_name": "lee715/easy-hotkey",
      "commit_id": "fda4ca3ee0a4d2d92b68a11c8cdc6d319fbe7c19",
      "short_commit_id": "fda4c",
      "message": "add new",
      "committer": "lee715",
      "branch": "master"
    }
  }
}

testWebhook = (payload, checkMessage) ->
  # Overwrite the sendMessage function of coding
  codeship.sendMessage = checkMessage
  req.body = payload.body
  codeship.receiveEvent 'service.webhook', req

describe 'codeship#Webhook', ->

  before prepare

  req.integration =
    _id: '552cc903022844e6d8afb3b4'
    category: 'codeship'

  it 'receive zen', ->
    testWebhook {}, (message) ->
      throw new Error('Should not response to zen')

  it 'receive push', ->
    testWebhook payload, (message) ->
      message.should.have.properties 'integration', 'quote'
      message.integration._id.should.eql '552cc903022844e6d8afb3b4'
      message.quote.title.should.eql '[lee715/easy-hotkey] new commits on success stage'
      message.quote.text.should.eql [
        '<a href="https://github.com/lee715/easy-hotkey/commit/fda4ca3ee0a4d2d92b68a11c8cdc6d319fbe7c19" target="_blank">'
        '<code>fda4ca:</code></a> add new<br>'
      ].join ''
      message.quote.redirectUrl.should.eql 'https://codeship.com/projects/88500/builds/6639402'

  after cleanup
