
**第一步** 登录[github](https://github.com/)，选择一个你想要接受通知的repository；点击"Setting"，会有下面图示显示；找到并点击左侧的 `Webhook & services` 选项
![](/images/inte-guide/sample-githubwebhook-1.png)

**第二步** 点击上一个图片中显示的 `Add webhook` 按钮；会显示下面这个让你进行确认的页面；输入密码进行到下一步的设置
![](/images/inte-guide/sample-githubwebhook-2.png)

**第三步** 复制 [LOCALE_LINK](LOCALE_LINK) 到 `Payload URL`，然后在 `which events would you like to trigger this webhook?` 这一栏自定义你想要进行通知的events。
![](/images/inte-guide/sample-githubwebhook-3.png)

**第四步** 回到简聊，你可以为金数据聚合自定义名称、描述和头像。修改后点击保存。