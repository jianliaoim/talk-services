request = require 'request'
_ = require 'lodash'

options =
  method: 'POST'
  headers: "Content-Type": "application/json"
  json: true
  url: 'http://talk.ci/v1/services/webhook/64e5a78563c4295e765daa771981df6e0d7e064c'

[
  'push'
  'issue'
  'merge'
  'new-branch'
].forEach (payloadName) ->
  payload = require "../services/gitlab_assets/#{payloadName}"
  _options = _.assign {}, options, body: payload
  request _options, (err, res, body) -> console.log body
