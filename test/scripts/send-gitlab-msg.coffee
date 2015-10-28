request = require 'request'
_ = require 'lodash'

options =
  method: 'POST'
  headers: "Content-Type": "application/json"
  json: true
  url: 'http://talk.bi/v2/services/webhook/c417d7990227e7b1835d55e3339474c400ccbbde'

[
  'push'
  # 'issue'
  # 'merge'
  # 'new-branch'
].forEach (payloadName) ->
  payload = require "../services/gitlab_assets/#{payloadName}"
  _options = _.assign {}, options, body: payload
  request _options, (err, res, body) -> console.log body
