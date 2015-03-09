_ = require 'lodash'

class Setting

  constructor: (data) ->
    @add data

  add: (data) ->
    defaultData =
      requires:  # Require these properties
        _roomId: 'selector'
      options:  # Optional properties
        title: 'text'
        description: 'text'
        iconUrl: 'text'
    @_data = _.merge defaultData, data
    # Bind each data property to this
    props = {}
    Object.keys(@_data).forEach (key) ->
      props[key] =
        get: ->
          @_data[key]
    Object.defineProperties this, props

  toJSON: -> @_data

module.exports = Setting
