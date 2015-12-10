# Initialize service
requireDir = require 'require-dir'
loader = require '../src/loader'
loader.config =
  apiHost: ""
  cdnPrefix: ""

# Load all services
require './loader'

# requireDir './servers'

# require './services/incoming'
require './services/outgoing'

