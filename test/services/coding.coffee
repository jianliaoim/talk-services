should = require 'should'
requireDir = require 'require-dir'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
coding = service.load 'coding'

payloads = requireDir './coding_assets'

testWebhook = (event, payload, checkMessage) ->
  # Overwrite the sendMessage function of coding
  coding.sendMessage = checkMessage
  req.body = payload
  req.headers = 'x-coding-event': event
  coding.receiveEvent 'service.webhook', req

describe 'Coding#Webhook', ->

  before prepare

  req.integration =
    _id: '552cc903022844e6d8afb3b4'
    category: 'coding'

  it 'receive zen', ->
    testWebhook 'ping', payloads.zen, (message) ->
      throw new Error('Should not response to zen')

  it 'receive push', ->
    testWebhook 'push', payloads.push, (message) ->
      message.should.have.properties '_integrationId', 'quote'
      message._integrationId.should.eql '552cc903022844e6d8afb3b4'
      message.quote.title.should.eql '[test-webhook] 提交了新的代码'
      message.quote.text.should.eql [
        '<a href="https://coding.net/u/sailxjx/p/test-webhook/git/commit/5e321dae429679a4b9ad9e06b543eed5610ff9af" target="_blank">'
        '<code>5e321d:</code></a> Merge branch \'newbb\'<br>'
        '<a href="https://coding.net/u/sailxjx/p/test-webhook/git/commit/1b6019319ab12d432108d65caa018a37f062f306" target="_blank">'
        '<code>1b6019:</code></a> add makefile<br>'
      ].join ''
      message.quote.redirectUrl.should.eql 'https://coding.net/u/sailxjx/p/test-webhook'

  it 'receive member', ->
    testWebhook 'member', payloads.member, (message) ->
      message.quote.title.should.eql "[test-webhook] sailxjx 添加了新的成员 coding"
      message.quote.redirectUrl.should.eql 'https://coding.net/u/sailxjx/p/test-webhook/members/coding'

  it 'receive task', ->
    testWebhook 'task', payloads.task, (message) ->
      message.quote.title.should.eql "[test-webhook] sailxjx 添加了新的任务 测试"
      message.quote.redirectUrl.should.eql 'https://coding.net/u/sailxjx/p/test-webhook/tasks'

  it 'receive update task deadline', ->
    testWebhook 'task', payloads.update_task_deadline, (message) ->
      message.quote.title.should.eql '[test-webhook] sailxjx 更新了任务 测试 的截止日期 2015-04-30'
      message.quote.redirectUrl.should.eql 'https://coding.net/u/sailxjx/p/test-webhook/tasks'

  it 'receive update task priority', ->
    testWebhook 'task', payloads.update_task_priority, (message) ->
      message.quote.title.should.eql '[test-webhook] sailxjx 更新了任务 测试 的优先级 正常处理'
      message.quote.redirectUrl.should.eql 'https://coding.net/u/sailxjx/p/test-webhook/tasks'

  it 'receive reassign task', ->
    testWebhook 'task', payloads.reassign_task, (message) ->
      message.quote.title.should.eql '[test-webhook] sailxjx 将任务 测试 指派给 coding'
      message.quote.redirectUrl.should.eql 'https://coding.net/u/sailxjx/p/test-webhook/tasks'

  it 'receive finish task', ->
    testWebhook 'task', payloads.finish_task, (message) ->
      message.quote.title.should.eql '[test-webhook] sailxjx 完成了任务 测试'

  it 'receive restore task', ->
    testWebhook 'task', payloads.restore_task, (message) ->
      message.quote.title.should.eql '[test-webhook] sailxjx 重做了任务 测试'

  it 'receive new topic', ->
    testWebhook 'topic', payloads.new_topic, (message) ->
      message.quote.title.should.eql '[test-webhook] sailxjx 发起了新的话题 新项目讨论'
      message.quote.redirectUrl.should.eql 'https://coding.net/u/sailxjx/p/test-webhook/topic/29644'

  it 'receive update topic', ->
    testWebhook 'topic', payloads.update_topic, (message) ->
      message.quote.title.should.eql '[test-webhook] sailxjx 更新了话题 新项目讨论'
      message.quote.redirectUrl.should.eql "https://coding.net/u/sailxjx/p/test-webhook/topic/29644"

  it 'receive create dir', ->
    testWebhook 'document', payloads.create_dir, (message) ->
      message.quote.title.should.eql '[test-webhook] sailxjx 创建了新的文件夹 新建文件夹'
      message.quote.redirectUrl.should.eql "https://coding.net/u/sailxjx/p/test-webhook/attachment/default/preview/156105"

  it 'receive upload file', ->
    testWebhook 'document', payloads.upload_file, (message) ->
      message.quote.title.should.eql '[test-webhook] sailxjx 上传了新的文件 4.jpg'
      message.quote.redirectUrl.should.eql 'https://coding.net/u/sailxjx/p/test-webhook/attachment/default/preview/156107'

  it 'receive update dir', ->
    testWebhook 'document', payloads.update_dir, (message) ->
      message.quote.title.should.eql '[test-webhook] sailxjx 更新了文件夹 测试'
      message.quote.redirectUrl.should.eql 'https://coding.net/u/sailxjx/p/test-webhook/attachment/default/preview/156104'

  it 'receive watch', ->
    testWebhook 'watch', payloads.watch, (message) ->
      message.quote.title.should.eql '[alalalalalala] jiyinyiyong 关注了项目'
      message.quote.redirectUrl.should.eql 'https://coding.net/u/sailxjx/p/alalalalalala'

  it 'receive star', ->
    testWebhook 'star', payloads.star, (message) ->
      message.quote.title.should.eql '[alalalalalala] sailxjx 收藏了项目'
      message.quote.redirectUrl.should.eql 'https://coding.net/u/sailxjx/p/alalalalalala'

  it 'receive merge_request', ->
    testWebhook 'merge_request', payloads.merge_request, (message) ->
      message.quote.title.should.eql "[test-webhook] 新的 merge_request 请求 标题标题"
      message.quote.text.should.eql '<ul>\n<li>cccccc</li>\n<li>1</li>\n<li>2</li>\n</ul>\n'
      message.quote.redirectUrl.should.eql 'https://coding.net/u/sailxjx/p/test-webhook/git/merge/5'

  it 'receive refuse merge_request', ->
    testWebhook 'merge_request', payloads.refuse_merge_request, (message) ->
      message.quote.title.should.eql "[test-webhook] 拒绝了 merge_request 请求 标题标题"
      message.quote.text.should.eql '<ul>\n<li>cccccc</li>\n<li>1</li>\n<li>2</li>\n</ul>\n'
      message.quote.redirectUrl.should.eql 'https://coding.net/u/sailxjx/p/test-webhook/git/merge/5'

  it 'receive merge merge_request', ->
    testWebhook 'merge_request', payloads.merge_merge_request, (message) ->
      message.quote.title.should.eql "[test-webhook] 合并了 merge_request 请求 啊啊啊啊"
      message.quote.text.should.eql '<ul>\n<li>cccccc</li>\n</ul>\n'
      message.quote.redirectUrl.should.eql 'https://coding.net/u/sailxjx/p/test-webhook/git/merge/6'

  it 'should emit an error when the integration token isnt equals to payload token', ->
    req.body = payloads.push
    req.integration =
      _id: '552cc903022844e6d8afb3b3'
      category: 'coding'
      token: 'cba'
    coding.receiveEvent 'service.webhook', req
    .catch (err) -> err.message.should.eql 'Invalid token'

  # after cleanup
