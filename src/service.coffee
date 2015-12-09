path = require 'path'
fs = require 'fs'

config = require 'config'
Promise = require 'bluebird'
_ = require 'lodash'
glob = require 'glob'
request = require 'request'
marked = require 'marked'

requestAsync = Promise.promisify request

_getManual = ->

  return @_manual if @_manual?

  self = this
  name = @name
  fileNames = glob.sync "#{__dirname}/../manuals/#{name}*.md"

  _getContent = (fileName) ->
    baseName = path.basename fileName
    lang = baseName[(name.length + 1)..-4]
    content = fs.readFileSync(fileName, encoding: 'UTF-8')
    content = content.replace /\((.*?images.*?)\)/ig, (m, uri) -> '(' + self.static uri + ')'
    [lang, marked(content)]

  if fileNames.length is 0
    @_manual = false
  else if fileNames.length is 1
    @_manual = _getContent(fileNames[0])[1]
  else
    @_manual = _.zipObject fileNames.map _getContent

_getFields = ->
  [].concat @headerFields, @_fields, @footerFields

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

  userAgent: 'Talk Api Service V1'

  register: (@name) ->
    @title = @name
    @_fields = []
    # Open api
    @_apis = {}
    # Handler on events
    @_events = {}
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
  ###*
   * Handle i18n objects
   * @param  {Object} locales
   * @return {Object} locales
  ###
  i18n: (locales) -> locales

  ###*
   * Get url of static resource
   * @param  {String} str - Relative path of local resource
   * @return {String} url - Url of static resource
  ###
  static: (str) -> path.join __dirname, '../static', str

  # Register open apis
  # The route of api will be `POST services/:integration_name/:api_name`
  registerApi: (name, fn) -> @_apis[name] = fn

  ###*
   * Get url of apis from services, group by service name
   * @param  {String} apiName - Api name
   * @return {String} url - The complete api url
  ###
  getApiUrl: (apiName) ->
    service = require './service'
    config.apiHost + "/services/api/#{@name}/#{apiName}"

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

  receiveApi: (name, req, res) ->
    self = this

    Promise.resolve()
    .then ->
      unless toString.call(self._apis[name]) is '[object Function]'
        throw new Error('Api function is not defined')
      self._apis[name].call self, req, res

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
    # @todo Implement this function
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

    return @_httpPost url, payload if retryTimes < 1

    _tryPost = ->
      self._httpPost url, payload
      .catch (err) ->
        tryTimes += 1
        throw err if tryTimes > retryTimes
        Promise.delay interval
        .then ->
          interval *= 3
          _tryPost()

    _tryPost()

  _httpPost = (url, payload) ->
    requestAsync
      method: 'POST'
      url: url
      headers: 'User-Agent': @userAgent
      json: true
      timeout: 5000
      body: payload
    .spread (res, body) ->
      unless res.statusCode >= 200 and res.statusCode < 300
        throw new Error("bad request #{res.statusCode}")
      body
  # ========================== Define build-in functions finish ==========================

module.exports = Service
