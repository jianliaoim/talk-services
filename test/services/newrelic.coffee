should = require 'should'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
newrelic = service.load 'newrelic'

payload =
  policy_url: "https://alerts.newrelic.com/accounts/1065273/policies/0"
  condition_id: 0
  condition_name: "New Relic Alert - Test Condition"
  account_id: 1065273
  event_type: "NOTIFICATION"
  runbook_url: "http://localhost/runbook/url"
  severity: "INFO"
  incident_id: 0
  account_name: "Teambition_4"
  timestamp: 1439535842735
  details: "New Relic Alert - Channel Test"
  incident_acknowledge_url: "https://alerts.newrelic.com/accounts/1065273/incidents/0/acknowledge"
  owner: "Test User"
  policy_name: "New Relic Alert - Test Policy"
  incident_url: "https://alerts.newrelic.com/accounts/1065273/incidents/0"
  current_state: "test"
  targets: [
    id: "12345"
    name: "Test Target"
    link: "http://localhost/sample/callback/link/12345"
    labels:
      label: "value"
    product: "TESTING"
    type: "test"
  ]

describe 'NewRelic#Webhook', ->

  req.integration = _id: '123'

  before prepare

  it 'receive webhook', (done) ->
    newrelic.sendMessage = (message) ->
      message.should.have.properties 'integration'
      message.attachments[0].data.redirectUrl.should.eql payload.incident_url
      message.attachments[0].data.title.should.eql '''
        NOTIFICATION: New Relic Alert - Test Condition
      '''
      message.attachments[0].data.text.should.eql '''
        Owner: Test User
        Incident: New Relic Alert - Channel Test
      '''

    req.body = payload

    newrelic.receiveEvent 'service.webhook', req
    .then -> done()
    .catch done
