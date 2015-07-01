should = require 'should'
requireDir = require 'require-dir'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
csdn = service.load 'csdn'

payload = {
  "headers": {
    "x-real-ip": "42.121.112.219",
    "x-forwarded-for": "42.121.112.219",
    "host": "talk.ai",
    "x-nginx-proxy": "true",
    "connection": "Upgrade",
    "content-length": "1128",
    "content-type": "application/json"
  },
  "query": {},
  "body": {
    "before": "5dff974d0fb8cbfd8d8c063050866e0e6593ea70",
    "after": "59acbad155b77f3d03412094aab3877a1ff2887c",
    "ref": "refs/heads/master",
    "commits": [
      {
        "id": "59acbad155b77f3d03412094aab3877a1ff2887c",
        "message": "c\n",
        "timestamp": "2015-06-30T11:24:48+08:00",
        "url": "https://code.csdn.net/white715/webcnn/commit/59acbad155b77f3d03412094aab3877a1ff2887c",
        "author": {
          "name": "lee715",
          "email": "li.l@huiyi-tech.com"
        }
      },
      {
        "id": "e32a60eccbb10f434ed498c0a9b77f366e91a8dc",
        "message": "b\n",
        "timestamp": "2015-06-30T11:24:41+08:00",
        "url": "https://code.csdn.net/white715/webcnn/commit/e32a60eccbb10f434ed498c0a9b77f366e91a8dc",
        "author": {
          "name": "lee715",
          "email": "li.l@huiyi-tech.com"
        }
      }
    ],
    "user_id": 134214,
    "user_name": "white715",
    "repository": {
      "name": "webcnn",
      "url": "git@code.csdn.net:white715/webcnn.git",
      "description": "webcnn",
      "homepage": "https://code.csdn.net/white715/webcnn"
    },
    "total_commits_count": 2
  }
}

testWebhook = (payload, checkMessage) ->
  # Overwrite the sendMessage function of coding
  csdn.sendMessage = checkMessage
  req.body = payload.body
  csdn.receiveEvent 'service.webhook', req

describe 'Csdn#Webhook', ->

  before prepare

  req.integration =
    _id: '552cc903022844e6d8afb3b4'
    category: 'coding'

  it 'receive zen', ->
    testWebhook {}, (message) ->
      throw new Error('Should not response to zen')

  it 'receive push', ->
    testWebhook payload, (message) ->
      message.should.have.properties 'integration', 'quote'
      message.integration._id.should.eql '552cc903022844e6d8afb3b4'
      message.quote.title.should.eql '[webcnn] 提交了新的代码'
      message.quote.text.should.eql [
        '<a href="https://code.csdn.net/white715/webcnn/commit/59acbad155b77f3d03412094aab3877a1ff2887c" target="_blank">'
        '<code>59acba:</code></a> c\n<br>'
        '<a href="https://code.csdn.net/white715/webcnn/commit/e32a60eccbb10f434ed498c0a9b77f366e91a8dc" target="_blank">'
        '<code>e32a60:</code></a> b\n<br>'
      ].join ''
      message.quote.redirectUrl.should.eql 'https://code.csdn.net/white715/webcnn'

  # after cleanup
