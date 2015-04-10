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

  getSettings: ->
    settings =
      name: @name
      title: @title
      summary: @summary
      description: @description
      iconUrl: @iconUrl
      fields: @fields

register = (name, fn) ->
  service = new Service name
  fn.apply service
  service

module.exports = register
