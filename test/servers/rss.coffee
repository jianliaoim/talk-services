express = require 'express'
fs = require 'fs'
should = require 'should'

app = express()

app.get '/:feed', (req, res) ->
  {feed} = req.params
  res.send(fs.readFileSync "#{__dirname}/../services/rss_assets/#{feed}")

app.post '/worker', (req, res) ->
  req.body.should.have.properties 'event', 'data'
  req.body.data.should.have.properties 'category', 'url'
  req.body.data.category.should.eql 'rss'

  res.send ok: 1

module.exports = app
