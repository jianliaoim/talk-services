should = require 'should'
Promise = require 'bluebird'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
{limbo, socket} = service.components
{IntegrationModel, TeamModel, MessageModel, RoomModel, UserModel} = limbo.use 'talk'
robot = service.load 'robot'

describe 'Robot#Events', ->

  team = new TeamModel
    name: 'Team'

  room = new RoomModel
    topic: 'General'
    team: team._id
    isGeneral: true

  integration = new IntegrationModel
    category: 'robot'
    team: team._id
    token: 'abc'
    title: robot.title
    url: "http://www.domain.com"
    iconUrl: robot.iconUrl

  it 'message.create', (done) ->
    robot.httpPost = (url, message) ->
      message.body.should.eql 'abc'
      return Promise.resolve(content: "Hi")

    robot.sendMessage = (message) ->
      message.body.should.eql 'Hi'
      "#{message._toId}".should.eql '559ce208e891ac07a3d6bb2a'
      "#{message._creatorId}".should.eql "#{integration._robotId}"
      "#{message._teamId}".should.eql "#{team._id}"
      done()

    message = new MessageModel
      creator: '559ce208e891ac07a3d6bb2a'
      team: team._id
      to: integration._robotId
      body: 'abc'

    robot.receiveEvent 'message.create', message
    .catch done

  it 'service.webhook', (done) ->
    robot.sendMessage = (message) ->
      message.should.have.properties '_teamId', '_roomId'
      message.body.should.eql 'Hi'
      "#{message._creatorId}".should.eql "#{integration._robotId}"
      "#{message._roomId}".should.eql "#{room._id}"  # General room
      done()

    payload = content: "Hi"
    req.body = payload
    req.integration = integration
    robot.receiveEvent 'service.webhook', req
    .catch done

  it 'before.integration.update', (done) ->
    integration.title = '滴滴'
    integration.description = "睡觉啦"
    integration.iconUrl = "http://www.newicon.com"

    req.integration = integration
    robot.receiveEvent 'before.integration.update', req
    .then ->
      UserModel.findOneAsync _id: integration._robotId
      .then (robot) ->
        robot.name.should.eql '滴滴'
        robot.description.should.eql '睡觉啦'
        robot.avatarUrl.should.eql "http://www.newicon.com"
        done()
    .catch done

  it 'before.integration.remove', (done) ->
    socket.broadcast = (channel, event, data, socketId) ->
      channel.should.eql "team:#{team._id}"
      event.should.eql 'team:leave'
      data.should.have.properties '_userId', '_teamId'
      done()

    req.integration = integration
    robot.receiveEvent 'before.integration.remove', req
    .catch done

  after cleanup
