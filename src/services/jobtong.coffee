_ = require 'lodash'
util = require '../util'

_receiveWebhook = ({body}) ->
  payload = body or {}

  texts = []

  texts.push "性别：#{payload.sex}" if payload.sex
  texts.push "年龄：#{payload.age}" if payload.age
  texts.push "学历：#{payload.degree}" if payload.degree
  texts.push "经验年限：#{payload.experience}" if payload.experience
  texts.push "当前公司：#{payload.company}" if payload.company
  texts.push "当前职位：#{payload.job_name}" if payload.job_name
  texts.push "简历投递日期：#{payload.apply_at}" if payload.apply_at

  message =
    attachments: [
      category: 'quote'
      data:
        title: payload.title
        text: texts.join '\n'
        redirectUrl: payload.url
        imageUrl: payload.face_url
    ]

  message

module.exports = ->

  @title = '周伯通招聘'

  @template = 'webhook'

  @summary = util.i18n
    zh: '周伯通，招人喜欢'
    en: 'Jobtong makes job search more enjoyable.'

  @description = util.i18n
    zh: '周伯通招聘（ http://www.jobtong.com ），2014年重装上阵，打造最懂互联网的招聘社区。是国内最知名的社会化招聘平台之一，倡导营销化、社会化的招聘服务，引领网络招聘行业新变革！'
    en: "Jobtong (http://www.jobtong.com), starting in 2014, is trying to build a recruitment community that is most familiar with Internet. It's one of the most famous social recruitment platform in China. We are advocacing marketing and socialization recruitment services and leading the new revolution of online recruitment industry!"

  @iconUrl = util.static 'images/icons/jobtong@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readOnly: true
    description: util.i18n
      zh: 'Webhook URL'
      en: 'Webhook URL'

  @registerEvent 'service.webhook', _receiveWebhook
