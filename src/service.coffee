path = require 'path'

_ = require 'lodash'
requireDir = require 'require-dir'
Promise = require 'bluebird'

_services = null
_robotToServices = null

service =

  register: require './register'

  loadAll: ->
    unless _services
      _services = requireDir './services'

      props = _.mapValues _services, (service) ->
        Object.defineProperty service, '$promise', value: service.initialize()
        service.$promise

      Object.defineProperty _services, '$promise', value: Promise.props props

    _services

  load: (name) -> @loadAll()[name]

  static: (str) -> path.join __dirname, '../static', str

  i18n: (locales) -> locales

  getRobotOf: (name) -> @load(name).robot

  apiHost: 'https://talk.ai/v1'

  userAgent: 'Talk Api Service V1'

  # Complete actived service list
  activedServices: [
    'incoming', 'outgoing', 'robot', 'teambition', 'rss', 'github', 'firim', 'jobtong', 'pingxx'
    'gitlab', 'coding', 'gitcafe', 'bitbucket', 'jinshuju', 'jiankongbao', 'kf5', 'swathub',
    'csdn', 'oschina', 'buildkite', 'codeship', 'jira', 'qingcloud', 'mikecrm', 'bughd',
    'travis', 'jenkins', 'circleci', 'magnumci', 'newrelic', 'heroku'
    'weibo'
  ]

module.exports = service
