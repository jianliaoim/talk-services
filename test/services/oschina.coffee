should = require 'should'
requireDir = require 'require-dir'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
oschina = service.load 'oschina'

payload = {
  "headers": {
    "x-real-ip": "124.202.141.60",
    "x-forwarded-for": "124.202.141.60",
    "host": "talk.ai",
    "x-nginx-proxy": "true",
    "connection": "Upgrade",
    "content-length": "994",
    "accept": "*/*; q=0.5, application/xml",
    "accept-encoding": "gzip, deflate",
    "content-type": "application/x-www-form-urlencoded",
    "user-agent": "Ruby"
  },
  "query": {},
  "body": {
    "hook": {
      "password": "tb123",
      "push_data": {
        "before": "fae5f9ec25e1424a733986c2ae0d241fd28556cc",
        "after": "cdc6e27f9b156a9693cb05369cee6a5686dd8f43",
        "ref": "master",
        "user_id": 39550,
        "user_name": "garrett",
        "repository": {
          "name": "webcnn",
          "url": "git@git.oschina.net:344958185/webcnn.git",
          "description": "webcnn",
          "homepage": "http://git.oschina.net/344958185/webcnn"
        },
        "commits": [
          {
            "id": "cdc6e27f9b156a9693cb05369cee6a5686dd8f43",
            "message": "updated readme",
            "timestamp": "2015-07-01T10:14:51+08:00",
            "url": "http://git.oschina.net/344958185/webcnn/commit/cdc6e27f9b156a9693cb05369cee6a5686dd8f43",
            "author": {
              "name": "garrett",
              "email": "344958185@qq.com",
              "time": "2015-07-01T10:14:51+08:00"
            }
          }
        ],
        "total_commits_count": 1
      }
    }
  }
}

testWebhook = (payload, checkMessage) ->
  # Overwrite the sendMessage function of coding
  oschina.sendMessage = checkMessage
  req.body = payload.body
  oschina.receiveEvent 'service.webhook', req

describe 'oschina#Webhook', ->

  before prepare

  req.integration =
    _id: '552cc903022844e6d8afb3b4'
    category: 'oschina'

  it 'receive zen', ->
    testWebhook {}, (message) ->
      throw new Error('Should not response to zen')

  it 'receive push', ->
    testWebhook payload, (message) ->
      message.should.have.properties 'integration', 'quote'
      message.integration._id.should.eql '552cc903022844e6d8afb3b4'
      message.quote.title.should.eql '[webcnn] 提交了新的代码'
      message.quote.text.should.eql [
        '<a href="http://git.oschina.net/344958185/webcnn/commit/cdc6e27f9b156a9693cb05369cee6a5686dd8f43" target="_blank">'
        '<code>cdc6e2:</code></a> updated readme<br>'
      ].join ''
      message.quote.redirectUrl.should.eql 'http://git.oschina.net/344958185/webcnn'

  # after cleanup
