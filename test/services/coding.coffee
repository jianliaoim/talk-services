should = require 'should'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
coding = service.load 'coding'

payload = {
  "after": "5e321dae429679a4b9ad9e06b543eed5610ff9af",
  "ref": "master",
  "token": "abc",
  "repository": {
    "description": "test webhook",
    "name": "test-webhook",
    "url": "https://coding.net/u/sailxjx/p/test-webhook/git"
  },
  "before": "494fc9037544d04ba0a55cc38b377f021f155c23",
  "commits": [
    {
      "sha": "5e321dae429679a4b9ad9e06b543eed5610ff9af",
      "short_message": "Merge branch 'newbb'",
      "committer": {
        "email": "sailxjx@gmail.com",
        "name": "Xu Jingxin"
      }
    },
    {
      "sha": "1b6019319ab12d432108d65caa018a37f062f306",
      "short_message": "add makefile",
      "committer": {
        "email": "sailxjx@gmail.com",
        "name": "Xu Jingxin"
      }
    }
  ]
}

describe 'Coding#Webhook', ->

  before prepare

  it 'should create new message when receive a webhook request with a push payload', (done) ->
    # Overwrite the sendMessage function of coding
    coding.sendMessage = (message) ->
      message.should.have.properties '_integrationId', 'quote'
      message._integrationId.should.eql '552cc903022844e6d8afb3b4'
      message.quote.title.should.eql '来自 Coding 的事件'
      message.quote.text.should.eql [
        '在项目 test-webhook 中提交了新的代码<br>'
        '<a href="https://coding.net/u/sailxjx/p/test-webhook/git/commit/5e321dae429679a4b9ad9e06b543eed5610ff9af" target="_blank">'
        '<code>5e321d:</code></a> Merge branch \'newbb\'<br>'
        '<a href="https://coding.net/u/sailxjx/p/test-webhook/git/commit/1b6019319ab12d432108d65caa018a37f062f306" target="_blank">'
        '<code>1b6019:</code></a> add makefile<br>'
      ].join ''
      done()

    req.body = payload
    req.integration =
      _id: '552cc903022844e6d8afb3b4'
      category: 'coding'
    coding.receiveEvent 'service.webhook', req

  it 'should emit an error when the integration token isnt equals to payload token', (done) ->
    req.body = payload
    req.integration =
      _id: '552cc903022844e6d8afb3b3'
      category: 'coding'
      token: 'cba'
    coding.receiveEvent 'service.webhook', req
    .catch (err) ->
      err.message.should.eql 'Invalid token'
      done()

  after cleanup
