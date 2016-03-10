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
    serviceUrl: 'http://127.0.0.1:7632/rss/worker'
  github:
    apiHost: 'http://127.0.0.1:7632/github'
  talkai:
    apikey: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    devid: "123456"
  trello:
    apiKey: 'aaa'
    apiHost: 'http://127.0.0.1:7632/trello'

# Load all services
require './loader'

require './servers/app'

requireDir './services'
