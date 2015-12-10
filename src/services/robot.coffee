Promise = require 'bluebird'
_ = require 'lodash'
util = require '../util'

###*
 * Post message to the bundled url
 * @param  {Model} message
 * @return {Promise}
###
_postMessage = (message) ->
  {limbo} = service.components
  {TeamModel, IntegrationModel} = limbo.use 'talk'
  self = this

  $integration = IntegrationModel.findOneAsync
    team: message._teamId
    robot: message._toId
    errorInfo: null

  $integration.then (integration) ->
    return unless integration?.url
    {url, token} = integration
    msg = message.toJSON?() or message
    message.token = token if token

    self.httpPost url, msg, retryTimes: 5

    .then (body) ->
      return unless body?.content or body?.text or body?.title
      replyMessage =
        _creatorId: integration._robotId
        _teamId: message._teamId
      if message._roomId
        replyMessage._roomId = message._roomId
      else
        replyMessage._toId = message._creatorId
      replyMessage.body = body.content if body.content
      if body.text or body.title
        attachment = category: 'quote', data: body
        attachment.data.category = 'robot'
        replyMessage.attachments = [attachment]
      self.sendMessage replyMessage

    .catch (err) ->
      integration.errorTimes += 1
      integration.lastErrorInfo = err.message
      integration.errorInfo = err.message if integration.errorTimes > 5
      new Promise (resolve, reject) ->
        integration.save (err, integration) ->
          return reject(err) if err
          resolve()

_receiveWebhook = ({integration, query, body}) ->
  {limbo} = service.components
  {TeamModel, RoomModel, MemberModel} = limbo.use 'talk'
  self = this

  payload = _.assign {}
    , query or {}
    , body or {}

  {content, authorName, title, text, redirectUrl, imageUrl, thumbnailPicUrl, _roomId, _toId} = payload
  {_teamId} = integration
  throw new Error("Title and text can not be empty") unless title?.length or text?.length or content?.length

  message =
    integration: integration
    body: content
    authorName: authorName
    _teamId: _teamId
    _creatorId: integration._robotId

  if title or text or redirectUrl or thumbnailPicUrl or imageUrl
    attachment =
      category: 'quote'
      data:
        title: title
        text: text
        redirectUrl: redirectUrl
        imageUrl: thumbnailPicUrl or imageUrl

  if _roomId
    $message = RoomModel.findOneAsync _id: _roomId
    .then (room) ->
      throw new Error('OBJECT_MISSING', "room #{_roomId}") unless room
      throw new Error('INVALID_OBJECT', "room #{_roomId}") unless "#{room._teamId}" is "#{_teamId}"
      message.room = room._id
      message
  else if _toId
    throw new Error("INVALID_OBJECT", "can not send message to self") if "#{_toId}" is "#{integration._robotId}"
    $message = MemberModel.findOneAsync user: _toId, team: _teamId, isQuit: false
    .then (member) ->
      throw new Error("INVALID_OBJECT", "user #{_toId}") unless member
      message._toId = _toId
      message
  else
    $message = RoomModel.findOne team: _teamId, isGeneral: true
    .then (room) ->
      throw new Error('OBJECT_MISSING', "general room of team #{_teamId}") unless room
      message._roomId = room._id
      message

  $message.then (message) ->
    message.attachments = [attachment] if attachment
    self.sendMessage message

###*
 * Remove this robot from bundled team
 * @param  {Model} integration
 * @return {Promise}
###
_removeRobot = ({integration}) ->
  {limbo, socket} = service.components
  {TeamModel} = limbo.use 'talk'
  return unless integration._robotId

  TeamModel.removeMemberAsync integration._teamId, integration._robotId
  .then (team) ->
    data =
      _teamId: team._id
      _userId: integration._robotId
    socket.broadcast "team:#{team._id}", "team:leave", data

###*
 * Create a new robot and invite him to this team
 * Fork current robot as the bundle user of this integration
 * @param  {Model} integration
 * @return {Promise}
###
_createRobot = ({integration}) ->
  {limbo, socket} = service.components
  {UserModel, TeamModel} = limbo.use 'talk'

  robot = new UserModel
    name: integration.title
    avatarUrl: integration.iconUrl
    description: integration.description
    isRobot: true

  $robot = new Promise (resolve, reject) ->
    robot.save (err, robot) ->
      return reject(err) if err
      resolve robot

  $team = $robot.then (robot) ->
    integration.robot = robot
    TeamModel.addMemberAsync integration._teamId, robot._id

  $broadcast = Promise.all [$robot, $team]

  .spread (robot, team) ->
    robot.team = team
    robot._teamId = team._id
    socket.broadcast "team:#{team._id}", "team:join", robot

###*
 * Update robot infomation
 * @param  {Model} integration
 * @return {Promise} robot
###
_updateRobot = ({integration}) ->
  return unless integration._robotId
  {limbo} = service.components
  {UserModel, TeamModel} = limbo.use 'talk'
  $robot = UserModel.findOneAsync _id: integration._robotId
  .then (robot) ->
    return unless robot
    robot.name = integration.title
    robot.avatarUrl = integration.iconUrl
    robot.description = integration.description
    robot.updatedAt = new Date
    new Promise (resolve, reject) ->
      robot.save (err, robot) ->
        return reject(err) if err
        resolve robot

module.exports = ->

  @title = '自定义机器人'

  @template = 'form'

  @isCustomized = true

  @summary = util.i18n
    zh: '我们提供了开放的数据接口，你可以利用自定义机器人开发各种应用和服务。'
    en: 'A robot act as a real user'

  @description = util.i18n
    zh: '自定义机器人的功能不限，你可以利用我们提供的开放数据接口，开发更多简聊的相关应用和服务。'
    en: 'A robot act as a real user'

  @iconUrl = util.static 'images/icons/robot@2x.png'

  @headerFields = []

  @fields = [
    key: 'url'
    type: 'text'
    description: util.i18n
      zh: '（可选）你可以通过 Webhook URL 来接收用户发送给机器人的消息'
      en: '(Optional) Webhook url of your application'
  ,
    key: 'token'
    type: 'text'
    autoGen: true
    description: util.i18n
      zh: '（可选）Token 会被包含在发送给你的消息中'
      en: '(Optional) Token will include in the received message'
  ,
    key: 'webhookUrl'
    type: 'text'
    readonly: true
    showOnSaved: true
    description: util.i18n
      zh: '通过 Webhook URL 发送消息给话题或成员'
      en: 'Send messages to users or channels through webhook URL'
  ]

  @registerEvent 'message.create', _postMessage

  @registerEvent 'service.webhook', _receiveWebhook

  @registerEvent 'before.integration.create', _createRobot

  @registerEvent 'before.integration.update', _updateRobot

  @registerEvent 'before.integration.remove', _removeRobot
