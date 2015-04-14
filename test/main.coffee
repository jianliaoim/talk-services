# Initialize service
service = require './service'

# Test settings
settings = require './settings'

# Subtestcases of each service
requireDir = require 'require-dir'
requireDir './services'
