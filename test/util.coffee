# Test utils

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

module.exports =
  prepare: prepare
  cleanup: cleanup
