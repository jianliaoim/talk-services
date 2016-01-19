should = require 'should'
loader = require '../../src/loader'
{req} = require '../util'
$mikecrm = loader.load 'mikecrm'

describe 'MikeCRM#Webhook', ->

  it 'receive webhook', (done) ->
    req.body = {
      "form": {
        "name": "hello",
        "title": "麦客宣讲会活动报名表",
        "subtitle": "9月12日，看麦客如何“重新定义信息收集”！",
        "url": "http://www.mikecrm.com/formFeedback.php?ID=566933"
      },
      "component": {
        "0": {
          "name": "basic_name",
          "title": "您的姓名",
          "value": "测试"
        },
        "1": {
          "name": "basic_email",
          "title": "E-mail",
          "value": "ceshi@teambition.com"
        },
        "2": {
          "name": "basic_mobile",
          "title": "联系电话",
          "value": "18700004300"
        }
      }
    }

    req.integration = _id: 1

    $mikecrm.then (mikecrm) -> mikecrm.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql 'MikeCRM: hello 麦客宣讲会活动报名表'
      message.attachments[0].data.text.should.eql '''
      您的姓名 : 测试
      E-mail : ceshi@teambition.com
      联系电话 : 18700004300
      '''
      message.attachments[0].data.redirectUrl.should.eql 'http://www.mikecrm.com/formFeedback.php?ID=566933'
    .nodeify done
