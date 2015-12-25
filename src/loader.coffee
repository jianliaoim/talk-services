path = require 'path'

_ = require 'lodash'
Promise = require 'bluebird'

# Sort services
serviceNames = [
  'incoming', 'outgoing', 'robot', 'teambition', 'rss', 'cloudinsight', 'github', 'firim', 'jobtong', 'pingxx',
  'gitlab', 'coding', 'gitcafe', 'bitbucket', 'jinshuju', 'jiankongbao', 'kf5', 'swathub',
  'csdn', 'oschina', 'buildkite', 'codeship', 'jira', 'qingcloud', 'mikecrm', 'bughd',
  'travis', 'jenkins', 'circleci', 'magnumci', 'newrelic', 'heroku', 'goldxitudaily',
  'weibo'
]

class ServiceLoader

  config: {}

  $_services: {}

  $_settings: []

  ###*
   * Load a service
   * @param  {String} name - Service name
   * @param  {Function} regFn - Register function, if this function is not exists, auto load the service from module
   * @return {Promise} Service instance
  ###
  load: (name, regFn) ->
    unless @$_services[name]

      Service = require './service'

      @$_services[name] = Promise.resolve(new Service(name)).then (service) ->

        Promise.resolve(service.register())
        .then ->
          regFn or= require("./services/#{name}")
          regFn.call service, service
        .then -> service

      @$_settings.push @$_services[name].then (service) -> service.toJSON()

    @$_services[name]

  ###*
   * Service settings
   * @return {Promsie} Settings array of services
  ###
  settings: -> Promise.all @$_settings

loader = new ServiceLoader

module.exports = loader
