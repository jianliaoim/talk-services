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

  it 'should load a service and apply reg function again', (done) ->

    $custom = loader.load 'custom', (custom) ->
      Promise.delay(100).then -> custom.customName = 'customName'

    $custom = loader.load('custom').then (custom) ->
      custom.customName.should.eql 'customName'

    $custom.nodeify done

  it 'should get an error message when service register was not existing and reg function was not provided', (done) ->

    loader.load 'unknown'
    .then -> done new Error('Should not pass')
    .catch (err) -> done()
