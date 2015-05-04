should = require 'should'
Promise = require 'bluebird'
requireDir = require 'require-dir'
crypto = require 'crypto'

service = require '../../src/service'
config = require '../config'
{prepare, cleanup, req} = require '../util'
teambition = service.load 'teambition'
# Fake client serect
teambition.clientSecret = 'abc'

{limbo} = service.components
{IntegrationModel} = limbo.use 'talk'

payloads = requireDir './teambition_assets'

sign =
  "sign": "b0df73e3c09a9620f31998911b1940109ee24c0b"
  "timestamp": "1430293521192"
  "nonce": "b00e8a80"

_testWebhook = (event, payload, checkMessage) ->
  # Overwrite the sendMessage function of coding
  teambition.sendMessage = checkMessage
  req.body = payload
  timestamp = Date.now()
  nonce = 'f2611e70'
  req.query = timestamp: "#{timestamp}", nonce: nonce
  req.query.sign = crypto.createHash('sha1').update("#{teambition.clientSecret}#{timestamp}#{nonce}").digest('hex')
  teambition.receiveEvent 'service.webhook', req

describe 'Teambition#IntegrationHooks', ->

  return

  unless config.teambition?.token and config.teambition?._projectId
    return console.error """
    Teambition token and _projectId are not exist
    Add them in config.json to test teambition service
    """

  @timeout 5000

  hookId = null

  {_projectId} = config.teambition

  integration = new IntegrationModel
    category: 'teambition'
    token: config.teambition.token
    events: ["task.create"]
    project: _id: config.teambition._projectId, name: 'Test'

  before prepare

  it 'should create teambition webhook when creating integration', (done) ->
    teambition.receiveEvent 'before.integration.create', integration
    .then ->
      integration.data[_projectId].should.have.properties 'hookId'
      hookId = integration.data[_projectId].hookId
      new Promise (resolve, reject) ->
        integration.save (err, integration) ->
          return reject(err) if err
          resolve integration
    .then -> done()
    .catch done

  it 'should update teambition webhook when update integration', (done) ->
    integration._original = integration.toJSON()
    integration.events = ["task.create", "subtask.create"]
    teambition.receiveEvent 'before.integration.update', integration
    .then ->
      integration.data[_projectId].hookId.should.eql hookId
      new Promise (resolve, reject) ->
        integration.save (err, integration) ->
          return reject(err) if err
          resolve integration
    .then -> done()
    .catch done

  if config.teambition._newProjectId
    it 'should update the hookId when update integration project id', (done) ->
      integration._original = integration.toJSON()
      integration.project._id = config.teambition._newProjectId
      teambition.receiveEvent 'before.integration.update', integration
      .then ->
        integration.data[config.teambition._newProjectId].hookId.should.not.eql hookId
        integration.data.should.not.have.properties config.teambition._projectId
        new Promise (resolve, reject) ->
          integration.save (err, integration) ->
            return reject(err) if err
            resolve integration
      .then -> done()
      .catch done

  else
    console.error """
    Teambition _newProjectId is not exist
    Add it in config.json to test changing teanbition integration project
    """

  it 'should remove the teambition hook when remove integration', (done) ->
    teambition.receiveEvent 'before.integration.remove', integration
    .then -> done()
    .catch done

  after cleanup

