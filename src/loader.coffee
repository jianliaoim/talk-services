path = require 'path'

_ = require 'lodash'
Promise = require 'bluebird'

# Sort services
serviceNames = [
  'incoming', 'outgoing', 'robot', 'teambition', 'rss', 'github', 'firim', 'jobtong', 'pingxx',
  'gitlab', 'coding', 'gitcafe', 'bitbucket', 'jinshuju', 'jiankongbao', 'kf5', 'swathub',
  'csdn', 'oschina', 'buildkite', 'codeship', 'jira', 'qingcloud', 'mikecrm', 'bughd',
  'travis', 'jenkins', 'circleci', 'magnumci', 'newrelic', 'heroku', 'goldxitudaily',
  'weibo'
]

class ServiceLoader

  config: {}

  loadAll: ->
    unless @$_services
      Service = require './service'
      _serviceInstances = serviceNames.map (serviceName) ->
        service = new Service
        service.register serviceName
        require("./services/#{serviceName}").call service, service
        service
      @$_services = Promise.props _.zipObject serviceNames, _serviceInstances
    @$_services

  load: (name) -> @loadAll().then (serviceMap) -> serviceMap[name]

  settings: ->
    unless @$_settings
      @$_settings = @loadAll().then (services) ->
        _.mapValues services, (service) -> service.toJSON()
    @$_settings

loader = new ServiceLoader

module.exports = loader
