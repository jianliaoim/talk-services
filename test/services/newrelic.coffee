should = require 'should'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
newrelic = service.load 'newrelic'

describe 'NewRelic#Webhook', ->
