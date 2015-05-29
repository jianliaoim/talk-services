service = require '../service'

module.exports = service.register 'talkai', ->

  @title = '小艾'

  @robot.email = 'talkai@talk.ai'

  @iconUrl = service.static 'images/icons/talkai@2x.jpg'

  @isHidden = true
