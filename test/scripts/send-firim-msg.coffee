request = require 'request'
_ = require 'lodash'

options =
  method: 'POST'
  headers: "Content-Type": "application/json"
  json: true
  url: 'http://talk.bi/v1/services/webhook/75391804bb31576d4a476d65489f3f6d6b5d379a'
  body: {
    "msg": "小叮当的梦想国-更新",
    "icon": "http://firicon.fir.im/3f8e9549b93029b9e18828f67af17b0d77525990",
    "link": "http://fir.im/6gca",
    "name": "小叮当的梦想国",
    "changelog": "测试webhook\r\n测试内容：\r\n修改bug",
    "platform": "Android",
    "build": "2"
  }

request options, (err, res, body) -> console.log body
