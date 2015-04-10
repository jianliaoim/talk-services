path = require 'path'
fs = require 'fs'
_ = require 'lodash'
glob = require 'glob'

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

  constructor: (@name) ->
    @title = @name
    @fields = _roomId: type: 'selector'
    @_apis = {}
    @_callbacks = {}
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

  registerEvent: (event, handler) ->

  getRobot: -> @_robot

  initRobot: ->
    robot =
      name: @name
      email: "#{name}@talk.ai"
      avatarUrl: @_iconUrl

  toJSON: ->
    name: @name
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
