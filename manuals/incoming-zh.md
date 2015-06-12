**第一步** 生成的webhook地址为 [LOCALE_LINK](LOCALE_LINK)
该 WebHook 地址收到 POST 请求时，对应的话题中将收到推送通知，请求字段和内容可参考下例：

```json
{
  "authorName": "Stack",                          // 消息发送者的姓名，如果留空将显示为配置中的聚合标题
  "title": "Winter is coming",                    // 聚合消息标题
  "text": "",                                     // 聚合消息正文
  "redirectUrl": "https://talk.ai/site",          // 跳转链接
  "imageUrl": "http://your.image.url"             // 消息中可添加一张预览图片
}
```

以下例子使用 curl 请求：

```shell
curl -d authorName=小艾 -d title=大家好 -d text=打个招呼吧 -d redirectUrl=https://talk.ai/site LOCALE_LINK
```

**第二步** 填写 Incoming Webhook 自定义名称、描述和头像。
修改后点击保存。消息将如下图所示

![](images/inte-guide/notice-webhook.png)
