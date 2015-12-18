should = require 'should'
loader = require '../../src/loader'
{req} = require '../util'
$mikecrm = loader.load 'mikecrm'

describe 'MikeCRM#Webhook', ->

  it 'receive webhook', (done) ->

    req.body = {
      "headers": {
        "x-real-ip": "42.121.6.107",
        "x-forwarded-for": "42.121.6.107",
        "host": "jianliao.com",
        "x-nginx-proxy": "true",
        "connection": "Upgrade",
        "content-length": "818",
        "accept": "*/*",
        "content-type": "application/json"
      },
      "query": {},
      "body": {
        "form": {
          "name": "新的表单",
          "title": "麦田剧社招新啦！",
          "subtitle": "人生入戏，戏如人生；在舞台上，感受别样人生！",
          "url": "http://www.mikecrm.com/formFeedback.php?ID=284153"
        },
        "component": {
          "0": {
            "name": "basic_name",
            "title": "姓名",
            "value": "xingming"
          },
          "1": {
            "name": "basic_gender",
            "title": "性别",
            "value": "帅哥"
          },
          "2": {
            "name": "id_number",
            "title": "学号",
            "value": "1213121313"
          },
          "3": {
            "name": "basic_company",
            "title": "专业院系",
            "value": "xueyuan"
          },
          "4": {
            "name": "basic_mobile",
            "title": "手机",
            "value": "1333333333"
          },
          "5": {
            "name": "id_checkBox",
            "title": "可接受的面试时间",
            "value": {
              "0": "周一",
              "1": "周二"
            }
          },
          "6": {
            "name": "id_multiple",
            "title": "自我评价一下吧！",
            "value": "ziwopingjia"
          },
          "7": {
            "name": "id_multiple",
            "title": "有没有什么爱好及特长",
            "value": "aihaotechang"
          }
        }
      }
    }

    req.integration = _id: 1

    $mikecrm.then (mikecrm) -> mikecrm.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql 'MikeCRM: 新的表单 麦田剧社招新啦！'
      message.attachments[0].data.text.should.eql '''
      姓名 : xingming
      性别 : 帅哥
      学号 : 1213121313
      专业院系 : xueyuan
      手机 : 1333333333
      可接受的面试时间 : 周一,周二
      自我评价一下吧！ : ziwopingjia
      有没有什么爱好及特长 : aihaotechang
      '''
      message.attachments[0].data.redirectUrl.should.eql 'http://www.mikecrm.com/formFeedback.php?ID=284153'
    .nodeify done
