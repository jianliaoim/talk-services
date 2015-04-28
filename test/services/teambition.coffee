return
should = require 'should'
requireDir = require 'require-dir'
service = require '../../src/service'
config = require '../config'
{prepare, cleanup, req} = require '../util'
teambition = service.load 'teambition'
{limbo} = service.components
{IntegrationModel} = limbo.use 'talk'

payloads = requireDir './teambition_assets'

describe 'Teambition#IntegrationHooks', ->

  unless config.teambition?._userId
    return console.error """
    Config Teambition user to test teambition integration hooks
    """

  @timeout 5000

  hookId = null

  before prepare

  integration = new IntegrationModel
    category: 'teambition'
    _creatorId: config.teambition._userId
    data:
      project:
        _id: '123'
        name: '1231231231'
      notifications:
        task: true

  it 'should create teambition webhook when creating integration', (done) ->
    teambition.receiveEvent 'before.integration.create', integration
    .then ->
      integration.data.should.have.properties 'hookId'
      hookId = integration.data.hookId
      new Promise (resolve, reject) ->
        integration.save (err, integration) ->
          return reject(err) if err
          resolve integration

    .then -> done()
    .catch done

  it 'should update teambition webhook when update integration', (done) ->
    integration.data.notifications.task = false
    # Mark the mixed field `modified` to save this property into database
    integration.markModified 'data'

    teambition.receiveEvent 'before.integration.update', integration
    .then ->
      integration.data.hookId.should.eql hookId
      new Promise (resolve, reject) ->
        integration.save (err, integration) ->
          return reject(err) if err
          resolve integration

    .then -> done()
    .catch done

  it 'should remove the teambition hook when remove integration', (done) ->
    teambition.receiveEvent 'before.integration.remove', integration
    .then -> done()
    .catch done

  after cleanup

describe 'Teambition#Webhook', ->

  before prepare

  req.integration =
    _id: '5539eef5db959e7d87c9e48a'
    category: 'teambition'

  after cleanup
