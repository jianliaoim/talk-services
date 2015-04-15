should = require 'should'
fs = require 'fs'
express = require 'express'
service = require '../../src/service'
{prepare, cleanup, req, res} = require '../util'
rss = service.load 'rss'

app = express()

app.use '/:feed', (req, res) ->
  {feed} = req.params
  res.send(fs.readFileSync "#{__dirname}/rss_assets/#{feed}")

describe 'RSS#CheckRSS', ->

  _server = null

  before (done) ->
    prepare (err) ->
      return done(err) if err
      _server = app.listen 3333, done

  it 'should parse the title and description of rss feed', (done) ->
    req.set 'url', 'http://localhost:3333/v2ex.xml'
    rss.receiveApi 'checkRSS', req, res
    .then (body) ->
      body.should.have.properties 'title', 'description'
      body.title.should.eql 'V2EX'
      body.description.should.eql 'way to explore'
      done()
    .catch done

  it 'should fit for the GBK encoding site', (done) ->
    req.set 'url', 'http://localhost:3333/baidu.xml'
    rss.receiveApi 'checkRSS', req, res
    .then (body) ->
      body.title.should.eql '百度国内焦点新闻'
      done()
    .catch done

  after (done) ->
    cleanup (err) ->
      return done(err) if err
      _server.close done
