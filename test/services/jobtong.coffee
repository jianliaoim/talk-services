should = require 'should'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
jobtong = service.load 'jobtong'

describe 'Jobtong#Webhook', ->

  before prepare

  it 'receive webhook', (done) ->
    jobtong.sendMessage = (message) ->
      message.quote.title.should.eql '天朝来的求职者'
      message.quote.text.should.eql """
      性别：gay
      年龄：0
      学历：小学辍学
      经验年限：+10086
      当前公司：宇宙真理公司
      当前职位：酱油
      简历投递日期：2015-07-02T02:52:55.563Z
      """
      message.quote.redirectUrl.should.eql 'http://www.url.com'
      message.quote.thumbnailPicUrl.should.eql 'http://www.face.com'
      done()

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

    jobtong.receiveEvent 'service.webhook', req
    .catch done

  after cleanup
