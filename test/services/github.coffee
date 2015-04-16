should = require 'should'
requireDir = require 'require-dir'
Promise = require 'bluebird'

service = require '../../src/service'
config = require '../config'
{prepare, cleanup, req, res} = require '../util'
github = service.load 'github'
{limbo} = service.components
{IntegrationModel} = limbo.use 'talk'

payloads = requireDir './github_assets'

describe 'Github#IntegrationHooks', ->

  return  # Skip test with github apis

  unless config.github?.token and config.github?.repos
    return console.error """
    Github token and repos not exist
    Add them in config.json to test github service
    """

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

describe 'Github#Webhook', ->

  before prepare

  req.integration = _id: 'xxx'

  it 'receive commit comment', (done) ->
    github.sendMessage = (message) ->
      message.quote.userName.should.eql 'sailxjx'
      message.quote.userAvatarUrl.should.eql 'https://avatars.githubusercontent.com/u/909853?v=3'
      message.quote.title.should.eql 'teambition/limbo new commit comment by sailxjx'
      message.quote.text.trim().should.eql '<p>Leave a commit comment</p>'
      message.quote.redirectUrl.should.eql 'https://github.com/teambition/limbo/commit/507388aa1123b0e91fa2d17314b625802cd3f3fa#commitcomment-8535013'

    req.body = payloads['commit-comment']
    req.headers['x-github-event'] = 'commit_comment'
    github.receiveEvent 'webhook', req, res
    .then -> done()
    .catch done

  it 'receive create', (done) ->
    github.sendMessage = (message) ->
      message.quote.title.should.eql 'new branch [test] to teambition/limbo'
      message.quote.redirectUrl.should.eql 'https://github.com/teambition/limbo'

    req.body = payloads['create']
    req.headers['x-github-event'] = 'create'
    github.receiveEvent 'webhook', req, res
    .then -> done()
    .catch done

  after cleanup
