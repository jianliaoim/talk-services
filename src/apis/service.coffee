app = require '../server'

module.exports = serviceController = app.controller 'service', ->

  @action 'settings', (req, res, callback) ->
    callback null, ok: 1
