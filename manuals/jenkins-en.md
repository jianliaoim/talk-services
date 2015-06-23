1. 进入 Jenkins 首页，点击左侧系统管理链接

  ![](/images/inte-guide/jenkins-1.png)

2. 选择管理插件

  ![](/images/inte-guide/jenkins-2.png)

3. 搜索 'jianliao'，安装简聊插件

  ![](/images/inte-guide/jenkins-3.png)

4. 安装完成后进入系统设置，配置聚合 Webhook 链接和 jenkins 域名以备简聊能正确的跳转回 jenkins

  ![](/images/inte-guide/jenkins-4.png)

  ![](/images/inte-guide/jenkins-5.png)

5. 在项目中选择配置菜单，在 Jianliao Notifications 中选择你希望收到推送的事件，也可以此任务配置单独的 Webhook 链接

  ![](/images/inte-guide/jenkins-6.png)

  ![](/images/inte-guide/jenkins-7.png)

6. 配置完成后，就可以等待简聊推送构建任务信息啦

  ![](/images/inte-guide/jenkins-8.png)
