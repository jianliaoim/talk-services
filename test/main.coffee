# Initialize service
requireDir = require 'require-dir'
service = require '../src/service'
service.components = require './components'
service.sdk = require './sdk'

servers = requireDir './servers'

# Test service
require './service'

# Subtestcases of each service
requireDir './services'
