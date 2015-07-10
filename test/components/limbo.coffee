mongoose = require 'mongoose'
Promise = require 'bluebird'
limbo = require 'limbo'
config = require '../config'
schemas = require './schemas'

# Promisify mongoose objects
Promise.promisifyAll mongoose.Model

Object.keys(schemas).forEach (key) ->
  Promise.promisifyAll schemas[key].statics
  Promise.promisifyAll schemas[key].methods

talkOptions = {}
talkOptions = auth: authdb: config.talkAuthDb if config.talkAuthDb

talk = limbo.use 'talk',
  conn: mongoose.createConnection config.talk, talkOptions
  schemas: schemas
  methods:
    $save: ->
      model = this
      new Promise (resolve, reject) ->
        model.save (err, model) ->
          return reject(err) if err
          resolve model

module.exports = limbo
