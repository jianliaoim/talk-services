监控告警功能是基于资源层面的监控数据，设置告警条件和通知列表， 有助于及时了解资源使用情况和处理突发事件。

Webhook 可以让你的系统直接收到青云的通知。当监控告警发生时，青云系统会以 HTTP POST 的方式将通知信息发送到指定 URL ，你可以在这个 URL 的接收逻辑中自行处理通知信息。

每加入一条新的 Webhook URL 都需要先进行验证。验证方法是在 URL Response 中返回指定的 token ，一旦通过验证就无需再在 Response 中保留这个 token 。 每个 URL 对于同一个用户只需验证一次。

![webhook 设置界面](/images/inte-guide/sample-qingcloud.png)