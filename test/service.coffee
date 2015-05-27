_ = require 'lodash'

service = require '../src/service'
service.components = require './components'
util = require './util'

{prepare, cleanup} = util

describe 'Service#LoadAll', ->

  before prepare

  it 'should load services, each with several properties', ->

    services = service.loadAll()
    Object.keys(services).forEach (name) ->
      services[name].should.have.properties 'name', 'title'

  it 'should load robots of each services when the promise is fulfilled', (done) ->

    _checkService = (service) ->
      service.robot.should.have.properties 'name', 'avatarUrl', 'email', 'createdAt', 'updatedAt'
      service.robot.isRobot.should.eql true

    services = service.loadAll()

    service.loadAll().$promise.then (_services) ->

      console.log _services.coding.toJSON()

      Object.keys(_services).forEach (name) ->
        _checkService _services[name]

      Object.keys(services).forEach (name) ->
        _checkService services[name]

      done()

  after cleanup

module.exports = service
