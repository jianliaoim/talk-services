当被绑定话题中成员发送消息时（聚合消息，系统消息与文件上传不在此列），简聊会给你配置的链接发送一个 POST 请求

消息结构

```json
{
    "_id": "549908a78cd040715c48caf2",
    "content": "Winter is coming",                    // 消息正文
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
```

如果你希望给这条消息发送一个回复，需要以 JSON 格式返回响应内容，在结果中包含以下结构

```json
{
  "content": "Got it",                // 回复消息内容
  "username": "Little Finger"         // 在回复消息中显示的用户名（可选）
}
```

