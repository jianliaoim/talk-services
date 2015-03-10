_ = require 'lodash'

class Setting

  constructor: (data) ->
    @add data

  add: (data) ->
    defaultData =
      fields:
        _roomId: 'selector'
        title:
          type: 'text'
          optional: true
        description:
          type: 'text'
          optional: true
        iconUrl:
          type: 'text'
          optional: true
    @_data = _.merge defaultData, data

  toJSON: -> @_data

module.exports = Setting
