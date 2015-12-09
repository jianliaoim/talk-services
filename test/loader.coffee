should = require 'should'
_ = require 'lodash'
service = require '../src/loader'
Service = require '../src/service'

describe 'Loader#LoadAll', ->

  it 'should all services', (done) ->

    service.loadAll().then (services) ->
      _.values(services).length.should.above 0
      _.values(services).forEach (service) ->
        service.should.instanceOf Service

    .nodeify done

  it 'should get settings of each service', (done) ->

    service.settings().then (settings) ->
      _.values(settings).length.should.above 0
      _.values(settings).forEach (setting) ->
        setting.should.not.instanceOf Service
        setting.should.have.properties 'name', 'title', 'manual'

    .nodeify done
