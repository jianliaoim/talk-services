# Initialize service
requireDir = require 'require-dir'
# Load mocked servers
require './servers/app'

loader = require '../src/loader'
loader.config =
  apiHost: ""
  cdnPrefix: ""
  talkAccountApiUrl: "http://127.0.0.1:7632/account"
  teambition:
    clientSecret: 'abc'
    host: 'http://127.0.0.1:7632/tb'
  rss:
    serviceUrl: 'http://127.0.0.1:7411'
  github:
    apiHost: 'http://127.0.0.1:7632/github'

# Load all services
require './loader'

requireDir './servers'

require './services/incoming'
require './services/outgoing'
# require './services/robot'  # Not implement
require './services/teambition'
require './services/rss'
require './services/github'
require './services/firim'
require './services/jobtong'
require './services/pingxx'
require './services/gitlab'
require './services/coding'
require './services/gitcafe'
require './services/bitbucket'
require './services/jinshuju'
require './services/jiankongbao'
require './services/kf5'
require './services/swathub'
require './services/csdn'
require './services/oschina'
require './services/buildkite'
require './services/codeship'
require './services/jira'
require './services/qingcloud'
require './services/mikecrm'
require './services/bughd'
require './services/travis'
require './services/jenkins'
require './services/circleci'
require './services/magnumci'
require './services/newrelic'
require './services/heroku'
require './services/goldxitudaily'
require './services/weibo'
require './services/cloudinsight'
