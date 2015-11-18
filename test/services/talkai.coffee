should = require 'should'
Promise = require 'bluebird'
_ = require 'lodash'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
talkai = service.load 'talkai'
config = require '../config'

describe 'Talkai#MessageCreate', ->

  unless config.talkai
    return console.error """
    Turing key is not exist
    Add it in config.json to test talkai service
    """

  talkai.config = _.assign talkai.config, config.talkai

  @timeout 5000

  before prepare

  it 'receive body', (done) ->
    talkai.sendMessage = (message) ->
      message.should.have.properties '_creatorId', '_toId', 'body', '_teamId'
      message.body.should.eql '我不会说英语的啦，你还是说中文吧。'
      done()

    message =
      _toId: talkai.robot._id
      _creatorId: 1
      _teamId: 2
      body: 'faefafnak'

    talkai.receiveEvent 'message.create', message

  it 'receive URL body', (done) ->
    talkai.sendMessage = (message) ->
      message.should.have.properties '_creatorId', '_toId', 'attachments', '_teamId'
      message.attachments[0].data.should.have.properties 'title', 'redirectUrl'
      message.attachments[0].data.title.indexOf('undefined').should.below 0
      message.attachments[0].data.redirectUrl.indexOf('undefined').should.below 0
      done()

    message =
      _toId: talkai.robot._id
      _creatorId: 1
      _teamId: 2
      body: '周杰伦的照片'

    talkai.receiveEvent 'message.create', message

  it 'receive train body', (done) ->
    talkai.sendMessage = (message) ->
      message.should.have.properties '_creatorId', '_toId', 'attachments', '_teamId'
      message.attachments[0].data.should.have.properties 'title', 'text'
      message.attachments[0].data.title.indexOf('undefined').should.below 0
      message.attachments[0].data.text.indexOf('undefined').should.below 0
      done()

    message =
      _toId: talkai.robot._id
      _creatorId: 1
      _teamId: 2
      body: '体育新闻'

    talkai.receiveEvent 'message.create', message

  it 'receive train body', (done) ->
    talkai.sendMessage = (message) ->
      message.should.have.properties '_creatorId', '_toId', 'attachments', '_teamId'
      message.attachments[0].data.should.have.properties 'title'
      message.attachments[0].data.title.indexOf('undefined').should.below 0
      done()

    message =
      _toId: talkai.robot._id
      _creatorId: 1
      _teamId: 2
      body: '上海到北京的火车'

    talkai.receiveEvent 'message.create', message

  it 'receive flight body', (done) ->
    talkai.sendMessage = (message) ->
      message.should.have.properties '_creatorId', '_toId', 'attachments', '_teamId'
      message.attachments[0].data.should.have.properties 'title'
      done()

    message =
      _toId: talkai.robot._id
      _creatorId: 1
      _teamId: 2
      body: '明天从北京到上海的飞机'

    talkai.receiveEvent 'message.create', message

  it 'receive other body', (done) ->
    talkai.sendMessage = (message) ->
      message.should.have.properties '_creatorId', '_toId', 'attachments', '_teamId'
      message.attachments[0].data.should.have.properties 'title', 'text'
      message.attachments[0].data.title.indexOf('undefined').should.below 0
      message.attachments[0].data.text.indexOf('undefined').should.below 0
      done()

    message =
      _toId: talkai.robot._id
      _creatorId: 1
      _teamId: 2
      body: '红烧肉怎么做'

    talkai.receiveEvent 'message.create', message

  after cleanup
