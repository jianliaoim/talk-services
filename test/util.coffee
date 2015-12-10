# Test utils
http = require 'http'
Promise = require 'bluebird'

prepare = (done) -> done()

cleanup = (done) -> done()

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
