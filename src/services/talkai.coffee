service = require '../service'

_sendToRobot = (message) ->

  self = this

  @httpPost @robotUrl, message

  .catch (err) ->
    return # Mute

  .then (body) ->
    return unless body?.content or body?.text
    replyMessage =
      _creatorId: self.robot._id
      _teamId: message._teamId
      _toId: message._creatorId
    replyMessage.content = body.content if body.content
    replyMessage.quote = body if body.text
    self.sendMessage replyMessage

module.exports = talkai = service.register 'talkai', ->

  @title = '小艾'

  @robot.email = 'talkai@talk.ai'

  @iconUrl = service.static 'images/icons/talkai@2x.jpg'

  @isHidden = true

  @robotUrl = 'http://localhost:7215'

  @registerEvent 'message.create', _sendToRobot
