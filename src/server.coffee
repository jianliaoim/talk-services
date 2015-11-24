express = require 'express'
sundae = require 'sundae'
requireDir = require 'require-dir'

module.exports = app = sundae express()

require './initializers/express'
require './initializers/error'
require './initializers/request'

requireDir './apis', recurse: true

require './initializers/routes'
