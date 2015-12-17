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

# # Load all services
# require './loader'

# requireDir './servers'

# require './services/incoming'
# require './services/outgoing'
# require './services/robot'  # Not implement
# require './services/teambition'
# require './services/rss'
require './services/github'
# require './services/firim'
