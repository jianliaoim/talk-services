should = require 'should'
Promise = require 'bluebird'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
talkai = service.load 'talkai'

describe 'Talkai#MessageCreate', ->

  before prepare

  it 'receive content', (done) ->
    talkai.sendMessage = (message) ->
      message.should.have.properties '_creatorId', '_toId', 'content', '_teamId'
      message.content.should.eql '我不会说英语的啦，你还是说中文吧。'
      done()

    message =
      _toId: talkai.robot._id
      _creatorId: 1
      _teamId: 2
      content: 'faefafnak'

    talkai.receiveEvent 'message.create', message

  it 'receive URL content', (done) ->
    talkai.sendMessage = (message) ->
      message.should.have.properties '_creatorId', '_toId', 'quote', '_teamId'
      message.quote.should.have.properties 'title', 'redirectUrl'
      done()

    message =
      _toId: talkai.robot._id
      _creatorId: 1
      _teamId: 2
      content: '周杰伦的照片'

    talkai.receiveEvent 'message.create', message

  it 'receive train content', (done) ->
    talkai.sendMessage = (message) ->
      message.should.have.properties '_creatorId', '_toId', 'quote', '_teamId'
      message.quote.should.have.properties 'title', 'text'
      done()

    message =
      _toId: talkai.robot._id
      _creatorId: 1
      _teamId: 2
      content: '体育新闻'

    talkai.receiveEvent 'message.create', message

  it 'receive train content', (done) ->
    talkai.sendMessage = (message) ->
      message.should.have.properties '_creatorId', '_toId', 'quote', '_teamId'
      message.quote.should.have.properties 'title', 'text'
      done()

    message =
      _toId: talkai.robot._id
      _creatorId: 1
      _teamId: 2
      content: '上海到北京的火车'

    talkai.receiveEvent 'message.create', message

  it 'receive other content', (done) ->
    talkai.sendMessage = (message) ->
      message.should.have.properties '_creatorId', '_toId', 'quote', '_teamId'
      message.quote.should.have.properties 'title', 'text'
      done()

    message =
      _toId: talkai.robot._id
      _creatorId: 1
      _teamId: 2
      content: '红烧肉怎么做'

    talkai.receiveEvent 'message.create', message
  after cleanup
