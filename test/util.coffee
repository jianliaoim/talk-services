# Test utils
http = require 'http'
Promise = require 'bluebird'
{limbo, redis} = require './components'
talk = limbo.use 'talk'

prepare = (done) -> done()

cleanup = (done) ->
  $cleanRedis = redis.flushdbAsync()
  $cleanDb = Promise.all Object.keys(talk).map (key) ->
    model = talk[key]
    return unless toString.call(model?.remove) is '[object Function]'
    model.removeAsync()

  Promise.all [$cleanRedis, $cleanDb]
  .then -> done()
  .catch done

util =
  prepare: prepare
  cleanup: cleanup

Object.defineProperty util, 'req',
  get: ->
    req = new http.IncomingMessage
    req._params = {}
    req.headers = {}
    req.get = (key) -> if key then @_params[key] else @_params
    req.set = (key, val) -> @_params[key] = val
    req

Object.defineProperty util, 'res', ->
  get: ->
    res = new http.ServerResponse
    res

module.exports = util


