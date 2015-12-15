express = require 'express'
fs = require 'fs'

app = express()

app.get '/:feed', (req, res) ->
  {feed} = req.params
  res.send(fs.readFileSync "#{__dirname}/../services/rss_assets/#{feed}")

module.exports = app
