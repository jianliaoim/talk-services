requireDir = require 'require-dir'
path = require 'path'

service =
  register: require './register'
  loadAll: -> requireDir './services'
  static: (str) -> path.join __dirname, '../static', str
  i18n: (dict) -> dict

# Components should be initialized before services loaded
Object.defineProperty service, 'components', get: -> @_components

module.exports = service
