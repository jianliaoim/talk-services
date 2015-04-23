# Initialize service
service = require '../src/service'
service.components = require './components'

# # Test service
# require './service'

# Subtestcases of each service
require './services/coding'
# requireDir = require 'require-dir'
# requireDir './services'
