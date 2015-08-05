1. 添加自定义机器人后，它会出现在你的团队成员列表中，当成员向机器人发送私聊信息时，机器人会把这条消息通过 POST 请求转发给你配置好的链接（URL）。

  ```json
  {
      "_id": "549908a78cd040715c48caf2",
      "body": "Winter is coming",                    // 消息正文
      "room": {
        "_id": "549908a68cd040715c48cadf",
        "topic": "Game of Throne",                      // 话题名称
        "email": "room.r2e29c2a0@talk.ai"               // 话题绑定邮箱
        // ...
      },
      "creator": {
        "_id": "549908a68cd040715c48cad1",
        "name": "Stack"                                 // 发送者姓名
        // ...
      },
      "_teamId": "549908a68cd040715c48cad3",            // 团队 id
      "createdAt": "2014-12-23T06:16:06.999Z",          // 创建时间
      "updatedAt": "2014-12-23T06:16:06.999Z"           // 更新时间
      // ...
  }
  ```

2. 如果你希望给这条消息发送一个回复，需要以 JSON 格式返回响应内容，在结果中包含以下结构

  ```json
  {
    "content": "Thanks!",                      // 回复消息正文内容（content 与 text 至少有一个参数不为空）
    "text": "Got it",                          // 回复消息附加内容（显示在聚合消息的区域中）
    "authorName": "Little Finger",             // 在回复消息中显示的用户名（可选）
    "redirectUrl": "http://you.service.com"    // 跳转链接（可选）
  }
  ```

  ![](/images/inte-guide/sample-outgoing-1.png)

3. 自定义机器人会绑定一个 Webhook URL，你可以通过这个 URL 发送消息到私聊或话题中。

  ```json
  {
    "content": "Hello",                             // 消息正文
    "_roomId": "559b7f7a57c4d18ad796e1df",          // 指定话题 ID，不可与 _toId 同时存在
    "_toId": "559b7f9357c4d18ad796e1e0",            // 指定私聊对象 ID，不可与 _roomId 同时存在。如果 _roomId 和 _toId 都不存在，消息会自动发送到团队公告板中
    "authorName": "Stack",                          // 消息发送者的姓名，如果留空将显示为机器人的名字
    "title": "Winter is coming",                    // 聚合消息标题
    "text": "",                                     // 聚合消息正文
    "redirectUrl": "https://talk.ai/site",          // 跳转链接
    "thumbnailPicUrl": "http://your.image.url"      // 消息中可添加一张预览图片
  }
  ```
