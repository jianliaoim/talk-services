should = require 'should'
requireDir = require 'require-dir'
Promise = require 'bluebird'

service = require '../../src/service'
config = require '../config'
{prepare, cleanup, req, res} = require '../util'
github = service.load 'github'
{limbo} = service.components
{IntegrationModel} = limbo.use 'talk'

payloads = requireDir './github_assets'

describe 'Github#IntegrationHooks', ->

  return  # Skip test with github apis

  unless config.github?.token and config.github?.repos
    return console.error """
    Github token and repos not exist
    Add them in config.json to test github service
    """

  @timeout 10000

  integration = new IntegrationModel
    category: 'github'
    token: config.github.token
    notifications:
      push: 1
    repos: [config.github.repos]

  hookId = null

  before prepare

  it 'should create github hook when integration created', (done) ->
    req.integration = integration
    github.receiveEvent 'integration.create', req, res
    .then ->
      integration.data[config.github.repos].hookId.should.be.type 'number'
      hookId = integration.data[config.github.repos].hookId
      new Promise (resolve, reject) ->
        integration.save (err, integration) ->
          return reject(err) if err
          resolve integration
    .catch done
    .then -> done()

  it 'should update github hook when integration updated', (done) ->
    integration.notifications =
      push: 1
      create: 1
    github.receiveEvent 'integration.update', req, res
    .then ->
      # Hook id is not changed
      integration.data[config.github.repos].hookId.should.eql hookId
      done()
    .catch done

  it 'should remove the github hook when integration removed', (done) ->
    github.receiveEvent 'integration.remove', req, res
    .then -> done()
    .catch done

  after cleanup

describe 'Github#Webhook', ->

  before prepare

  req.integration = _id: 'xxx'

  it 'receive commit comment', (done) ->
    github.sendMessage = (message) ->
      message.quote.userName.should.eql 'sailxjx'
      message.quote.userAvatarUrl.should.eql 'https://avatars.githubusercontent.com/u/909853?v=3'
      message.quote.title.should.eql 'teambition/limbo commit comment by sailxjx'
      message.quote.text.trim().should.eql '<p>Leave a commit comment</p>'
      message.quote.redirectUrl.should.eql 'https://github.com/teambition/limbo/commit/507388aa1123b0e91fa2d17314b625802cd3f3fa#commitcomment-8535013'

    req.body = payloads['commit-comment']
    req.headers['x-github-event'] = 'commit_comment'
    github.receiveEvent 'webhook', req, res
    .then -> done()
    .catch done

  it 'receive create', (done) ->
    github.sendMessage = (message) ->
      message.quote.title.should.eql 'teambition/limbo branch test created by sailxjx'
      message.quote.redirectUrl.should.eql 'https://github.com/teambition/limbo'

    req.body = payloads['create']
    req.headers['x-github-event'] = 'create'
    github.receiveEvent 'webhook', req, res
    .then -> done()
    .catch done

  it 'receive delete', (done) ->
    github.sendMessage = (message) ->
      message.quote.title.should.eql 'teambition/limbo branch test deleted by sailxjx'
      message.quote.redirectUrl.should.eql 'https://github.com/teambition/limbo'

    req.body = payloads['delete']
    req.headers['x-github-event'] = 'delete'
    github.receiveEvent 'webhook', req, res
    .then -> done()
    .catch done

  it 'receive fork', (done) ->
    github.sendMessage = (message) ->
      message.quote.title.should.eql 'teambition/limbo forked to sailxjx/limbo'
      message.quote.redirectUrl.should.eql 'https://github.com/sailxjx/limbo'

    req.body = payloads['fork']
    req.headers['x-github-event'] = 'fork'
    github.receiveEvent 'webhook', req, res
    .then -> done()
    .catch done

  it 'receive issue comment', (done) ->
    github.sendMessage = (message) ->
      message.quote.title.should.eql 'sailxjx/mms issue comment by sailxjx'
      message.quote.text.should.eql '''
      <h1 id="markdown">Markdown</h1>
      <ul>
      <li>a</li>
      <li>b</li>
      <li>c</li>
      </ul>
      <pre><code class="lang-coffeescript">foo = -&gt;
      </code></pre>\n
      '''
      message.quote.redirectUrl.should.eql 'https://github.com/sailxjx/mms/issues/1#issuecomment-62661320'

    req.body = payloads['issue-comment']
    req.headers['x-github-event'] = 'issue_comment'
    github.receiveEvent 'webhook', req, res
    .then -> done()
    .catch done

  it 'receive issues', (done) ->
    github.sendMessage = (message) ->
      message.quote.title.should.eql "teambition/limbo issue opened test"
      message.quote.text.should.eql '<p>FOr integration</p>\n<ul>\n<li>1</li>\n<li>2</li>\n<li>3</li>\n</ul>\n<pre><code class="lang-coffeescript">foo -&gt;\n</code></pre>\n'
      message.quote.redirectUrl.should.eql 'https://github.com/teambition/limbo/issues/2'

    req.body = payloads['issues']
    req.headers['x-github-event'] = 'issues'
    github.receiveEvent 'webhook', req, res
    .then -> done()
    .catch done

  it 'receive pull request', (done) ->
    github.sendMessage = (message) ->
      message.quote.title.should.eql 'teambition/limbo pull request update readme'
      message.quote.text.should.eql '<p>For test</p>\n'
      message.quote.redirectUrl.should.eql 'https://github.com/teambition/limbo/pull/3'

    req.body = payloads['pull-request']
    req.headers['x-github-event'] = 'pull_request'
    github.receiveEvent 'webhook', req, res
    .then -> done()
    .catch done

  it 'receive pull request review comment', (done) ->
    github.sendMessage = (message) ->
      message.quote.title.should.eql 'teambition/limbo review comment by sailxjx'
      message.quote.text.should.eql '<p>Review CCCC</p>\n'
      message.quote.redirectUrl.should.eql 'https://github.com/teambition/limbo/pull/3#discussion_r20270745'

    req.body = payloads['pull-request-review-comment']
    req.headers['x-github-event'] = 'pull_request_review_comment'
    github.receiveEvent 'webhook', req, res
    .then -> done()
    .catch done

  it 'receive push', (done) ->
    github.sendMessage = (message) ->
      message.quote.title.should.eql 'teambition/limbo commits to refs/heads/master'
      message.quote.text.should.eql [
        '<a href="https://github.com/teambition/limbo/commit/20b0e57a9acaf05987da1813480739caece54999" target="_blank"><code>20b0e5:</code></a> update readme<br>'
        '<a href="https://github.com/teambition/limbo/commit/90654779287d9de686422daaa4dbff0b4d6e5542" target="_blank"><code>906547:</code></a> Merge pull request #3 from sailxjx/master\n\nupdate readme<br>'
      ].join ''
      message.quote.redirectUrl.should.eql 'https://github.com/teambition/limbo/commit/90654779287d9de686422daaa4dbff0b4d6e5542'

    req.body = payloads['push']
    req.headers['x-github-event'] = 'push'
    github.receiveEvent 'webhook', req, res
    .then -> done()
    .catch done

  after cleanup
