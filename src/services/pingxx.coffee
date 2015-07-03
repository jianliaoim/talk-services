_ = require 'lodash'
moment = require 'moment-timezone'
service = require '../service'

_receiveWebhook = ({integration, body}) ->
  object = body?.data?.object or {}

  return unless body?.type

  redirectUrl = "https://dashboard.pingxx.com/app/detail?app_id=#{object.app}" if object.app
  texts = []
  title = ''

  switch body?.type
    when 'charge.succeeded'
      title = "付款成功 #{object.subject or ''}"
    when 'refund.succeeded'
      title = "退款成功 #{object.subject or ''}"
    when 'summary.daily.available'
      title = "日统计 #{object.acct_display_name or ''}"
    when 'summary.weekly.available'
      title = "周统计 #{object.acct_display_name or ''}"
    when 'summary.monthly.available'
      title = "月统计 #{object.acct_display_name or ''}"
    else return false

  switch body?.type
    when 'charge.succeeded', 'refund.succeeded'
      texts.push "订单号：#{object.order_no}" if object.order_no
      texts.push "金额：#{object.amount / 100} #{object.currency?.toUpperCase() or ''}" if object.amount
      texts.push "商品描述：#{object.body}" if object.body
      texts.push "订单详情：#{object.description}" if object.description
      texts.push "付款时间：#{moment(object.time_paid * 1000).format('YYYY-MM-DD hh:mm:ss')}" if object.time_paid
      texts.push "失效时间：#{moment(object.time_expire * 1000).format('YYYY-MM-DD hh:mm:ss')}" if object.time_expire
    when 'summary.daily.available', 'summary.weekly.available', 'summary.monthly.available'
      texts.push "交易金额：#{object.charges_amount / 100} 元" if object.charges_amount
      texts.push "交易量：#{object.charges_count} 笔" if object.charges_count
      texts.push "起始时间：#{moment(object.summary_from * 1000).format('YYYY-MM-DD hh:mm:ss')}" if object.summary_from
      texts.push "终止时间：#{moment(object.summary_to * 1000).format('YYYY-MM-DD hh:mm:ss')}" if object.summary_to
    else return false

  message =
    integration: integration
    quote:
      title: title
      text: texts.join '\n'
      redirectUrl: redirectUrl

  @sendMessage message

module.exports = service.register 'pingxx', ->

  @title = 'Ping++'

  @template = 'webhook'

  @summary = service.i18n
    zh: '移动应用支付解决方案'
    en: 'Mobile Payment Solution Provider'

  @description = service.i18n
    zh: 'Ping++ 是为移动应用量身打造的下一代支付系统。移动开发者只需一次性接入 Ping++ 的 SDK，即可快速完成当前主流的支付渠道接入，并可按需定制自己的支付系统。让所有 App接入支付，像大厦接入电力一样简单。
开发者本应专注于产品本身，而不是复杂冗余的支付申请配置流程。Ping++ 为开发者完成这部分繁重的工作，提交一次申请资料+几行代码，即可一次性接入包括支付宝，微信，银联、京东支付、百度钱包、易宝支付、Apple Pay 等在内的多种支付渠道。接入之后，对交易的管理也可以通过统一的管理后台实现。在管理平台上，Ping++ 整合各渠道交易数据，定期提供交易报表，让交易数据一目了然。
Ping++ 致力于成为一个移动互联网经济的基础设施，为每一个 App 提供「支付力」。更多请访问官网 www.pingxx.com 。'
    en: "Ping++ offers integrated mobile payment sdks and one-stop mobile payment solution for any team who are developing mobile app/site and wish to have an easy access to the major payment channels all at once(wechat pay, wechat subscription, alipay, union pay, baidu wallet, JD wallet, and apple pay, soon other international payment channels).

Our products are aimed to help mobile business to accelerate on payment channel development. We take over all the work when payment channel is concerned (apply-link-test-fly), hence the programming team can be more focused and efficient on developing the product itself.

Everyone is welcome to lean on us, to move a bit faster ;)"

  @iconUrl = service.static 'images/icons/pingxx@2x.png'

  @_fields.push
    key: 'webhookUrl'
    type: 'text'
    readOnly: true
    description: service.i18n
      zh: 'Webhook URL'
      en: 'Webhook URL'

  @registerEvent 'service.webhook', _receiveWebhook
