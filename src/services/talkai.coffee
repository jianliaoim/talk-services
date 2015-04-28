service = require '../service'

module.exports = service.register 'talkai', ->

  @title = '小艾'

  @robot.email = 'talkai@talk.ai'

  @isHidden = true
