你可以在项目中配置 [circle.yml](https://circleci.com/docs/configuration#notify) 来让 Circle CI 构建后发送 Webhook 请求：

```yml
notify:
  webhooks:
    # A list of hook hashes, containing the url field
    - url: LOCALE_LINK
```
