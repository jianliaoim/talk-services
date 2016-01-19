should = require 'should'
requireDir = require 'require-dir'

loader = require '../../src/loader'
{req} = require '../util'
$gitlab = loader.load 'gitlab'

payloads = requireDir './gitlab_assets'

describe 'GitLab#Webhook', ->

  req.integration =
    _id: 'xxx'
    _teamId: '123'
    _roomId: '456'

  it 'receive push webhook', (done) ->
    req.body = payloads['push']

    $gitlab.then (gitlab) ->
      gitlab.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql 'Diaspora new commits'
      message.attachments[0].data.text.should.eql [
        '<a href="http://localhost/diaspora/commits/b6568db1bc1dcd7f8b4d5a946b0b91f9dacd7327" target="_blank">'
        '<code>b6568d:</code></a> [Jordi Mallach] Update Catalan translation to e38cb41.<br>'
        '<a href="http://localhost/diaspora/commits/da1560886d4f094c3e6c9ef40349f7d38b5d27d7" target="_blank">'
        '<code>da1560:</code></a> [GitLab dev user] fixed readme<br>'
      ].join ''
    .nodeify done

  it 'receive issue webhook', (done) ->
    req.body = payloads['issue']

    $gitlab.then (gitlab) -> gitlab.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql '[opened] Some Issue'
      message.attachments[0].data.text.should.eql '''
      <pre><code>SomeCode
      </code></pre>
      '''
    .nodeify done

  it 'receive merge webhook', (done) ->
    req.body = payloads['merge']

    $gitlab.then (gitlab) -> gitlab.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql '[opened] Feature/gitlab'
      message.attachments[0].data.text.should.eql '''
      <p>Merge GitLab Feature</p>\n
      '''
    .nodeify done
