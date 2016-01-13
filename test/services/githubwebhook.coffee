should = require 'should'
loader = require '../../src/loader'
{req} = require '../util'
$githubwebhook = loader.load 'githubwebhook'
requireDir = require 'require-dir'

payloads = requireDir './github_assets'

describe 'Githubwebhook#Webhook', ->

  it 'receive commit comment', (done) ->
    req.body = payloads['commit-comment']
    req.headers['x-github-event'] = 'commit_comment'

    $githubwebhook.then (githubwebhook) ->
      githubwebhook.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.userName.should.eql 'sailxjx'
      message.attachments[0].data.userAvatarUrl.should.eql 'https://avatars.githubusercontent.com/u/909853?v=3'
      message.attachments[0].data.title.should.eql 'teambition/limbo commit comment by sailxjx'
      message.attachments[0].data.text.trim().should.eql '<p>Leave a commit comment</p>'
      message.attachments[0].data.redirectUrl.should.eql 'https://github.com/teambition/limbo/commit/507388aa1123b0e91fa2d17314b625802cd3f3fa#commitcomment-8535013'
    .nodeify done

  it 'receive create', (done) ->
    req.body = payloads['create']
    req.headers['x-github-event'] = 'create'

    $githubwebhook.then (githubwebhook) ->
      githubwebhook.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql 'teambition/limbo branch test created by sailxjx'
      message.attachments[0].data.redirectUrl.should.eql 'https://github.com/teambition/limbo'
    .nodeify done

  it 'receive delete', (done) ->
    req.body = payloads['delete']
    req.headers['x-github-event'] = 'delete'

    $githubwebhook.then (githubwebhook) ->
      githubwebhook.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql 'teambition/limbo branch test deleted by sailxjx'
      message.attachments[0].data.redirectUrl.should.eql 'https://github.com/teambition/limbo'
    .nodeify done

  it 'receive fork', (done) ->
    req.body = payloads['fork']
    req.headers['x-github-event'] = 'fork'

    $githubwebhook.then (githubwebhook) ->
      githubwebhook.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql 'teambition/limbo forked to sailxjx/limbo'
      message.attachments[0].data.redirectUrl.should.eql 'https://github.com/sailxjx/limbo'
    .nodeify done

  it 'receive issue comment', (done) ->
    req.body = payloads['issue-comment']
    req.headers['x-github-event'] = 'issue_comment'

    $githubwebhook.then (githubwebhook) ->
      githubwebhook.receiveEvent 'service.webhook', req
    .then (message) ->
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
      message.attachments[0].data.redirectUrl.should.eql 'https://github.com/sailxjx/mms/issues/1#issuecomment-62661320'
    .nodeify done

  it 'receive issues', (done) ->
    req.body = payloads['issues']
    req.headers['x-github-event'] = 'issues'

    $githubwebhook.then (githubwebhook) ->
      githubwebhook.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql "teambition/limbo issue opened test"
      message.attachments[0].data.text.should.eql '<p>FOr integration</p>\n<ul>\n<li>1</li>\n<li>2</li>\n<li>3</li>\n</ul>\n<pre><code class="lang-coffeescript">foo -&gt;\n</code></pre>\n'
      message.attachments[0].data.redirectUrl.should.eql 'https://github.com/teambition/limbo/issues/2'
    .nodeify done

  it 'receive pull request', (done) ->
    req.body = payloads['pull-request']
    req.headers['x-github-event'] = 'pull_request'

    $githubwebhook.then (githubwebhook) ->
      githubwebhook.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql 'teambition/limbo pull request update readme'
      message.attachments[0].data.text.should.eql '<p>For test</p>\n'
      message.attachments[0].data.redirectUrl.should.eql 'https://github.com/teambition/limbo/pull/3'
    .nodeify done

  it 'receive pull request review comment', (done) ->
    req.body = payloads['pull-request-review-comment']
    req.headers['x-github-event'] = 'pull_request_review_comment'

    $githubwebhook.then (githubwebhook) ->
      githubwebhook.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql 'teambition/limbo review comment by sailxjx'
      message.attachments[0].data.text.should.eql '<p>Review CCCC</p>\n'
      message.attachments[0].data.redirectUrl.should.eql 'https://github.com/teambition/limbo/pull/3#discussion_r20270745'
    .nodeify done

  it 'receive push', (done) ->
    req.body = payloads['push']
    req.headers['x-github-event'] = 'push'

    $githubwebhook.then (githubwebhook) ->
      githubwebhook.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql 'teambition/limbo commits to refs/heads/master'
      message.attachments[0].data.text.should.eql [
        '<a href="https://github.com/teambition/limbo/commit/20b0e57a9acaf05987da1813480739caece54999" target="_blank"><code>20b0e5:</code></a> [sailxjx] update readme<br>'
        '<a href="https://github.com/teambition/limbo/commit/90654779287d9de686422daaa4dbff0b4d6e5542" target="_blank"><code>906547:</code></a> [Xu Jingxin] Merge pull request #3 from sailxjx/master\n\nupdate readme<br>'
      ].join ''
      message.attachments[0].data.redirectUrl.should.eql 'https://github.com/teambition/limbo/commit/90654779287d9de686422daaa4dbff0b4d6e5542'
    .nodeify done
