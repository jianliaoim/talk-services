should = require 'should'
loader = require '../../src/loader'
{req} = require '../util'
$goldxitudaily = loader.load 'goldxitudaily'

describe 'Goldxitudaily#BeforeIntegrationCreate', ->

  it 'should modify the url of integration to xitu\'s feed url', (done) ->
    integration = category: 'goldxitudaily'
    req.integration = integration

    $goldxitudaily.then (goldxitudaily) -> goldxitudaily.receiveEvent 'before.integration.create', req
    .then -> integration.url.should.eql 'http://dev.gold.avosapps.com/jianliao/rss'
    .nodeify done
