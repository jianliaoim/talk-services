should = require 'should'
Promise = require 'bluebird'
requireDir = require 'require-dir'
crypto = require 'crypto'
_ = require 'lodash'

loader = require '../../src/loader'
{req, res} = require '../util'

$teambition = loader.load 'teambition'

payloads = requireDir './teambition_assets'

sign =
  "sign": "b0df73e3c09a9620f31998911b1940109ee24c0b"
  "timestamp": "1430293521192"
  "nonce": "b00e8a80"

_testWebhook = (event, payload, checkMessage) ->
  # Overwrite the sendMessage function of coding
  req.body = payload
  timestamp = Date.now()
  nonce = 'f2611e70'
  req.query = timestamp: "#{timestamp}", nonce: nonce
  values = [timestamp, nonce, loader.config.teambition.clientSecret]
  req.query.sign = crypto.createHash('sha1').update(values.sort().join '').digest('hex')
  $teambition.then (teambition) -> teambition.receiveEvent 'service.webhook', req

describe 'Teambition#GetProjects', ->

  it 'should read the teambition\'s projects of user', (done) ->
    req.set 'accountToken', 'xxx'
    $teambition.then (teambition) ->
      teambition.receiveApi 'getProjects', req, res
    .then (projects) ->
      projects.length.should.eql 2
      projects.forEach (project) -> project.should.have.properties '_id', 'name'
    .nodeify done

describe 'Teambition#IntegrationHooks', ->

  _projectId = '5632dc1a065565ad690266a0'
  _newProjectId = '5632dc1a065565ad690266a1'
  hookId = null

  integration =
    category: 'teambition'
    events: ["task.create"]
    project: _id: _projectId, name: 'Test'

  req.set 'accountToken', 'xxx'

  it 'should create teambition webhook when creating integration', (done) ->
    req.integration = integration
    $teambition.then (teambition) ->
      teambition.receiveEvent 'before.integration.create', req
    .then ->
      integration.data[_projectId].should.have.properties 'hookId'
      hookId = integration.data[_projectId].hookId
    .nodeify done

  it 'should update teambition webhook when update integration', (done) ->
    req.integration = integration
    req.set 'events', ["task.create", "subtask.create"]
    $teambition.then (teambition) ->
      teambition.receiveEvent 'before.integration.update', req
    .then ->
      integration.data[_projectId].hookId.should.eql hookId
      integration.events = ["task.create", "subtask.create"]
    .nodeify done

  it 'should update the hookId when update integration project id', (done) ->
    req.integration = integration
    req.set 'project', _id: _newProjectId
    $teambition.then (teambition) ->
      teambition.receiveEvent 'before.integration.update', req
    .then ->
      integration.data[_newProjectId].hookId.should.not.eql hookId
      integration.data.should.not.have.properties _projectId
      integration.project = _id: _newProjectId
    .nodeify done

  it 'should remove the teambition hook when remove integration', (done) ->
    req.integration = integration
    $teambition.then (teambition) ->
      teambition.receiveEvent 'before.integration.remove', req
    .nodeify done

