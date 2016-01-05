should = require 'should'
Promise = require 'bluebird'

loader = require '../../src/loader'
{req, res} = require '../util'

$rss = loader.load 'rss'

describe 'RSS', ->

  it 'should parse the title and description of rss feed', (done) ->
    req.set 'url', 'http://127.0.0.1:7632/rss/v2ex.xml'
    $rss.then (rss) ->
      rss.receiveApi 'checkRSS', req, res
    .then (body) ->
      body.should.have.properties 'title', 'description'
      body.title.should.eql 'V2EX'
      body.description.should.eql 'way to explore'
    .nodeify done

  it 'should fit for the GBK encoding site', (done) ->
    req.set 'url', 'http://127.0.0.1:7632/rss/baidu.xml'
    $rss.then (rss) ->
      rss.receiveApi 'checkRSS', req, res
    .then (body) ->
      body.title.should.eql '百度国内焦点新闻'
    .nodeify done

  it 'should receive new integration.create', (done) ->
    integration =
      category: 'rss'
      url: 'http://127.0.0.1:7632/rss/baidu.xml'

    req.integration = integration

    $rss.then (rss) -> rss.receiveEvent 'integration.create', req
    .nodeify done
