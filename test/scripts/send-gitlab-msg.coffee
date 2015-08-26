request = require 'request'
_ = require 'lodash'

options =
  method: 'POST'
  headers: "Content-Type": "application/json"
  json: true
  url: 'http://talk.bi/v2/services/webhook/a08ce4f12b3f07a178a6d732c770b24ba1e39775'

[
  'push'
  # 'issue'
  # 'merge'
  # 'new-branch'
].forEach (payloadName) ->
  payload = require "../services/gitlab_assets/#{payloadName}"
  _options = _.assign {}, options, body: payload
  request _options, (err, res, body) -> console.log body
