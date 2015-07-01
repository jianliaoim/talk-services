should = require 'should'
requireDir = require 'require-dir'

service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
gitcafe = service.load 'gitcafe'

payloads = requireDir './gitcafe_assets'

describe 'GitCafe#Webhook', ->

  before prepare

  req.integration =
    _id: 'xxx'
    _teamId: '123'
    _roomId: '456'

  it 'receive null webhook', (done) ->

    data = payloads['empty_event']
    req.headers = data.headers
    req.body = data.body

    gitcafe.receiveEvent 'service.webhook', req
    .catch (err) -> 
      err.message.should.eql 'Unknown GitCafe event type'
      done()
    
  it 'receive commit comment webhook', (done) ->
    gitcafe.sendMessage = (message) ->
      message.quote.title.should.eql 'destec 评论了提交 fix'
      message.quote.text.should.eql '<p>add a new comment for the <code>fix</code>(<code>1df6f2819b212a9cc9ece1ddf238bbc5e9cdb956</code>) <a href="https://gitcafe.com/destec/test/commit/1df6f2819b212a9cc9ece1ddf238bbc5e9cdb956">url</a> commit</p>\n'
      message.quote.redirectUrl.should.eql 'https://gitcafe.com/destec/test/commit/1df6f2819b212a9cc9ece1ddf238bbc5e9cdb956#comment-559224b544c2439cf20008b7'
      done()

    data = payloads['commit_comment']
    req.headers = data.headers
    req.body = data.body

    gitcafe.receiveEvent 'service.webhook', req

  it 'receive pull request webhook', (done) ->
    gitcafe.sendMessage = (message) ->
      message.quote.title.should.eql 'destec 向 test 项目发起了 Pull Request 请求'
      message.quote.text.should.eql '<p>test pull request</p>\n (<p>test pull request content</p>\n)'
      message.quote.redirectUrl.should.eql 'https://gitcafe.com/destec/test/pull/2'
      done()

    data = payloads['pull_request']
    req.headers = data.headers
    req.body = data.body

    gitcafe.receiveEvent 'service.webhook', req

  it 'receive pull request comment webhook', (done) ->
    gitcafe.sendMessage = (message) ->
      message.quote.title.should.eql 'destec 评论了 test 项目的 Pull Request 请求'
      message.quote.text.should.eql '<p>test comment for the test pr</p>\n'
      message.quote.redirectUrl.should.eql 'https://gitcafe.com/destec/test/pull/2#comment-5592258444c2439cf2000903'
      done()

    data = payloads['pull_request_comment']
    req.headers = data.headers
    req.body = data.body

    gitcafe.receiveEvent 'service.webhook', req

  it 'receive push webhook', (done) ->
    gitcafe.sendMessage = (message) ->
      message.quote.title.should.eql 'destec 向 test 项目提交了代码'
      message.quote.text.should.eql '<a href="https://gitcafe.com/destec/test/commit/1df6f2819b212a9cc9ece1ddf238bbc5e9cdb956" target="_blank"><code>1df6f2:</code></a> fix<br>'
      message.quote.redirectUrl.should.eql 'https://gitcafe.com/destec/test/commits/master'
      done()

    data = payloads['push']
    req.headers = data.headers
    req.body = data.body

    gitcafe.receiveEvent 'service.webhook', req

  it 'receive ticket webhook', (done) ->
    gitcafe.sendMessage = (message) ->
      message.quote.title.should.eql 'destec 在 test 项目创建了工单'
      message.quote.text.should.eql '<p>new ticket</p>\n (<h2 id="this-is-a-test-ticket-">this is a test ticket.</h2>\n<blockquote>\n<p>and some ref.</p>\n</blockquote>\n)'
      message.quote.redirectUrl.should.eql 'https://gitcafe.com/destec/test/tickets/1'
      done()

    data = payloads['ticket']
    req.headers = data.headers
    req.body = data.body

    gitcafe.receiveEvent 'service.webhook', req

  it 'receive ticket comment webhook', (done) ->
    gitcafe.sendMessage = (message) ->
      message.quote.title.should.eql 'destec 评论了工单 new ticket'
      message.quote.text.should.eql '<p><em> this is a test comment for the test ticket. </em></p>\n<ul>\n<li>this is a test comment for the test ticket. *</li>\n</ul>\n'
      message.quote.redirectUrl.should.eql 'https://gitcafe.com/destec/test/tickets/1#comment-559212c944c2434bca0001d5'
      done()
      
    data = payloads['ticket_comment']
    req.headers = data.headers
    req.body = data.body

    gitcafe.receiveEvent 'service.webhook', req

  after cleanup
