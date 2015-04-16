should = require 'should'
requireDir = require 'require-dir'

service = require '../../src/service'
{prepare, cleanup, req, res} = require '../util'
gitlab = service.load 'gitlab'

payloads = requireDir './gitlab_assets'

describe 'GitLab#Webhook', ->

  before prepare

  req.integration =
    _id: 'xxx'
    _teamId: '123'
    _roomId: '456'

  it 'receive push webhook', (done) ->
    gitlab.sendMessage = (message) ->
      message.quote.title.should.eql 'Diaspora new commits'
      message.quote.text.should.eql [
        '<a href="http://localhost/diaspora/commits/b6568db1bc1dcd7f8b4d5a946b0b91f9dacd7327" target="_blank">'
        '<code>b6568d:</code></a> Update Catalan translation to e38cb41.<br>'
        '<a href="http://localhost/diaspora/commits/da1560886d4f094c3e6c9ef40349f7d38b5d27d7" target="_blank">'
        '<code>da1560:</code></a> fixed readme<br>'
      ].join ''

    req.body = payloads['push']

    gitlab.receiveEvent 'webhook', req, res
    .then -> done()
    .catch done

  it 'receive issue webhook', (done) ->
    gitlab.sendMessage = (message) ->
      message.quote.title.should.eql '[opened] Some Issue'
      message.quote.text.should.eql '''
      <pre><code>SomeCode
      </code></pre>
      '''

    req.body = payloads['issue']

    gitlab.receiveEvent 'webhook', req, res
    .then -> done()
    .catch done

  it 'receive merge webhook', (done) ->
    gitlab.sendMessage = (message) ->
      message.quote.title.should.eql '[opened] Feature/gitlab'
      message.quote.text.should.eql '''
      <p>Merge GitLab Feature</p>\n
      '''

    req.body = payloads['merge']

    gitlab.receiveEvent 'webhook', req, res
    .then -> done()
    .catch done

  after cleanup
