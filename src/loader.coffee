path = require 'path'

_ = require 'lodash'
Promise = require 'bluebird'

Service = require './service'

# Sort services
serviceNames = [
  'incoming', 'outgoing', 'robot', 'teambition', 'rss', 'github', 'firim', 'jobtong', 'pingxx',
  'gitlab', 'coding', 'gitcafe', 'bitbucket', 'jinshuju', 'jiankongbao', 'kf5', 'swathub',
  'csdn', 'oschina', 'buildkite', 'codeship', 'jira', 'qingcloud', 'mikecrm', 'bughd',
  'travis', 'jenkins', 'circleci', 'magnumci', 'newrelic', 'heroku', 'goldxitudaily',
  'weibo'
]

serviceNames = ['incoming']

class ServiceLoader

  loadAll: ->
    unless @$_services
      _serviceInstances = serviceNames.map (serviceName) ->
        service = new Service
        service.register serviceName
        require("./services/#{serviceName}").apply service
        service
      @$_services = Promise.props _.zipObject serviceNames, _serviceInstances
    @$_services

  load: (name) -> @loadAll().then (serviceMap) -> serviceMap[name]

  settings: ->
    unless @$_settings
      @$_settings = @loadAll().then (services) ->
        _.mapValues services, (service) -> service.toJSON()
    @$_settings

module.exports = new ServiceLoader
