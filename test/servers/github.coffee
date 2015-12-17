express = require 'express'

reposToHook =
  awesome: id: 1

app = express()

app.post '/repos/:user/:repos/hooks', (req, res) ->
  res.json reposToHook[req.params.repos]

module.exports = app
