path = require 'path'

_ = require 'lodash'
requireDir = require 'require-dir'
Promise = require 'bluebird'

_services = null

service =

  register: require './register'

  loadAll: ->
    unless _services
      _services = requireDir './services'
      props = _.mapValues _services, (service) ->
        service.$promise = service.initialize()
      _services.$promise = Promise.props props
    _services

  load: (name) -> @loadAll()[name]

  static: (str) -> path.join __dirname, '../static', str

  i18n: (locales) -> locales

  getRobotOf: (name) -> @load(name).robot

  apiHost: 'https://talk.ai/v1'

  userAgent: 'Talk Api Service V1'

module.exports = service
