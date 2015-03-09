Setting = require './setting'

class Service

  constructor: ->
    @setting = new Setting(@setting) unless @setting instanceof Setting

Service.Setting = Setting

module.exports = Service
