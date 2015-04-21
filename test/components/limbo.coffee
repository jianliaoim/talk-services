mongoose = require 'mongoose'
Promise = require 'bluebird'
limbo = require 'limbo'
config = require '../config'
schemas = require './schemas'

Promise.promisifyAll mongoose.Model

_promisifyObj = (obj) ->
  Object.keys(obj).forEach (key) ->
    return if key.match /Async$/
    obj["#{key}Async"] = Promise.promisify obj[key]

_promisifySchema = (schema) ->
  _promisifyObj schema.methods
  _promisifyObj schema.statics

_promisifySchemas = (schemas) ->
  Object.keys(schemas).forEach (key) -> _promisifySchema schemas[key]

_promisifySchemas schemas

db = limbo.use 'talk',
  conn: mongoose.createConnection config.talk
  schemas: schemas

module.exports = limbo
