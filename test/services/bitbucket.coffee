should = require 'should'
loader = require '../../src/loader'
{req} = require '../util'
$bitbucket = loader.load 'bitbucket'

describe 'Bitbucket#Webhook', ->

  it 'receive invalid webhook', (done) ->

    data = require './bitbucket_assets/invalid_event.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    $bitbucket.then (bitbucket) -> bitbucket.receiveEvent 'service.webhook', req
    .then -> done new Error('Should not pass')
    .catch (err) ->
      err.message.should.eql 'Invalid event type'
      done()

  it 'receive invalid webhook(invalid issue action)', (done) ->

    data = require './bitbucket_assets/invalid_issue_action.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    $bitbucket.then (bitbucket) -> bitbucket.receiveEvent 'service.webhook', req
    .then -> done new Error('should not pass')
    .catch (err) ->
      err.message.should.eql 'Unsupported action'
      done()

  it 'receive repository push', (done) ->

    data = require './bitbucket_assets/repo_push.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    $bitbucket.then (bitbucket) -> bitbucket.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql 'A new push for project Test Bitbucket'
      message.attachments[0].data.text.should.eql 'Committer: Catalyst Zhang'
      message.attachments[0].data.redirectUrl.should.eql 'https://bitbucket.org/destec/test-bitbucket'
    .nodeify done

  it 'receive repository comment', (done) ->

    data = require './bitbucket_assets/repo_commit_comment_created.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    $bitbucket.then (bitbucket) -> bitbucket.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql 'A new comment for Test Bitbucket'
      message.attachments[0].data.text.should.eql 'a comment for the commit.'
      message.attachments[0].data.redirectUrl.should.eql 'https://bitbucket.org/destec/test-bitbucket/commits/024cb7dc2cea5cc1360dad6531661a037e492a8d#comment-2066462'
    .nodeify done

  it 'receive issue comment notifycation', (done) ->

    data = require './bitbucket_assets/issue_comment_created.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    $bitbucket.then (bitbucket) -> bitbucket.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql 'Catalyst Zhang created a comment for project destec/test-bitbucket'
      message.attachments[0].data.text.should.eql 'comment for the issue'
      message.attachments[0].data.redirectUrl.should.eql 'https://bitbucket.org/destec/test-bitbucket/issue/1#comment-19446825'
    .nodeify done

  it 'receive issue created notification', (done) ->

    data = require './bitbucket_assets/issue_created.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    $bitbucket.then (bitbucket) -> bitbucket.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql 'Catalyst Zhang created an issue for project destec/test-bitbucket'
      message.attachments[0].data.text.should.eql 'the test issue'
      message.attachments[0].data.redirectUrl.should.eql 'https://bitbucket.org/destec/test-bitbucket/issue/1/hi-what-is-issue'
    .nodeify done

  it 'receive issue updated notification', (done) ->

    data = require './bitbucket_assets/issue_updated.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    $bitbucket.then (bitbucket) -> bitbucket.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql 'Catalyst Zhang updated an issue for project destec/test-bitbucket'
      message.attachments[0].data.text.should.eql 'update the test issue'
      message.attachments[0].data.redirectUrl.should.eql 'https://bitbucket.org/destec/test-bitbucket/issue/1/hi-what-is-issue'
    .nodeify done

  it 'receive pull request created notification', (done) ->

    data = require './bitbucket_assets/pullrequest_created.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    $bitbucket.then (bitbucket) -> bitbucket.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql 'Catalyst Zhang created a pull request for Test Bitbucket'
      message.attachments[0].data.text.should.eql 'first br'
      message.attachments[0].data.redirectUrl.should.eql 'https://bitbucket.org/destec/test-bitbucket/pull-request/1'
    .nodeify done

  it 'receive pull request updated notification', (done) ->

    data = require './bitbucket_assets/pullrequest_updated.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    $bitbucket.then (bitbucket) -> bitbucket.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql 'Catalyst Zhang updated a pull request for Test Bitbucket'
      message.attachments[0].data.text.should.eql 'first br'
      message.attachments[0].data.redirectUrl.should.eql 'https://bitbucket.org/destec/test-bitbucket/pull-request/1'
    .nodeify done

  it 'receive pull request fulfilled notification', (done) ->

    data = require './bitbucket_assets/pullrequest_fulfilled.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    $bitbucket.then (bitbucket) -> bitbucket.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql 'Catalyst Zhang fulfilled the pull request update pr'
      message.attachments[0].data.text.should.eql ''
      message.attachments[0].data.redirectUrl.should.eql 'https://bitbucket.org/destec/test-bitbucket/pull-request/1'
    .nodeify done

  it 'receive pull request rejected notification', (done) ->

    data = require './bitbucket_assets/pullrequest_rejected.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    $bitbucket.then (bitbucket) -> bitbucket.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql 'Catalyst Zhang rejected the pull request second pr'
      message.attachments[0].data.text.should.eql ''
      message.attachments[0].data.redirectUrl.should.eql 'https://bitbucket.org/destec/test-bitbucket/pull-request/2'
    .nodeify done

  it 'receive pull request comment created notification', (done) ->

    data = require './bitbucket_assets/pullrequest_comment_created.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    $bitbucket.then (bitbucket) -> bitbucket.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql 'Catalyst Zhang created a comment for pull request update pr'
      message.attachments[0].data.text.should.eql 'update pr'
      message.attachments[0].data.redirectUrl.should.eql 'https://bitbucket.org/destec/test-bitbucket/pull-request/1'
    .nodeify done

  it 'receive pull request comment updated notification', (done) ->

    data = require './bitbucket_assets/pullrequest_comment_deleted.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    $bitbucket.then (bitbucket) -> bitbucket.receiveEvent 'service.webhook', req
    .then (message) ->
      (message) ->
      message.attachments[0].data.title.should.eql 'Catalyst Zhang deleted a comment for pull request update pr'
      message.attachments[0].data.text.should.eql 'update pr'
      message.attachments[0].data.redirectUrl.should.eql 'https://bitbucket.org/destec/test-bitbucket/pull-request/1'
    .nodeify done
