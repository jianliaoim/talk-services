should = require 'should'
requireDir = require 'require-dir'
Promise = require 'bluebird'
_ = require 'lodash'

loader = require '../../src/loader'
{req, res} = require '../util'
$trello = loader.load 'trello'

payloads = requireDir './trello_assets'

describe 'Trello#GetBoards', ->

  it 'should get boards from trello', (done) ->
    req.set 'accountToken', 'trello'
    $trello.then (trello) ->
      trello.receiveApi 'getBoards', req, res
    .then (boards) ->
      boards.length.should.eql 2
    .nodeify done

describe 'Trello#Integration', ->

  integration =
    category: 'trello'
    config:
      modelId: '4f0a922ff25c53695a0cb1d7'
      modelName: 'Welcome Board'

  it 'should create trello webhook when creating integration', (done) ->
    req.set 'accountToken', 'trello'
    req.integration = integration

    $trello.then (trello) -> trello.receiveEvent 'before.integration.create', req
    .then -> integration.data.webhookId.should.eql '56dfc3818d119dd1563685dc'
    .nodeify done

  it 'should update trello webhook when changing model id', (done) ->
    req.set 'accountToken', 'trello'
    req.set 'config',
      modelId: '4f83f6fab28be1c82841b3c0'
      modelName: 'ToDoNow'

    $trello.then (trello) -> trello.receiveEvent 'before.integration.update', req
    .then -> req.integration.data.webhookId.should.eql '56dfc3818d119dd1563685dd'
    .nodeify done

  it 'should remove trello webhook when removing integration', (done) ->
    req.set 'accountToken', 'trello'
    $trello.then (trello) -> trello.receiveEvent 'before.integration.remove', req
    .nodeify done

describe 'Trello#Webhook', ->

  it 'receive addAttachmentToCard', (done) ->
    req.body = payloads['addAttachmentToCard'].body
    $trello.then (trello) ->
      trello.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql '晶鑫 许 attached 4.png to Job Launcher'
      message.attachments[0].data.imageUrl.should.eql 'https://trello-attachments.s3.amazonaws.com/4f841c4836f1988153c16630/700x400/2476680a0cdf34c51b24fff65491f657/4.png'
      message.attachments[0].data.redirectUrl.should.eql 'https://trello.com/c/cpPBC3ce'
    .nodeify done

  it 'receive addChecklistToCard', (done) ->
    req.body = payloads['addChecklistToCard'].body
    $trello.then (trello) ->
      trello.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql '晶鑫 许 added checklist to BBBBBBBBBB'
      message.attachments[0].data.text.should.eql 'Checklist'
      message.attachments[0].data.redirectUrl.should.eql 'https://trello.com/c/4m1sKhJ8'
    .nodeify done

  it 'receive commentCard', (done) ->
    req.body = payloads['commentCard'].body
    $trello.then (trello) ->
      trello.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql '晶鑫 许 comment on BBBBBBBBBB'
      message.attachments[0].data.text.should.eql 'Hello\n'
      message.attachments[0].data.redirectUrl.should.eql 'https://trello.com/c/4m1sKhJ8'
    .nodeify done

  it 'receive createCard', (done) ->
    req.body = payloads['createCard'].body
    $trello.then (trello) ->
      trello.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql '晶鑫 许 created New Card'
      message.attachments[0].data.redirectUrl.should.eql 'https://trello.com/c/JkEhlWsI'
    .nodeify done

  it 'receive createCheckItem', (done) ->
    req.body = payloads['createCheckItem'].body
    $trello.then (trello) ->
      trello.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql '晶鑫 许 added new check item to Js流程图（前端，WebSocket）'
      message.attachments[0].data.text.should.eql 'A'
      message.attachments[0].data.redirectUrl.should.eql 'https://trello.com/c/lQBYCT9O'
    .nodeify done

  it 'receive updateBoard-close', (done) ->
    req.body = payloads['updateBoard-close'].body
    $trello.then (trello) ->
      trello.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql '晶鑫 许 closed board ToDo'
      message.attachments[0].data.redirectUrl.should.eql 'https://trello.com/b/GkR7AsMR'
    .nodeify done

  it 'receive updateBoard-rename', (done) ->
    req.body = payloads['updateBoard-rename'].body
    $trello.then (trello) ->
      trello.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql '晶鑫 许 renamed board ToDoNow from ToDo'
      message.attachments[0].data.redirectUrl.should.eql 'https://trello.com/b/GkR7AsMR'
    .nodeify done

  it 'receive updateCard-close', (done) ->
    req.body = payloads['updateCard-close'].body
    $trello.then (trello) ->
      trello.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql '晶鑫 许 closed card BBBBBBBBBB'
      message.attachments[0].data.redirectUrl.should.eql 'https://trello.com/c/4m1sKhJ8'
    .nodeify done

  it 'receive updateCard-due', (done) ->
    req.body = payloads['updateCard-due'].body
    $trello.then (trello) ->
      trello.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql '晶鑫 许 set BBBBBBBBBB to be due 2016-03-09T04:00:00.000Z'
      message.attachments[0].data.redirectUrl.should.eql 'https://trello.com/c/4m1sKhJ8'
    .nodeify done

  it 'receive updateCard-move', (done) ->
    req.body = payloads['updateCard-move'].body
    $trello.then (trello) ->
      trello.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql '晶鑫 许 moved fasdfasdf from fasdfasdf to To Do'
      message.attachments[0].data.redirectUrl.should.eql 'https://trello.com/c/4m1sKhJ8'
    .nodeify done

  it 'receive updateCard-rename', (done) ->
    req.body = payloads['updateCard-rename'].body
    $trello.then (trello) ->
      trello.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql '晶鑫 许 renamed BBBBBBBBBB from AAAAAAAAAAAA'
      message.attachments[0].data.redirectUrl.should.eql 'https://trello.com/c/4m1sKhJ8'
    .nodeify done

  it 'receive updateCheckItem', (done) ->
    req.body = payloads['updateCheckItem'].body
    $trello.then (trello) ->
      trello.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql '晶鑫 许 renamed BC from B'
      message.attachments[0].data.redirectUrl.should.eql 'https://trello.com/c/lQBYCT9O'
    .nodeify done

  it 'receive updateCheckItemStateOnCard', (done) ->
    req.body = payloads['updateCheckItemStateOnCard'].body
    $trello.then (trello) ->
      trello.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql '晶鑫 许 complete A'
      message.attachments[0].data.redirectUrl.should.eql 'https://trello.com/c/lQBYCT9O'
    .nodeify done

  it 'receive updateChecklist', (done) ->
    req.body = payloads['updateChecklist'].body
    $trello.then (trello) ->
      trello.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql '晶鑫 许 renamed New Name from New check'
      message.attachments[0].data.redirectUrl.should.eql 'https://trello.com/b/GkR7AsMR'
    .nodeify done

  it 'receive updateComment', (done) ->
    req.body = payloads['updateComment'].body
    $trello.then (trello) ->
      trello.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql '晶鑫 许 updated comment on BBBBBBBBBB'
      message.attachments[0].data.text.should.eql 'Hello World\n'
      message.attachments[0].data.redirectUrl.should.eql 'https://trello.com/c/4m1sKhJ8'
    .nodeify done
