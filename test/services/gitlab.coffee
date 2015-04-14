should = require 'should'
service = require '../../src/service'
{prepare, cleanup, req, res} = require '../util'
gitlab = service.load 'gitlab'

issuePayload = {
  "object_kind": "issue",
  "user": {
    "name": "sailxjx",
    "username": "sailxjx",
    "avatar_url": "https://code.teambition.com//uploads/user/avatar/7/sailxjx.png"
  },
  "object_attributes": {
    "id": 10,
    "title": "Some Issue",
    "assignee_id": null,
    "author_id": 7,
    "project_id": 21,
    "created_at": "2015-01-26 10:01:20 +0800",
    "updated_at": "2015-01-26 10:01:20 +0800",
    "position": 0,
    "branch_name": null,
    "description": "```\r\nSomeCode\r\n```",
    "milestone_id": null,
    "state": "opened",
    "iid": 1,
    "url": "https://code.teambition.com/talk/talk-core/issues/1",
    "action": "open"
  }
}

newBranchPayload = {
  "before": "0000000000000000000000000000000000000000",
  "after": "8dfb272d9e9bc2276c0c72e391318c4ec29bcb4c",
  "ref": "refs/heads/feature/gitlab",
  "checkout_sha": "8dfb272d9e9bc2276c0c72e391318c4ec29bcb4c",
  "user_id": 7,
  "user_name": "sailxjx",
  "project_id": 21,
  "repository": {
    "name": "talk-core",
    "url": "git@code.teambition.com:talk/talk-core.git",
    "description": "",
    "homepage": "https://code.teambition.com/talk/talk-core"
  },
  "commits": [],
  "total_commits_count": 0
}

mergePayload = {
  "object_kind": "merge_request",
  "user": {
    "name": "sailxjx",
    "username": "sailxjx",
    "avatar_url": "https://code.teambition.com//uploads/user/avatar/7/sailxjx.png"
  },
  "object_attributes": {
    "id": 465,
    "target_branch": "master",
    "source_branch": "feature/gitlab",
    "source_project_id": 21,
    "author_id": 7,
    "assignee_id": null,
    "title": "Feature/gitlab",
    "created_at": "2015-01-26 09:56:49 +0800",
    "updated_at": "2015-01-26 09:56:49 +0800",
    "milestone_id": null,
    "state": "opened",
    "merge_status": "unchecked",
    "target_project_id": 21,
    "iid": 2,
    "description": "Merge GitLab Feature",
    "position": 0,
    "locked_at": null,
    "source": {
      "name": "talk-core",
      "ssh_url": "git@code.teambition.com:talk/talk-core.git",
      "http_url": "https://code.teambition.com/talk/talk-core.git",
      "namespace": "Talk",
      "visibility_level": 0
    },
    "target": {
      "name": "talk-core",
      "ssh_url": "git@code.teambition.com:talk/talk-core.git",
      "http_url": "https://code.teambition.com/talk/talk-core.git",
      "namespace": "Talk",
      "visibility_level": 0
    },
    "last_commit": {
      "id": "e523992d8b2f2adb720224868e26cce1c81e061a",
      "message": "add gitlab repository homepage\n",
      "timestamp": "2015-01-26T09:55:51+08:00",
      "url": "https://code.teambition.com/talk/talk-core/commit/e523992d8b2f2adb720224868e26cce1c81e061a",
      "author": {
        "name": "Xu Jingxin",
        "email": "sailxjx@gmail.com"
      }
    }
  }
}

pushPayload = {
  "before": "95790bf891e76fee5e1747ab589903a6a1f80f22",
  "after": "da1560886d4f094c3e6c9ef40349f7d38b5d27d7",
  "ref": "refs/heads/master",
  "user_id": 4,
  "user_name": "John Smith",
  "project_id": 15,
  "repository": {
    "name": "Diaspora",
    "url": "git@localhost:diaspora.git",
    "description": "",
    "homepage": "http://localhost/diaspora",
  },
  "commits": [
    {
      "id": "b6568db1bc1dcd7f8b4d5a946b0b91f9dacd7327",
      "message": "Update Catalan translation to e38cb41.",
      "timestamp": "2011-12-12T14:27:31+02:00",
      "url": "http://localhost/diaspora/commits/b6568db1bc1dcd7f8b4d5a946b0b91f9dacd7327",
      "author": {
        "name": "Jordi Mallach",
        "email": "jordi@softcatala.org",
      }
    },
    {
      "id": "da1560886d4f094c3e6c9ef40349f7d38b5d27d7",
      "message": "fixed readme",
      "timestamp": "2012-01-03T23:36:29+02:00",
      "url": "http://localhost/diaspora/commits/da1560886d4f094c3e6c9ef40349f7d38b5d27d7",
      "author": {
        "name": "GitLab dev user",
        "email": "gitlabdev@dv6700.(none)",
      },
    },
  ],
  "total_commits_count": 4
}

describe 'GitLab#Webhook', ->

  before prepare

  req.integration =
    _id: 'xxx'
    _teamId: '123'
    _roomId: '456'

  it 'receive push webhook', (done) ->
    gitlab.sendMessage = (message) ->
      message.quote.title.should.eql 'New event from gitlab'
      message.quote.text.should.eql [
        '<a href="http://localhost/diaspora" target="_blank">Diaspora</a> new commits<br>'
        '<a href="http://localhost/diaspora/commits/b6568db1bc1dcd7f8b4d5a946b0b91f9dacd7327" target="_blank">'
        '<code>b6568d:</code></a> Update Catalan translation to e38cb41.<br>'
        '<a href="http://localhost/diaspora/commits/da1560886d4f094c3e6c9ef40349f7d38b5d27d7" target="_blank">'
        '<code>da1560:</code></a> fixed readme<br>'
      ].join ''

    req.body = pushPayload

    gitlab.receiveEvent 'webhook', req, res
    .then -> done()
    .catch done

  it 'receive issue webhook', (done) ->
    gitlab.sendMessage = (message) ->
      message.quote.text.should.eql '''
      <a href="https://code.teambition.com/talk/talk-core/issues/1" target="_blank">Some Issue</a> [opened]<br>
      <pre><code>SomeCode
      </code></pre>
      '''

    req.body = issuePayload

    gitlab.receiveEvent 'webhook', req, res
    .then -> done()
    .catch done

  it 'receive merge webhook', (done) ->
    gitlab.sendMessage = (message) ->
      message.quote.text.should.eql '''
      <a href="https://code.teambition.com/talk/talk-core/commit/e523992d8b2f2adb720224868e26cce1c81e061a" target="_blank">Feature/gitlab</a> [opened]<br>\n<p>Merge GitLab Feature</p>\n
      '''

    req.body = mergePayload

    gitlab.receiveEvent 'webhook', req, res
    .then -> done()
    .catch done

  after cleanup
