# Initialize service
service = require '../src/service'
service.components = require './components'

# Test service
require './service'

# Subtestcases of each service
requireDir = require 'require-dir'
requireDir './services'
