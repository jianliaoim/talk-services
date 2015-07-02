should = require 'should'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
bitbucket = service.load 'bitbucket'

describe 'Bitbucket#Webhook', ->

  before prepare

  it 'receive invalid webhook', (done) ->

    data = require './bitbucket_assets/invalid_event.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    bitbucket.receiveEvent 'service.webhook', req
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

    bitbucket.receiveEvent 'service.webhook', req
    .catch (err) ->
      err.message.should.eql 'Unsupported action'
      done()

  it 'receive invalid webhook(invalid repo action)', (done) ->

    data = require './bitbucket_assets/invalid_repo_action.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    bitbucket.receiveEvent 'service.webhook', req
    .catch (err) ->
      err.message.should.eql 'Unsupported action'
      done()

  it 'receive invalid webhook(invalid pr action)', (done) ->

    data = require './bitbucket_assets/invalid_pr_action.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    bitbucket.receiveEvent 'service.webhook', req
    .catch (err) ->
      err.message.should.eql 'Unsupported action'
      done()

  it 'receive repository push', (done) ->
    bitbucket.sendMessage = (message) ->
      message.quote.title.should.eql 'A new push for project Test Bitbucket'
      message.quote.text.should.eql 'Committer: Catalyst Zhang'
      message.quote.redirectUrl.should.eql 'https://bitbucket.org/destec/test-bitbucket'
      done()

    data = require './bitbucket_assets/repo_push.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    bitbucket.receiveEvent 'service.webhook', req

  it 'receive repository comment', (done) ->
    bitbucket.sendMessage = (message) ->
      message.quote.title.should.eql 'A new comment for Test Bitbucket'
      message.quote.text.should.eql 'a comment for the commit.'
      message.quote.redirectUrl.should.eql 'https://bitbucket.org/destec/test-bitbucket/commits/024cb7dc2cea5cc1360dad6531661a037e492a8d#comment-2066462'
      done()

    data = require './bitbucket_assets/repo_commit_comment_created.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    bitbucket.receiveEvent 'service.webhook', req

  it 'receive issue comment notifycation', (done) ->
    bitbucket.sendMessage = (message) ->
      message.quote.title.should.eql 'Catalyst Zhang created a comment for project destec/test-bitbucket'
      message.quote.text.should.eql 'comment for the issue'
      message.quote.redirectUrl.should.eql 'https://bitbucket.org/destec/test-bitbucket/issue/1#comment-19446825'
      done()

    data = require './bitbucket_assets/issue_comment_created.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    bitbucket.receiveEvent 'service.webhook', req

  it 'receive issue created notification', (done) ->
    bitbucket.sendMessage = (message) ->
      message.quote.title.should.eql 'Catalyst Zhang created an issue for project destec/test-bitbucket'
      message.quote.text.should.eql 'the test issue'
      message.quote.redirectUrl.should.eql 'https://bitbucket.org/destec/test-bitbucket/issue/1/hi-what-is-issue'
      done()

    data = require './bitbucket_assets/issue_created.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    bitbucket.receiveEvent 'service.webhook', req

  it 'receive issue updated notification', (done) ->
    bitbucket.sendMessage = (message) ->
      message.quote.title.should.eql 'Catalyst Zhang updated an issue for project destec/test-bitbucket'
      message.quote.text.should.eql 'update the test issue'
      message.quote.redirectUrl.should.eql 'https://bitbucket.org/destec/test-bitbucket/issue/1/hi-what-is-issue'
      done()

    data = require './bitbucket_assets/issue_updated.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    bitbucket.receiveEvent 'service.webhook', req

  it 'receive pull request created notification', (done) ->
    bitbucket.sendMessage = (message) ->
      message.quote.title.should.eql 'Catalyst Zhang created a pull request for Test Bitbucket'
      message.quote.text.should.eql 'first br'
      message.quote.redirectUrl.should.eql 'https://bitbucket.org/destec/test-bitbucket/pull-request/1'
      done()

    data = require './bitbucket_assets/pullrequest_created.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    bitbucket.receiveEvent 'service.webhook', req

  it 'receive pull request updated notification', (done) ->
    bitbucket.sendMessage = (message) ->
      message.quote.title.should.eql 'Catalyst Zhang updated a pull request for Test Bitbucket'
      message.quote.text.should.eql 'first br'
      message.quote.redirectUrl.should.eql 'https://bitbucket.org/destec/test-bitbucket/pull-request/1'
      done()

    data = require './bitbucket_assets/pullrequest_updated.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    bitbucket.receiveEvent 'service.webhook', req

  it 'receive pull request fulfilled notification', (done) ->
    bitbucket.sendMessage = (message) ->
      message.quote.title.should.eql 'Catalyst Zhang fulfilled the pull request update pr'
      message.quote.text.should.eql ''
      message.quote.redirectUrl.should.eql 'https://bitbucket.org/destec/test-bitbucket/pull-request/1'
      done()

    data = require './bitbucket_assets/pullrequest_fulfilled.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    bitbucket.receiveEvent 'service.webhook', req

  it 'receive pull request rejected notification', (done) ->
    bitbucket.sendMessage = (message) ->
      message.quote.title.should.eql 'Catalyst Zhang rejected the pull request second pr'
      message.quote.text.should.eql ''
      message.quote.redirectUrl.should.eql 'https://bitbucket.org/destec/test-bitbucket/pull-request/2'
      done()

    data = require './bitbucket_assets/pullrequest_rejected.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    bitbucket.receiveEvent 'service.webhook', req

  it 'receive pull request comment created notification', (done) ->
    bitbucket.sendMessage = (message) ->
      message.quote.title.should.eql 'Catalyst Zhang created a comment for pull request update pr'
      message.quote.text.should.eql 'update pr'
      message.quote.redirectUrl.should.eql 'https://bitbucket.org/destec/test-bitbucket/pull-request/1'
      done()

    data = require './bitbucket_assets/pullrequest_comment_created.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    bitbucket.receiveEvent 'service.webhook', req

  it 'receive pull request comment updated notification', (done) ->
    bitbucket.sendMessage = (message) ->
      message.quote.title.should.eql 'Catalyst Zhang deleted a comment for pull request update pr'
      message.quote.text.should.eql 'update pr'
      message.quote.redirectUrl.should.eql 'https://bitbucket.org/destec/test-bitbucket/pull-request/1'
      done()

    data = require './bitbucket_assets/pullrequest_comment_deleted.json'
    req.headers = data.headers
    req.body = data.body

    req.integration =
      _id: 1
      token: '02ddb822d4000975005c76484364f1ee'

    bitbucket.receiveEvent 'service.webhook', req

  after cleanup
