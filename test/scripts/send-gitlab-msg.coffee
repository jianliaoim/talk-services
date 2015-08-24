request = require 'request'
_ = require 'lodash'

options =
  method: 'POST'
  headers: "Content-Type": "application/json"
  json: true
  url: 'http://talk.ci/v2/services/webhook/84d783307b261074b3e9d370ab83162ed2d3c27d'

[
  'push'
  # 'issue'
  # 'merge'
  # 'new-branch'
].forEach (payloadName) ->
  payload = require "../services/gitlab_assets/#{payloadName}"
  _options = _.assign {}, options, body: payload
  request _options, (err, res, body) -> console.log body
