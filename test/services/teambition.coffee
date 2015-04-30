should = require 'should'
Promise = require 'bluebird'
requireDir = require 'require-dir'
service = require '../../src/service'
config = require '../config'
{prepare, cleanup, req} = require '../util'
teambition = service.load 'teambition'
{limbo} = service.components
{IntegrationModel} = limbo.use 'talk'

payloads = requireDir './teambition_assets'

sign =
  "sign": "b0df73e3c09a9620f31998911b1940109ee24c0b"
  "timestamp": "1430293521192"
  "nonce": "b00e8a80"

_testWebhook = (event, payload, checkMessage) ->
  # Overwrite the sendMessage function of coding
  teambition.sendMessage = checkMessage
  req.body = payload
  teambition.receiveEvent 'service.webhook', req

describe 'Teambition#IntegrationHooks', ->

  return

  unless config.teambition?.token and config.teambition?._projectId
    return console.error """
    Teambition token and _projectId are not exist
    Add them in config.json to test teambition service
    """

  @timeout 5000

  hookId = null

  {_projectId} = config.teambition

  integration = new IntegrationModel
    category: 'teambition'
    token: config.teambition.token
    events: ["task.create"]
    project: _id: config.teambition._projectId, name: 'Test'

  before prepare

  it 'should create teambition webhook when creating integration', (done) ->
    teambition.receiveEvent 'before.integration.create', integration
    .then ->
      integration.data[_projectId].should.have.properties 'hookId'
      hookId = integration.data[_projectId].hookId
      new Promise (resolve, reject) ->
        integration.save (err, integration) ->
          return reject(err) if err
          resolve integration
    .then -> done()
    .catch done

  it 'should update teambition webhook when update integration', (done) ->
    integration._original = integration.toJSON()
    integration.events = ["task.create", "subtask.create"]
    teambition.receiveEvent 'before.integration.update', integration
    .then ->
      integration.data[_projectId].hookId.should.eql hookId
      new Promise (resolve, reject) ->
        integration.save (err, integration) ->
          return reject(err) if err
          resolve integration
    .then -> done()
    .catch done

  if config.teambition._newProjectId
    it 'should update the hookId when update integration project id', (done) ->
      integration._original = integration.toJSON()
      integration.project._id = config.teambition._newProjectId
      teambition.receiveEvent 'before.integration.update', integration
      .then ->
        integration.data[config.teambition._newProjectId].hookId.should.not.eql hookId
        integration.data.should.not.have.properties config.teambition._projectId
        new Promise (resolve, reject) ->
          integration.save (err, integration) ->
            return reject(err) if err
            resolve integration
      .then -> done()
      .catch done

  else
    console.error """
    Teambition _newProjectId is not exist
    Add it in config.json to test changing teanbition integration project
    """

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

  it 'receive project.rename', ->
    _testWebhook 'project.rename', payloads['project.rename'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 修改了项目名 新名'
      message.quote.redirectUrl.should.eql payloads['project.rename'].data.project.url

  it 'receive project.archive', ->
    _testWebhook 'project.archive', payloads['project.archive'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 归档了项目'
      message.quote.redirectUrl.should.eql payloads['project.archive'].data.project.url

  it 'receive project.unarchive', ->
    _testWebhook 'project.unarchive', payloads['project.unarchive'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 恢复了项目'
      message.quote.redirectUrl.should.eql payloads['project.unarchive'].data.project.url

  after cleanup