describe 'Teambition#Webhook', ->

  req.integration =
    _id: '5539eef5db959e7d87c9e48a'
    category: 'teambition'

  it 'receive project.rename', (done) ->
    _testWebhook 'project.rename', payloads['project.rename']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 重命名了项目 新名'
      message.attachments[0].data.redirectUrl.should.eql payloads['project.rename'].data.project.url
    .nodeify done

  it 'receive project.archive', (done) ->
    _testWebhook 'project.archive', payloads['project.archive']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 归档了项目 新名'
      message.attachments[0].data.redirectUrl.should.eql payloads['project.archive'].data.project.url
    .nodeify done

  it 'receive project.unarchive', (done) ->
    _testWebhook 'project.unarchive', payloads['project.unarchive']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 恢复了项目 新名'
      message.attachments[0].data.redirectUrl.should.eql payloads['project.unarchive'].data.project.url
    .nodeify done

  it 'receive project.member.create', (done) ->
    _testWebhook 'project.member.create', payloads['project.member.create']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 邀请了成员 大师兄'
    .nodeify done

  it 'receive project.member.remove', (done) ->
    _testWebhook 'project.member.create', payloads['project.member.remove']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 移除了成员 大师兄'
    .nodeify done

  it 'receive tasklist.create', (done) ->
    _testWebhook 'tasklist.create', payloads['tasklist.create']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 创建了任务列表 tasklist'
      message.attachments[0].data.redirectUrl.should.eql payloads['tasklist.create'].data.tasklist.url
    .nodeify done

  it 'receive tasklist.remove', (done) ->
    _testWebhook 'tasklist.remove', payloads['tasklist.remove']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 删除了任务列表 new tasklist'
    .nodeify done

  it 'receive tasklist.rename', (done) ->
    _testWebhook 'tasklist.rename', payloads['tasklist.rename']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 修改了任务列表 new tasklist'
    .nodeify done

  it 'receive task.create', (done) ->
    _testWebhook 'task.create', payloads['task.create']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 创建了任务 task'
      message.attachments[0].data.redirectUrl.should.eql payloads['task.create'].data.task.url
    .nodeify done

  it 'receive task.remove', (done) ->
    _testWebhook 'task.remove', payloads['task.remove']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 删除了任务 task'
    .nodeify done

  it 'receive task.update.executor', (done) ->
    _testWebhook 'task.update.executor', payloads['task.update.executor']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 将任务 task 指派给 大师兄'
    .nodeify done

  it 'receive task.remove.executor', (done) ->
    _testWebhook 'task.remove.executor', payloads['task.remove.executor']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 移除了任务的执行者 task'
    .nodeify done

  it 'receive task.update.priority', (done) ->
    _testWebhook 'task.update.priority', payloads['task.update.priority']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 更新了任务 subtask 的优先级 非常紧急'
    .nodeify done

  it 'receive task.update.dueDate', (done) ->
    _testWebhook 'task.update.dueDate', payloads['task.update.dueDate']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 更新了任务 task 的截止日期 04月22日'
    .nodeify done

  it 'receive task.rename', (done) ->
    _testWebhook 'task.rename', payloads['task.rename']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 重命名了任务 newtask'
    .nodeify done

  it 'receive task.move', (done) ->
    _testWebhook 'task.move', payloads['task.move']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 将任务 task 移动到 tasklist列表，DOING阶段'
    .nodeify done

  it 'receive task.done', (done) ->
    _testWebhook 'task.done', payloads['task.done']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 完成了任务 task'
    .nodeify done

  ###*
   * @todo Add task.update.involveMembers
  ###
  # it 'receive task.update.involveMembers', (done) ->
  #   _testWebhook 'task.update.involveMembers', payloads['task.update.involveMembers'], (message) ->
  #     message.attachments[0].data.title.should.eql '[新名] 二师兄添加了任务 task 的参与者 大师兄'

  it 'receive subtask.create', (done) ->
    _testWebhook 'subtask.create', payloads['subtask.create']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 创建了子任务 subtask'
      message.attachments[0].data.redirectUrl.should.eql payloads['subtask.create'].data.subtask.task.url
    .nodeify done

  it 'receive subtask.update.executor', (done) ->
    _testWebhook 'subtask.update.executor', payloads['subtask.update.executor']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 将子任务 subtask 指派给 大师兄'
    .nodeify done

  it 'receive subtask.update.content', (done) ->
    _testWebhook 'subtask.update.content', payloads['subtask.update.content']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 更新了子任务 subtask 1'
    .nodeify done

  it 'receive subtask.done', (done) ->
    _testWebhook 'subtask.done', payloads['subtask.done']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 完成了子任务 subtask'
    .nodeify done

  it 'receive tag.create', (done) ->
    _testWebhook 'tag.create', payloads['tag.create']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 创建了标签 tag4'
      message.attachments[0].data.redirectUrl.should.eql payloads['tag.create'].data.tag.url
    .nodeify done

  it 'receive tag.remove', (done) ->
    _testWebhook 'tag.remove', payloads['tag.remove']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 删除了标签 tag3'
    .nodeify done

  it 'receive post.create', (done) ->
    _testWebhook 'post.create', payloads['post.create']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 发布了分享 Mardown'
      message.attachments[0].data.text.should.eql '<pre><code class="lang-javascript">var a = 1\n</code></pre>\n'
      message.attachments[0].data.redirectUrl.should.eql payloads['post.create'].data.post.url
    .nodeify done

  it 'receive post.update', (done) ->
    _testWebhook 'post.update', payloads['post.update']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 更新了分享 post'
      message.attachments[0].data.text.should.eql '<h3>分享内容</h3><div>分享2</div>'
    .nodeify done

  ###*
   * @todo Add post.update.involveMembers
  ###
  # it 'receive post.update.involveMembers', (done) ->
  #   _testWebhook 'post.update.involveMembers', payloads['post.update'], (message) ->
  #     message.attachments[0].data.title.should.eql

  it 'receive file.create', (done) ->
    _testWebhook 'file.create', payloads['file.create']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 上传了文件 5.jpg'
      message.attachments[0].data.imageUrl.should.eql payloads['file.create'].data.file[0].thumbnail
      message.attachments[0].data.redirectUrl.should.eql payloads['file.create'].data.file[0].url
    .nodeify done

  it 'receive file.remove', (done) ->
    _testWebhook 'file.remove', payloads['file.remove']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 删除了文件 123.jpg'
      message.attachments[0].data.redirectUrl.should.eql payloads['file.remove'].data.project.url
    .nodeify done

  it 'receive file.move', (done) ->
    _testWebhook 'file.move', payloads['file.move']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 将文件 5.jpg 移动到 dir'
      message.attachments[0].data.redirectUrl.should.eql payloads['file.move'].data.file.url
    .nodeify done

  it 'receive file.rename', (done) ->
    _testWebhook 'file.rename', payloads['file.rename']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 重命名了文件 123.jpg'
    .nodeify done

  it 'receive file.update.version', (done) ->
    _testWebhook 'file.update.version', payloads['file.update.version']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 更新了文件 4.jpg'
    .nodeify done

  ###*
   * @todo Add file.update.involveMembers
  ###
  # it 'receive file.update.involveMembers', (done) ->

  it 'receive event.create', (done) ->
    _testWebhook 'event.create', payloads['event.create']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 创建了日程 event 地点：office，开始时间：04月30日16:15:00，结束时间：04月30日17:15:00'
      message.attachments[0].data.text.should.eql '<p>haha</p>\n'
      message.attachments[0].data.redirectUrl.should.eql payloads['event.create'].data.event.url
    .nodeify done

  it 'receive event.remove', (done) ->
    _testWebhook 'event.remove', payloads['event.remove']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 删除了日程 event'
      message.attachments[0].data.redirectUrl.should.eql payloads['event.remove'].data.project.url
    .nodeify done

  it 'receive event.update', (done) ->
    _testWebhook 'event.update', payloads['event.update']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 更新了日程 event 地点：office，开始时间：04月30日20:15:00，结束时间：04月30日21:15:00'
      message.attachments[0].data.text.should.eql '<p>note</p>\n'
    .nodeify done

  it 'receive stage.create', (done) ->
    _testWebhook 'stage.create', payloads['stage.create']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 创建了阶段 DOING'
      message.attachments[0].data.redirectUrl.should.eql payloads['stage.create'].data.stage.tasklist.url
    .nodeify done

  it 'receive stage.rename', (done) ->
    _testWebhook 'stage.rename', payloads['stage.rename']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 重命名了阶段 TODO'
    .nodeify done

  it 'receive entry.create', (done) ->
    _testWebhook 'entry.create', payloads['entry.create']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 创建了账单 incoming，收入 10 元'
      message.attachments[0].data.redirectUrl.should.eql payloads['entry.create'].data.entry.url
    .nodeify done

  it 'receive entry.update', (done) ->
    _testWebhook 'entry.update', payloads['entry.update']
    .then (message) ->
      message.attachments[0].data.title.should.eql '[新名] 二师兄 更新了账单 income，收入 12 元'
    .nodeify done

  it 'should throw error when receive a invalid signature', (done) ->
    req.body = payloads['entry.create']
    req.query =
      timestamp: "#{Date.now()}"
      nonce: 'f2611e70'
    req.query.sign = 'other'

    $teambition.then (teambition) ->
      teambition.receiveEvent 'service.webhook', req
    .then -> done(new Error('Can not pass'))
    .catch (err) ->
      # Should receive error
      err.message.should.eql 'SIGNATURE_FAILED'
      done()
