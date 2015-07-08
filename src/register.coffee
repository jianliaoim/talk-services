path = require 'path'
Promise = require 'bluebird'
fs = require 'fs'
_ = require 'lodash'
glob = require 'glob'
request = require 'request'
marked = require 'marked'
requestAsync = Promise.promisify request

_getManual = ->

  return @_manual if @_manual?

  name = @name
  fileNames = glob.sync "#{__dirname}/../manuals/#{name}*.md"

  _getContent = (fileName) ->
    service = require './service'
    baseName = path.basename fileName
    lang = baseName[(name.length + 1)..-4]
    content = fs.readFileSync(fileName, encoding: 'UTF-8')
    content = content.replace /\((.*?images.*?)\)/ig, (m, uri) -> '(' + service.static uri + ')'
    [lang, marked(content)]

  if fileNames.length is 0
    @_manual = false
  else if fileNames.length is 1
    @_manual = _getContent(fileNames[0])[1]
  else
    @_manual = _.zipObject fileNames.map _getContent

_initRobot = ->
  self = this
  service = require './service'
  {limbo} = service.components
  {UserModel} = limbo.use 'talk'

  # Set default properties of robot
  @robot.name or= @title or @name
  @robot.email or= "#{@name}bot@talk.ai"
  @robot.avatarUrl or= @iconUrl
  @robot.isRobot = true

  conditions =
    email: @robot.email
    isRobot: true

  $robot = UserModel.findOneAsync conditions

  .then (_robot) ->
    return _robot if _robot
    robot = new UserModel self.robot
    update = robot.toJSON()
    delete update._id
    delete update.id
    UserModel.findOneAndUpdateAsync conditions
    ,
      update
    ,
      upsert: true
      new: true

  .then (robot) ->
    throw new Error("Service #{self.name} load robot failed") unless robot
    self.robot = robot

_getFields = ->
  [].concat @headerFields, @_fields, @footerFields

_httpPost = (url, payload) ->
  service = require './service'
  requestAsync
    method: 'POST'
    url: url
    headers: 'User-Agent': service.userAgent
    json: true
    timeout: 5000
    body: payload
  .spread (res, body) ->
    unless res.statusCode >= 200 and res.statusCode < 300
      throw new Error("bad request #{res.statusCode}")
    body

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

  # Whether if the service displayed in web/android/ios
  isHidden: false

  isCustomized: false

  constructor: (@name) ->
    @title = @name
    @_fields = []
    # Open api
    @_apis = {}
    # Handler on events
    @_events = {}
    @robot = {}
    @headerFields = [
      key: '_roomId'
      type: 'selector'
    ]
    @footerFields = [
      key: 'title'
      type: 'text'
    ,
      key: 'description'
      type: 'text'
    ,
      key: 'iconUrl'
      type: 'file'
    ]
    Object.defineProperty this, 'fields', get: _getFields, set: (@_fields) -> @_fields
    Object.defineProperty this, 'manual', get: _getManual

  initialize: ->
    unless @_initialized
      self = this
      $robot = _initRobot.apply this
      @_initialized = Promise.all [$robot]
      .then -> self
    @_initialized

  needCustomName: (need) ->

  needCustomDescription: (need) ->

  needCustomIcon: (need) ->

  # Register open apis
  # The route of api will be `POST services/:integration_name/:api_name`
  registerApi: (name, fn) ->
    @_apis[name] = fn

  getApiUrl: (apiName) ->
    service = require './service'
    service.apiHost + "/services/api/#{@name}/#{apiName}"

  receiveApi: (name, req, res) ->
    self = this
    Promise.resolve()
    .then ->
      unless toString.call(self._apis[name]) is '[object Function]'
        throw new Error('Api function is not defined')
      self._apis[name].call self, req, res

  registerEvents: (events) ->
    self = this
    if toString.call(events) is '[object Array]'
      events.forEach (event) ->
        self.registerEvent event
    else if toString.call(events) is '[object Object]'
      Object.keys(events).forEach (event) ->
        handler = events[event]
        self.registerEvent event, handler
    else throw new Error('Events are invalid')

  registerEvent: (event, handler) ->
    self = this
    unless toString.call(handler) is '[object Function]'
      throw new Error('Service url is not defined') unless @serviceUrl
      serviceUrl = @serviceUrl
      handler = (payload) ->
        self.httpPost serviceUrl
        ,
          event: event
          data: payload

    if handler.length is 2
      handler = Promise.promisify(handler)

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
    isCustomized: @isCustomized

  toObject: @::toJSON

  # ========================== Define build-in functions ==========================
  ###*
   * Send message to talk users
   * @param  {Object}   message
   * @return {Promise}  MessageModel
  ###
  sendMessage: (message) ->
    service = require './service'
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
   * @param  {String}   URL
   * @param  {Object}   Payload
   * @param  {Object}   Options
   * @return {Promise}  Response body
  ###
  httpPost: (url, payload, options = {}) ->
    tryTimes = 0
    retryTimes = options.retryTimes or 0
    interval = options.interval or 1000
    self = this

    return _httpPost url, payload if retryTimes < 1

    _tryPost = ->
      _httpPost url, payload
      .catch (err) ->
        tryTimes += 1
        throw err if tryTimes > retryTimes
        Promise.delay interval
        .then ->
          interval *= 3
          _tryPost()

    _tryPost()

  createRobot: (user) ->
    service = require './service'
    {limbo} = service.components
    {UserModel} = limbo.use 'talk'
    robot = new UserModel user
    robot.isRobot = true
    new Promise (resolve, reject) ->
      robot.save (err, robot) ->
        return reject(err) if err
        resolve robot
  # ========================== Define build-in functions finish ==========================

register = (name, fn) ->
  _service = new Service name
  fn.apply _service
  _service

module.exports = register
