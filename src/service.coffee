requireDir = require 'require-dir'
path = require 'path'

service =
  register: require './register'
  loadAll: -> requireDir './services'
  load: (name) -> @loadAll()[name]
  static: (str) -> path.join __dirname, '../static', str
  i18n: (dict) -> dict
  apiHost: 'https://talk.ai/v1'
  userAgent: 'Talk Api Service V1'

module.exports = service
