_ = require 'lodash'
service = require '../service'

_receiveWebhook = ({integration, body}) ->
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
    integration: integration
    quote:
      title: payload.title
      text: texts.join '\n'
      redirectUrl: payload.url
      thumbnailPicUrl: payload.face_url

  @sendMessage message

module.exports = service.register 'jobtong', ->

  @title = '周伯通'

  @template = 'webhook'

  @summary = service.i18n
    zh: '国内最知名的社会化招聘平台之一'
    en: 'A leading recruitment website in China'

  @description = service.i18n
    zh: '周伯通招聘，打造最懂移动互联网的招聘社区。是国内最知名的社会化招聘平台之一，倡导营销化、社会化的招聘服务，引领网络招聘行业新变革。'
    en: 'jobtong.com is a leading recruitment website in China'

  @iconUrl = service.static 'images/icons/jobtong@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readOnly: true
    description: service.i18n
      zh: 'Webhook URL'
      en: 'Webhook URL'

  @registerEvent 'service.webhook', _receiveWebhook
