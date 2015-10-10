should = require 'should'
requireDir = require 'require-dir'
Promise = require 'bluebird'

service = require '../../src/service'
config = require '../config'
{prepare, cleanup, req} = require '../util'
assembla = service.load 'assembla'
{limbo} = service.components
{IntegrationModel} = limbo.use 'talk'

payloads = requireDir './assembla_assets'

describe 'Assembla#Webhook', ->

  before prepare

  req.integration = _id: 'xxx'

  it 'receive commit comment', (done) ->
    assembla.sendMessage = (message) ->
      message.attachments[0].data.userName.should.eql 'sailxjx'
      message.attachments[0].data.userAvatarUrl.should.eql 'https://avatars.assemblausercontent.com/u/909853?v=3'
      message.attachments[0].data.title.should.eql 'teambition/limbo commit comment by sailxjx'
      message.attachments[0].data.text.trim().should.eql '<p>Leave a commit comment</p>'
      message.attachments[0].data.redirectUrl.should.eql 'https://assembla.com/teambition/limbo/commit/507388aa1123b0e91fa2d17314b625802cd3f3fa#commitcomment-8535013'

    req.body = payloads['commit-comment']
    req.headers['x-assembla-event'] = 'commit_comment'
    assembla.receiveEvent 'service.webhook', req
    .then -> done()
    .catch done

  it 'receive create', (done) ->
    assembla.sendMessage = (message) ->
      message.attachments[0].data.title.should.eql 'teambition/limbo branch test created by sailxjx'
      message.attachments[0].data.redirectUrl.should.eql 'https://assembla.com/teambition/limbo'

    req.body = payloads['create']
    req.headers['x-assembla-event'] = 'create'
    assembla.receiveEvent 'service.webhook', req
    .then -> done()
    .catch done

  it 'receive delete', (done) ->
    assembla.sendMessage = (message) ->
      message.attachments[0].data.title.should.eql 'teambition/limbo branch test deleted by sailxjx'
      message.attachments[0].data.redirectUrl.should.eql 'https://assembla.com/teambition/limbo'

    req.body = payloads['delete']
    req.headers['x-assembla-event'] = 'delete'
    assembla.receiveEvent 'service.webhook', req
    .then -> done()
    .catch done

  it 'receive fork', (done) ->
    assembla.sendMessage = (message) ->
      message.attachments[0].data.title.should.eql 'teambition/limbo forked to sailxjx/limbo'
      message.attachments[0].data.redirectUrl.should.eql 'https://assembla.com/sailxjx/limbo'

    req.body = payloads['fork']
    req.headers['x-assembla-event'] = 'fork'
    assembla.receiveEvent 'service.webhook', req
    .then -> done()
    .catch done

  it 'receive issue comment', (done) ->
    assembla.sendMessage = (message) ->
      message.attachments[0].data.title.should.eql 'sailxjx/mms issue comment by sailxjx'
      message.attachments[0].data.text.should.eql '''
      <h1 id="markdown">Markdown</h1>
      <ul>
      <li>a</li>
      <li>b</li>
      <li>c</li>
      </ul>
      <pre><code class="lang-coffeescript">foo = -&gt;
      </code></pre>\n
      '''
      message.attachments[0].data.redirectUrl.should.eql 'https://assembla.com/sailxjx/mms/issues/1#issuecomment-62661320'

    req.body = payloads['issue-comment']
    req.headers['x-assembla-event'] = 'issue_comment'
    assembla.receiveEvent 'service.webhook', req
    .then -> done()
    .catch done

  it 'receive issues', (done) ->
    assembla.sendMessage = (message) ->
      message.attachments[0].data.title.should.eql "teambition/limbo issue opened test"
      message.attachments[0].data.text.should.eql '<p>FOr integration</p>\n<ul>\n<li>1</li>\n<li>2</li>\n<li>3</li>\n</ul>\n<pre><code class="lang-coffeescript">foo -&gt;\n</code></pre>\n'
      message.attachments[0].data.redirectUrl.should.eql 'https://assembla.com/teambition/limbo/issues/2'

    req.body = payloads['issues']
    req.headers['x-assembla-event'] = 'issues'
    assembla.receiveEvent 'service.webhook', req
    .then -> done()
    .catch done

  it 'receive pull request', (done) ->
    assembla.sendMessage = (message) ->
      message.attachments[0].data.title.should.eql 'teambition/limbo pull request update readme'
      message.attachments[0].data.text.should.eql '<p>For test</p>\n'
      message.attachments[0].data.redirectUrl.should.eql 'https://assembla.com/teambition/limbo/pull/3'

    req.body = payloads['pull-request']
    req.headers['x-assembla-event'] = 'pull_request'
    assembla.receiveEvent 'service.webhook', req
    .then -> done()
    .catch done

  it 'receive pull request review comment', (done) ->
    assembla.sendMessage = (message) ->
      message.attachments[0].data.title.should.eql 'teambition/limbo review comment by sailxjx'
      message.attachments[0].data.text.should.eql '<p>Review CCCC</p>\n'
      message.attachments[0].data.redirectUrl.should.eql 'https://assembla.com/teambition/limbo/pull/3#discussion_r20270745'

    req.body = payloads['pull-request-review-comment']
    req.headers['x-assembla-event'] = 'pull_request_review_comment'
    assembla.receiveEvent 'service.webhook', req
    .then -> done()
    .catch done

  it 'receive push', (done) ->
    assembla.sendMessage = (message) ->
      message.attachments[0].data.title.should.eql 'teambition/limbo commits to refs/heads/master'
      message.attachments[0].data.text.should.eql [
        '<a href="https://assembla.com/teambition/limbo/commit/20b0e57a9acaf05987da1813480739caece54999" target="_blank"><code>20b0e5:</code></a> update readme<br>'
        '<a href="https://assembla.com/teambition/limbo/commit/90654779287d9de686422daaa4dbff0b4d6e5542" target="_blank"><code>906547:</code></a> Merge pull request #3 from sailxjx/master\n\nupdate readme<br>'
      ].join ''
      message.attachments[0].data.redirectUrl.should.eql 'https://assembla.com/teambition/limbo/commit/90654779287d9de686422daaa4dbff0b4d6e5542'

    req.body = payloads['push']
    req.headers['x-assembla-event'] = 'push'
    assembla.receiveEvent 'service.webhook', req
    .then -> done()
    .catch done

  after cleanup
