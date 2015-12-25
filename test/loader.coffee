should = require 'should'
Promise = require 'bluebird'
_ = require 'lodash'
loader = require '../src/loader'
Service = require '../src/service'

describe 'Loader#LoadAll', ->

  it 'should services', (done) ->

    $incoming = loader.load 'incoming'
    $teambition = loader.load 'teambition'
    $rss = loader.load 'rss'

    Promise.all [$incoming, $teambition, $rss]
    .then (services) ->
      services.length.should.above 0
      services.forEach (service) -> service.should.instanceOf Service
    .nodeify done

  it 'should get settings of each service', (done) ->

    loader.settings().then (settings) ->
      settings.length.should.above 0
      settings.forEach (setting) ->
        setting.should.not.instanceOf Service
        setting.should.have.properties 'name', 'title', 'manual'

    .nodeify done
