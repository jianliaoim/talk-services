_ = require 'lodash'
express = require 'express'
should = require 'should'

app = express()

app.get '/v1/user/get', (req, res) ->
  req.query.should.have.properties 'accountToken'
  res.status(200).json
    _id: '1'
    unions: [
      refer: 'teambition'
      accessToken: 'some account token'
    ,
      refer: 'trello'
      accessToken: 'trello token'
    ]

module.exports = app
