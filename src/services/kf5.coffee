_ = require 'lodash'

util = require '../util'

_receiveWebhook = ({integration, query, body}) ->
  payload = _.assign {}
    , query or {}
    , body or {}

  {
    content
    authorName
    title
    text
    redirectUrl
    imageUrl
  } = payload

  throw new Error("Title and text can not be empty") unless title?.length or text?.length or content?.length

  message =
    body: content
    authorName: authorName
    attachments: [
      category: 'quote'
      data:
        title: title
        text: text
        redirectUrl: redirectUrl
        imageUrl: imageUrl
    ]

  message

module.exports = ->

  @title = '逸创云客服'

  @template = 'webhook'

  @summary = util.i18n
    zh: '逸创云客服是一款多客服渠道整合的客服 Saas 产品。'
    en: 'Kf5.com is a Saas helpdesk service converging all support channels.'

  @description = util.i18n
    zh: '逸创云客服是一个聚合邮件、电话语音、IM交谈、移动端/网页表单、微信、微博、API接口、移动SDK等各种支持渠道的云端SaaS客服系统产品，让企业的客服以工单的形式统一响应和管理。'
    en: 'kf5.com is a customer helpdesk SaaS service converging all support channels such as email, voice, livechat, PC/mobile form, wechat, weibo, restful api and mobile sdk, and convert all support requests into ticket, making enterprise agents handling and managing in one place.'

  @iconUrl = util.static 'images/icons/kf5@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readOnly: true
    description: util.i18n
      zh: '复制 web hook 地址到逸创云客服的配置中'
      en: 'Copy and paste this url to start using kf5 webhook'

  @registerEvent 'service.webhook', _receiveWebhook
