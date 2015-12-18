should = require 'should'
loader = require '../../src/loader'
{req} = require '../util'
$jobtong = loader.load 'jobtong'

describe 'Jobtong#Webhook', ->

  it 'receive webhook', (done) ->
    req.body =
      'url': 'http://www.url.com'
      'title': '天朝来的求职者'
      'face_url': 'http://www.face.com'
      'sex': 'gay'
      'age': '0'
      'degree': '小学辍学'
      'experience': '+10086'
      'company': '宇宙真理公司'
      'job_name': '酱油'
      'apply_at': "2015-07-02T02:52:55.563Z"
    req.integration = _id: 1

    $jobtong.then (jobtong) ->
      jobtong.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql '天朝来的求职者'
      message.attachments[0].data.text.should.eql """
      性别：gay
      年龄：0
      学历：小学辍学
      经验年限：+10086
      当前公司：宇宙真理公司
      当前职位：酱油
      简历投递日期：2015-07-02T02:52:55.563Z
      """
      message.attachments[0].data.redirectUrl.should.eql 'http://www.url.com'
      message.attachments[0].data.imageUrl.should.eql 'http://www.face.com'
    .nodeify done
