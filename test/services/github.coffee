should = require 'should'
Promise = require 'bluebird'
service = require '../../src/service'
config = require '../config'
{prepare, cleanup, req, res} = require '../util'
github = service.load 'github'
{limbo} = service.components
{IntegrationModel} = limbo.use 'talk'

unless config.github?.token and config.github?.repos
  return console.error """
  Github token and repos not exist
  Add them in config.json to test github service
  """

describe 'Github#IntegrationHooks', ->

  @timeout 10000

  integration = new IntegrationModel
    category: 'github'
    token: config.github.token
    notifications:
      push: 1
    repos: [config.github.repos]

  hookId = null

  before prepare

  it 'should create github hook when integration created', (done) ->
    req.integration = integration
    github.receiveEvent 'integration.create', req, res
    .then ->
      integration.data[config.github.repos].hookId.should.be.type 'number'
      hookId = integration.data[config.github.repos].hookId
      new Promise (resolve, reject) ->
        integration.save (err, integration) ->
          return reject(err) if err
          resolve integration
    .catch done
    .then -> done()

  it 'should update github hook when integration updated', (done) ->
    integration.notifications =
      push: 1
      create: 1
    github.receiveEvent 'integration.update', req, res
    .then ->
      # Hook id is not changed
      integration.data[config.github.repos].hookId.should.eql hookId
      done()
    .catch done

  it 'should remove the github hook when integration removed', (done) ->
    github.receiveEvent 'integration.remove', req, res
    .then -> done()
    .catch done

  after cleanup
