Promise = require 'bluebird'
Err = require 'err1st'

class ServiceLoader

  config: {}

  $_services: {}

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

        Promise.resolve(service.register()).then ->
          try
            initializer = require "./services/#{name}"
          catch err
            unless toString.call(regFn) is '[object Function]'
              throw new Err("INVALID_SERVICE", name)
            return
          initializer.call service, service
        .then -> service

    if toString.call(regFn) is '[object Function]'
      @$_services[name] = @$_services[name].then (service) ->
        Promise.resolve(regFn.call service, service)
        .then -> service

    @$_services[name]

loader = new ServiceLoader

module.exports = loader
