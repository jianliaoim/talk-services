path = require 'path'
fs = require 'fs'
_ = require 'lodash'
glob = require 'glob'
request = require 'request'

_getManual = ->
  return @_manual if @_manual?

  name = @name
  fileNames = glob.sync "#{__dirname}/../manuals/#{name}*.md"

  _getContent = (fileName) ->
    baseName = path.basename fileName
    lang = baseName[(name.length + 1)..-4]
    [lang, fs.readFileSync(fileName, encoding: 'UTF-8')]

  if fileNames.length is 0
    @_manual = false
  else if fileNames.length is 1
    @_manual = _getContent(fileNames[0])[1]
  else
    @_manual = _.zipObject fileNames.map _getContent

class Service

  # Shown as title
  title: ''

  # Shown in the integration list
  summary: ''

  # Shown in the integration configuation page
  description: ''

  # Shown as integration icon and default avatarUrl of message creator
  iconUrl: ''

  # Template of settings page
  template: ''

  constructor: (@name) ->
    @title = @name
    @fields = _roomId: type: 'selector'
    # Open api
    @_apis = {}
    # Handler on events
    @_events = {}
    Object.defineProperty this, 'manual', get: _getManual

  # The the input field and handler
  setField: (field, options = {}) ->

  needCustomName: (need) ->

  needCustomDescription: (need) ->

  needCustomIcon: (need) ->

  # Register open apis
  # The route of api will be `POST services/:integration_name/:api_name`
  registerApi: (name, fn) ->

  registerEvents: (events) ->
    self = this
    if toString.call(events) is '[object Array]'
      events.forEach (event) ->
        self.registerEvent event
    else if toString.call(events) is '[object Object]'
      Object.keys(events).forEach (event) ->
        handler = events[event]
        self.registerEvent event, handler
    else throw new Error('Events type is invalid')

  registerEvent: (event, handler) ->
    unless toString.call(handler) is '[object Function]'
      throw new Error('Service url is not defined') unless @serviceUrl
      serviceUrl = @serviceUrl
      handler = (req, res, callback) ->
        request
          method: 'POST'
          url: serviceUrl
          headers: 'User-Agent': 'Talk Api Service V1'
          json: true
          timeout: 5000
          body:
            event: event
            data: res.data
        , (err, res, body) ->
          unless res.statusCode >= 200 and res.statusCode < 300
            err or= new Error("bad request #{res.statusCode}")
          callback err, body

    @_events[event] = handler

  receiveEvent: (event, req, res, callback) ->
    {integraion} = req.get()
    return callback(null) unless toString.call(@_events[event]) is '[object Function]'
    @_events[event].call req, res, callback

  sendMessage: (message, callback) ->
    robot = @robot
    {limbo} = service.components

    {MessageModel} = limbo.use 'talk'
    message = new MessageModel message
    message._creatorId = robot._id
    message._integrationId = integration._id
    message.save (err, message) -> callback err, message

  initRobot: ->
    robot =
      name: @name
      email: "#{name}@talk.ai"
      avatarUrl: @_iconUrl

  toJSON: ->
    name: @name
    template: @template
    title: @title
    summary: @summary
    description: @description
    iconUrl: @iconUrl
    fields: @fields
    manual: @manual

register = (name, fn) ->
  service = new Service name
  fn.apply service
  service

module.exports = register
