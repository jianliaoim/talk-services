should = require 'should'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
goldxitudaily = service.load 'goldxitudaily'
{limbo} = service.components
{IntegrationModel} = limbo.use 'talk'

describe 'Goldxitudaily#BeforeIntegrationCreate', ->

  before prepare

  it 'should modify the url of integration to xitu\'s feed url', (done) ->
    integration = new IntegrationModel
      category: 'goldxitudaily'
    req.integration = integration
    goldxitudaily.receiveEvent 'before.integration.create', req
    .then ->
      integration.url.should.eql 'http://dev.gold.avosapps.com/jianliao/rss'
      done()
    .catch done

  after cleanup
