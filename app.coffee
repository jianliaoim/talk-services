server = require './src/server'
logger = require('graceful-logger').format 'medium'

port = process.env.PORT or 7730
server.listen port, -> logger.info "Server listen on #{port}"
