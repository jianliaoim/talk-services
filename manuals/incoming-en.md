**First Step** WebHook link is [LOCALE_LINK](LOCALE_LINK)
When WebHook receive POST request, the selected topic will receive notification. Here's an example for request-header field and content.

```json
{
  "authorName": "Stack",                          // 消息发送者的姓名，如果留空将显示为配置中的聚合标题
  "title": "Winter is coming",                    // 聚合消息标题
  "text": "",                                     // 聚合消息正文
  "redirectUrl": "https://talk.ai/site",          // 跳转链接
  "imageUrl": "http://your.image.url"             // 消息中可添加一张预览图片
}
```

Here's another example for curl request.

```shell
curl -d authorName=小艾 -d title=大家好 -d text=打个招呼吧 -d redirectUrl=https://talk.ai/site LOCALE_LINK
```

**Second Step** Customize name, description and icon. Save your preference.
WebHook integration message will be pushed to selected topics as the picture below.
![](images/inte-guide/notice-webhook.png)
