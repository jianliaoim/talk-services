express = require 'express'
bodyParser = require 'body-parser'

module.exports = app = express()

app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: true)

app.use (err, req, res, next) ->
  res.status(400).json
    code: 400
    message: err.message

app.use '/tb', require './teambition'
app.use '/account', require './account'
app.use '/rss', require './rss'
app.use '/github', require './github'

app.listen 7632
