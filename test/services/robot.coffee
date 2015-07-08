should = require 'should'
Promise = require 'bluebird'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
{limbo, socket} = service.components
{IntegrationModel, TeamModel, MessageModel} = limbo.use 'talk'
robot = service.load 'robot'

describe 'Robot#Events', ->

  team = new TeamModel
    name: 'Team'

  integration = new IntegrationModel
    category: 'robot'
    team: team._id
    token: 'abc'
    title: robot.title
    iconUrl: robot.iconUrl

  before (done) ->
    $prepare = Promise.promisify(prepare)()
    $integration = new Promise (resolve, reject) ->
      integration.save (err, integration) -> resolve integration
    $team = new Promise (resolve, reject) ->
      team.save (err, team) -> resolve team
    Promise.all [$prepare, $integration, $team]
    .then -> done()
    .catch done

  it 'before.integration.create', (done) ->
    socket.broadcast = (channel, event, data, socketId) ->
      channel.should.eql "team:#{team._id}"
      event.should.eql 'team:join'
      data.should.have.properties 'name', 'team', '_teamId'
      data.name.should.eql robot.title
      data.avatarUrl.should.eql robot.iconUrl
      data.isRobot.should.eql true
      done()

    robot.receiveEvent 'before.integration.create', integration
    .catch done

  it 'message.create', (done) ->
    message = new MessageModel
      creator: '1'
      to: robot._id
      content: 'abc'

    robot.receiveEvent 'message.create', message
    .catch done

  it 'service.webhook', (done) ->
    done()

  it 'before.integration.remove', (done) ->
    done()

  after cleanup
