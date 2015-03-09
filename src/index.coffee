requireDir = require 'require-dir'
services = requireDir './services'

class Service

  services: services

  ###*
   * Initialize all services
   * @param  {[type]} name [description]
   * @return {[type]}      [description]
  ###
  initialize: (name) ->

  ###*
   * Get settings of all services
   * @return {Object} settings
  ###
  getAllSettings: ->
    sets = {}
    Object.keys(services).forEach (key) ->
      sets[key] = services[key].setting
    sets

module.exports = new Service
