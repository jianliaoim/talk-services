request = require 'request'
_ = require 'lodash'

options =
  method: 'POST'
  headers: "Content-Type": "application/json"
  json: true
  url: 'http://talk.ci/v2/services/webhook/57c732af45437c0cbfe87efe8236cc71cedf8d4d'
  body: {
    "body": "",
    "title": "消息标题",
    "text": "消息内容"
  }

request options, (err, res, body) -> console.log body
