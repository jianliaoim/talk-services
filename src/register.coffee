path = require 'path'
Promise = require 'bluebird'
fs = require 'fs'
_ = require 'lodash'
glob = require 'glob'
request = require 'request'
requestAsync = Promise.promisify request

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
    @robot =
      name: @name
      email: "#{@name}bot@talk.ai"
      avatarUrl: @iconUrl
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
    self = this
    unless toString.call(handler) is '[object Function]'
      throw new Error('Service url is not defined') unless @serviceUrl
      serviceUrl = @serviceUrl
      handler = (req, res) ->
        self.httpPost serviceUrl
        ,
          event: event
          data: res.data

    if handler.length is 3
      handler = Promise.promisify(handler).bind this

    @_events[event] = handler

  receiveEvent: (event, req, res) ->
    unless toString.call(@_events[event]) is '[object Function]'
      return Promise.resolve()

    self = this
    Promise.resolve()
    .then -> self._events[event].call self, req, res

  toJSON: ->
    name: @name
    template: @template
    title: @title
    summary: @summary
    description: @description
    iconUrl: @iconUrl
    fields: @fields
    manual: @manual

  # ========================== Define build-in functions ==========================
  ###*
   * Send message to talk users
   * @param  {Object}   message
   * @return {Promise}  MessageModel
  ###
  sendMessage: (message) ->
    robot = @robot
    {limbo} = service.components
    {MessageModel} = limbo.use 'talk'

    new Promise (resolve, reject) ->
      message = new MessageModel message
      message._creatorId or= robot._id
      message.save (err, message) ->
        return reject(err) if err
        resolve message

  ###*
   * Post data to the thrid part services
   * @param  {url}      url
   * @param  {Object}   payload
   * @return {Promise}  Response body
  ###
  httpPost: (url, payload) ->
    requestAsync
      method: 'POST'
      url: url
      headers: 'User-Agent': 'Talk Api Service V1'
      json: true
      timeout: 5000
      body: payload
    .spread (res, body) ->
      unless res.statusCode >= 200 and res.statusCode < 300
        throw new Error("bad request #{res.statusCode}")
      body
  # ========================== Define build-in functions finish ==========================

register = (name, fn) ->
  service = new Service name
  fn.apply service
  service

module.exports = register
