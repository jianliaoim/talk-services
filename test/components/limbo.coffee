mongoose = require 'mongoose'
Promise = require 'bluebird'
limbo = require 'limbo'
config = require '../config'
schemas = require './schemas'

db = limbo.use 'talk',
  conn: mongoose.createConnection config.talk
  schemas: schemas

Object.keys(db).forEach (key) ->
  Promise.promisifyAll db[key] unless key.indexOf('_') is 0

module.exports = limbo
