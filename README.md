Talk Services
===

[![NPM version][npm-image]][npm-url]
[![Build Status][travis-image]][travis-url]
[![Talk topic][talk-image]][talk-url]

简聊聚合服务代码与文档

# 文件目录

* `images/` 所有图片文件保存地址，包括每个服务的图标和教程截图，图标以`服务名@2x.png`形式命名，教程以`服务名-序号.png`形式命名

* `manuals/` 所有服务的文字教程地址，每个服务都配有中英文教程，以`服务名-语言.md`形式命名，使用 Markdown 格式编写。教程中引用的文件地址以绝对路径表示，如`/images/inte-guide/jenkins-1.png`

* `src/` 源代码目录，每个服务的业务逻辑代码保存在 `src/services/服务名.coffee` 中

* `test/` 测试代码目录，每个服务的测试代码保存在 `test/services/服务名.coffee` 中，另有一级子目录 `test/services/服务名_assets` 用于保存每个服务的模拟数据

# 开发教程

1. 每个服务都需要在代码中配置相关名称，模板，描述等，例如 `incoming.coffee` 文件中定义的 `Incoming Webhook` 服务

  ```coffee
  module.exports = ->

    # 服务标题，可使用中文名
    @title = 'Incoming Webhook'

    # 服务模板，大部分服务都以 webhook 形式接入简聊，可直接使用 webhook 模板
    @template = 'webhook'

    # 每个服务的简要描述，显示在聚合列表中，需中英文版本
    @summary = util.i18n
      zh: 'Incoming Webhook 是使用普通的 HTTP 请求与 JSON 数据从外部向简聊发送消息的简单方案。'
      en: 'Incoming Webhook makes use of normal HTTP requests with a JSON payload.'

    # 每个服务的详细描述，显示在配置页面中，需中英文版本
    @description = util.i18n
      zh: 'Incoming Webhook 是使用普通的 HTTP 请求与 JSON 数据从外部向简聊发送消息的简单方案。你可以将 Webook 地址复制到第三方服务，通过简单配置来自定义收取相应的推送消息。'
      en: 'Incoming Webhook makes use of normal HTTP requests with a JSON payload. Copy your webhook address to third-party services to configure push notifications.'

    # 服务图标，同为绝对路径表示
    @iconUrl = util.static 'images/icons/incoming@2x.png'

    # 服务需增加的额外字段，如果使用 webhook 模板，需增加 webhookUrl 字段及对应的字段描述
    @_fields.push
      key: 'webhookUrl'
      type: 'text'
      readOnly: true
      description: util.i18n
        zh: '复制 web hook 地址到你的应用中来启用 Incoming Webhook。'
        en: 'To start using incoming webhook, copy this url to your application'

    # 监听服务事件，处理业务逻辑
    @registerEvent 'service.webhook', _receiveWebhook
  ```

2. 监听事件后，可编写相应的业务逻辑代码，例如监听 `service.webhook` 事件，当收到来自第三方服务的 webhook 请求时，会将请求体作为参数传入事件的处理方法中

  ```coffee
  _receiveWebhook = ({query, body}) ->
    # 读取请求中的 query, body 对象
    payload = _.assign {}
      , query or {}
      , body or {}

    {content, authorName, title, text, redirectUrl, imageUrl} = payload

    throw new Error("Title and text can not be empty") unless title?.length or text?.length or content?.length

    # 将请求组合成 message 对象
    message =
      body: content
      authorName: authorName
      displayType: payload.displayType

    # message 对象可以添加附件属性
    if title or text or redirectUrl or imageUrl
      message.attachments = [
        category: 'quote'
        data:
          title: title
          text: text
          redirectUrl: redirectUrl
          imageUrl: imageUrl
      ]

    # 在方法最后返回 message 对象，API 将此对象包装后推送给客户端
    # 如果方法中返回 null, false, undefined，API 将忽略这次请求而不推送任何消息
    message
  ```

3. 支持的事件列表

| 事件名                        | 事件处理方法参数               | 需要的返回值               | 描述                          |
|------------------------------|------------------------------|--------------------------|--------------------------------------|
| `integration.create`         | 包含 `integration` 属性的 `req` 对象 |                          | 创建聚合后触发  |
| `integration.update`         | 包含 `integration` 属性的 `req` 对象 |                          | 更新聚合后触发  |
| `integration.remove`         | 包含 `integration` 属性的 `req` 对象 |                          | 删除聚合后出发  |
| `service.webhook`            | `req` 对象                         | 如返回 message 对象，则推送消息到客户端 | 当收到 webhook 请求时触发 |
| `before.integration.create`  | 包含 `integration` 属性的 `req` 对象 |                          | 创建聚合前触发 |
| `before.integration.update`  | 包含 `integration` 属性的 `req` 对象 |                          | 更新聚合前触发 |
| `before.integration.remove`  | 包含 `integration` 属性的 `req` 对象 |                          | 删除聚合前触发 |
| `message.create`             | 包含 `message` 属性的 `req` 对象      | 如返回 message 对象，会发送一条回复消息给消息来源方 | 新消息时触发 |

# 代码测试

1. 每个服务需要有对应的测试代码，大部分代码可用模拟数据测试，如测试 incoming webhook

  ```coffee
  should = require 'should'
  Promise = require 'bluebird'

  loader = require '../../src/loader'  # 加载 loader
  {req} = require '../util'            # 从 util 中取得模拟的 req 对象
  $incoming = loader.load 'incoming'   # 从 loader 加载对应服务

  describe 'Incoming#Webhook', ->

    it 'receive webhook', (done) ->
      # 模拟 webhook 请求结构体
      req.body =
        authorName: '路人甲'
        title: '你好'
        text: '天气不错'
        redirectUrl: 'https://talk.ai/site'
        imageUrl: 'https://dn-talk.oss.aliyuncs.com/site/images/workspace-84060cfd.jpg'

      $incoming.then (incoming) ->

        # 触发 service.webhook 事件
        incoming.receiveEvent 'service.webhook', req

      .then (message) ->

        # 检测返回结果是否正确
        message.should.have.properties 'authorName'
        message.attachments[0].data.should.have.properties 'title', 'text', 'redirectUrl', 'imageUrl'

      .nodeify done
  ```

[npm-url]: https://npmjs.org/package/talk-services
[npm-image]: http://img.shields.io/npm/v/talk-services.svg

[travis-url]: https://travis-ci.org/teambition/talk-services
[travis-image]: http://img.shields.io/travis/teambition/talk-services.svg

[talk-url]: https://guest.talk.ai/rooms/4f5dc4b04w
[talk-image]: https://img.shields.io/talk/t/4f5dc4b04w.svg
