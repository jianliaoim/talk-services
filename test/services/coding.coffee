should = require 'should'
requireDir = require 'require-dir'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
coding = service.load 'coding'

payloads = requireDir './coding_assets'

describe 'Coding#Webhook', ->

  before prepare

  req.integration =
    _id: '552cc903022844e6d8afb3b4'
    category: 'coding'

  it 'receive zen', (done) ->
    coding.sendMessage = (message) -> throw new Error('Should not response to zen')

    req.body = payloads.zen
    req.headers = "x-coding-event": "ping"
    coding.receiveEvent 'service.webhook', req
    .then -> done()
    .catch done

  it 'receive push', (done) ->
    # Overwrite the sendMessage function of coding
    coding.sendMessage = (message) ->
      message.should.have.properties '_integrationId', 'quote'
      message._integrationId.should.eql '552cc903022844e6d8afb3b4'
      message.quote.title.should.eql '项目 test-webhook 中提交了新的代码'
      message.quote.text.should.eql [
        '<a href="https://coding.net/u/sailxjx/p/test-webhook/git/commit/5e321dae429679a4b9ad9e06b543eed5610ff9af" target="_blank">'
        '<code>5e321d:</code></a> Merge branch \'newbb\'<br>'
        '<a href="https://coding.net/u/sailxjx/p/test-webhook/git/commit/1b6019319ab12d432108d65caa018a37f062f306" target="_blank">'
        '<code>1b6019:</code></a> add makefile<br>'
      ].join ''
      message.quote.redirectUrl.should.eql 'https://coding.net/u/sailxjx/p/test-webhook'

    req.body = payloads.push
    req.headers = "x-coding-event": "push"
    coding.receiveEvent 'service.webhook', req
    .then -> done()
    .catch done

  it 'receive member', (done) ->
    coding.sendMessage = (message) ->
      message.quote.title.should.eql "项目 test-webhook 中添加了新的成员 coding"
      message.quote.redirectUrl.should.eql 'https://coding.net/u/sailxjx/p/test-webhook/members/coding'

    req.body = payloads.member
    req.headers = "x-coding-event": "member"
    coding.receiveEvent 'service.webhook', req
    .then -> done()
    .catch done

  it 'receive task', (done) ->
    coding.sendMessage = (message) ->
      message.quote.title.should.eql "项目 test-webhook 中添加了新的任务"
      message.quote.text.should.eql '测试'
      message.quote.redirectUrl.should.eql 'https://coding.net/u/sailxjx/p/test-webhook/tasks'

    req.body = payloads.task
    req.headers = 'x-coding-event': 'task'
    coding.receiveEvent 'service.webhook', req
    .then -> done()
    .catch done

  it 'receive update task deadline', (done) ->
    coding.sendMessage = (message) ->
      message.quote.title.should.eql '项目 test-webhook 中更新了任务的截止日期 2015-04-30'
      message.quote.text.should.eql '测试'
      message.quote.redirectUrl.should.eql 'https://coding.net/u/sailxjx/p/test-webhook/tasks'

    req.body = payloads.update_task_deadline
    req.headers = 'x-coding-event': 'task'
    coding.receiveEvent 'service.webhook', req
    .then -> done()
    .catch done

  it 'receive update task priority', (done) ->
    coding.sendMessage = (message) ->
      message.quote.title.should.eql '项目 test-webhook 中更新了任务的优先级 正常处理'
      message.quote.text.should.eql '测试'
      message.quote.redirectUrl.should.eql 'https://coding.net/u/sailxjx/p/test-webhook/tasks'
    req.body = payloads.update_task_priority
    req.headers = 'x-coding-event': 'task'
    coding.receiveEvent 'service.webhook', req
    .then -> done()
    .catch done

  it 'should emit an error when the integration token isnt equals to payload token', (done) ->
    req.body = payloads.push
    req.integration =
      _id: '552cc903022844e6d8afb3b3'
      category: 'coding'
      token: 'cba'
    coding.receiveEvent 'service.webhook', req
    .catch (err) ->
      err.message.should.eql 'Invalid token'
      done()

  after cleanup