describe 'Teambition#Webhook', ->

  before prepare

  req.integration =
    _id: '5539eef5db959e7d87c9e48a'
    category: 'teambition'

  it 'receive project.rename', (done) ->
    _testWebhook 'project.rename', payloads['project.rename'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 修改了项目 新名'
      message.quote.redirectUrl.should.eql payloads['project.rename'].data.project.url
      done()

  it 'receive project.archive', (done) ->
    _testWebhook 'project.archive', payloads['project.archive'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 归档了项目 新名'
      message.quote.redirectUrl.should.eql payloads['project.archive'].data.project.url
      done()

  it 'receive project.unarchive', (done) ->
    _testWebhook 'project.unarchive', payloads['project.unarchive'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 恢复了项目 新名'
      message.quote.redirectUrl.should.eql payloads['project.unarchive'].data.project.url
      done()

  it 'receive project.member.create', (done) ->
    _testWebhook 'project.member.create', payloads['project.member.create'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 邀请了成员 大师兄'
      done()

  it 'receive project.member.remove', (done) ->
    _testWebhook 'project.member.create', payloads['project.member.remove'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 移除了成员 大师兄'
      done()

  it 'receive tasklist.create', (done) ->
    _testWebhook 'tasklist.create', payloads['tasklist.create'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 创建了任务列表 tasklist'
      message.quote.redirectUrl.should.eql payloads['tasklist.create'].data.tasklist.url
      done()

  it 'receive tasklist.remove', (done) ->
    _testWebhook 'tasklist.remove', payloads['tasklist.remove'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 删除了任务列表 new tasklist'
      done()

  it 'receive tasklist.rename', (done) ->
    _testWebhook 'tasklist.rename', payloads['tasklist.rename'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 修改了任务列表 new tasklist'
      done()

  it 'receive task.create', (done) ->
    _testWebhook 'task.create', payloads['task.create'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 创建了任务 task'
      message.quote.redirectUrl.should.eql payloads['task.create'].data.task.url
      done()

  it 'receive task.remove', (done) ->
    _testWebhook 'task.remove', payloads['task.remove'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 删除了任务 task'
      done()

  it 'receive task.update.executor', (done) ->
    _testWebhook 'task.update.executor', payloads['task.update.executor'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 将任务 task 指派给 大师兄'
      done()

  it 'receive task.remove.executor', (done) ->
    _testWebhook 'task.remove.executor', payloads['task.remove.executor'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 移除了任务 task 的执行者'
      done()

  it 'receive task.update.priority', (done) ->
    _testWebhook 'task.update.priority', payloads['task.update.priority'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 更新了任务 subtask 的优先级 非常紧急'
      done()

  it 'receive task.update.dueDate', (done) ->
    _testWebhook 'task.update.dueDate', payloads['task.update.dueDate'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 更新了任务 task 的截止日期 04月22日'
      done()

  it 'receive task.rename', (done) ->
    _testWebhook 'task.rename', payloads['task.rename'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 重命名了任务 newtask'
      done()

  it 'receive task.move', (done) ->
    _testWebhook 'task.move', payloads['task.move'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 将任务 task 移动到 tasklist列表，DOING阶段'
      done()

  it 'receive task.done', (done) ->
    _testWebhook 'task.done', payloads['task.done'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 完成了任务 task'
      done()

  ###*
   * @todo Add task.update.involveMembers
  ###
  # it 'receive task.update.involveMembers', (done) ->
  #   _testWebhook 'task.update.involveMembers', payloads['task.update.involveMembers'], (message) ->
  #     message.quote.title.should.eql '[新名] 二师兄添加了任务 task 的参与者 大师兄'

  it 'receive subtask.create', (done) ->
    _testWebhook 'subtask.create', payloads['subtask.create'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 创建了子任务 subtask'
      message.quote.redirectUrl.should.eql payloads['subtask.create'].data.subtask.task.url
      done()

  it 'receive subtask.update.executor', (done) ->
    _testWebhook 'subtask.update.executor', payloads['subtask.update.executor'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 将子任务 subtask 指派给 大师兄'
      done()

  it 'receive subtask.update.content', (done) ->
    _testWebhook 'subtask.update.content', payloads['subtask.update.content'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 更新了子任务 subtask 1'
      done()

  it 'receive subtask.done', (done) ->
    _testWebhook 'subtask.done', payloads['subtask.done'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 完成了子任务 subtask'
      done()

  it 'receive tag.create', (done) ->
    _testWebhook 'tag.create', payloads['tag.create'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 创建了标签 tag4'
      message.quote.redirectUrl.should.eql payloads['tag.create'].data.tag.url
      done()

  it 'receive tag.remove', (done) ->
    _testWebhook 'tag.remove', payloads['tag.remove'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 删除了标签 tag3'
      done()

  it 'receive post.create', (done) ->
    _testWebhook 'post.create', payloads['post.create'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 发布了分享 Mardown'
      message.quote.text.should.eql '<pre><code class="lang-javascript">var a = 1\n</code></pre>\n'
      message.quote.redirectUrl.should.eql payloads['post.create'].data.post.url
      done()

  it 'receive post.update', (done) ->
    _testWebhook 'post.update', payloads['post.update'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 更新了分享 post'
      message.quote.text.should.eql '<h3>分享内容</h3><div>分享2</div>'
      done()

  ###*
   * @todo Add post.update.involveMembers
  ###
  # it 'receive post.update.involveMembers', (done) ->
  #   _testWebhook 'post.update.involveMembers', payloads['post.update'], (message) ->
  #     message.quote.title.should.eql

  it 'receive file.create', (done) ->
    _testWebhook 'file.create', payloads['file.create'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 上传了文件 5.jpg'
      message.quote.thumbnailPicUrl.should.eql payloads['file.create'].data.file[0].thumbnail
      message.quote.redirectUrl.should.eql payloads['file.create'].data.file[0].url
      done()

  it 'receive file.remove', (done) ->
    _testWebhook 'file.remove', payloads['file.remove'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 删除了文件 123.jpg'
      message.quote.redirectUrl.should.eql payloads['file.remove'].data.project.url
      done()

  it 'receive file.move', (done) ->
    _testWebhook 'file.move', payloads['file.move'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 将文件 5.jpg 移动到 dir'
      message.quote.redirectUrl.should.eql payloads['file.move'].data.file.url
      done()

  it 'receive file.rename', (done) ->
    _testWebhook 'file.rename', payloads['file.rename'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 重命名了文件 123.jpg'
      done()

  it 'receive file.update.version', (done) ->
    _testWebhook 'file.update.version', payloads['file.update.version'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 更新了文件 4.jpg'
      done()

  ###*
   * @todo Add file.update.involveMembers
  ###
  # it 'receive file.update.involveMembers', (done) ->

  it 'receive event.create', (done) ->
    _testWebhook 'event.create', payloads['event.create'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 创建了日程 event 地点：office，开始时间：04月30日16:15:00，结束时间：04月30日17:15:00'
      message.quote.text.should.eql '<p>haha</p>\n'
      message.quote.redirectUrl.should.eql payloads['event.create'].data.event.url
      done()

  it 'receive event.remove', (done) ->
    _testWebhook 'event.remove', payloads['event.remove'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 删除了日程 event'
      message.quote.redirectUrl.should.eql payloads['event.remove'].data.project.url
      done()

  it 'receive event.update', (done) ->
    _testWebhook 'event.update', payloads['event.update'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 更新了日程 event 地点：office，开始时间：04月30日20:15:00，结束时间：04月30日21:15:00'
      message.quote.text.should.eql '<p>note</p>\n'
      done()

  it 'receive stage.create', (done) ->
    _testWebhook 'stage.create', payloads['stage.create'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 创建了阶段 DOING'
      message.quote.redirectUrl.should.eql payloads['stage.create'].data.stage.tasklist.url
      done()

  it 'receive stage.rename', (done) ->
    _testWebhook 'stage.rename', payloads['stage.rename'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 重命名了阶段 TODO'
      done()

  it 'receive entry.create', (done) ->
    _testWebhook 'entry.create', payloads['entry.create'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 创建了账单 incoming，收入 10 元'
      message.quote.redirectUrl.should.eql payloads['entry.create'].data.entry.url
      done()

  it 'receive entry.update', (done) ->
    _testWebhook 'entry.update', payloads['entry.update'], (message) ->
      message.quote.title.should.eql '[新名] 二师兄 更新了账单 income，收入 12 元'
      done()

  it 'should throw error when receive a invalid signature', (done) ->
    req.body = payloads['entry.create']
    req.query =
      timestamp: "#{Date.now()}"
      nonce: 'f2611e70'
    req.query.sign = 'other'

    teambition.receiveEvent 'service.webhook', req
    .then -> done(new Error('Can not pass'))
    .catch (err) ->
      # Should receive error
      err.message.should.eql 'Signature failed'
      done()

  after cleanup
