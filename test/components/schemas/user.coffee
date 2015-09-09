{Schema} = require 'mongoose'

module.exports = UserSchema = new Schema
  name: type: String
  avatarUrl: type: String
  service: type: String
  email: type: String
  description: type: String
  createdAt: type: Date, default: Date.now
  updatedAt: type: Date, default: Date.now
  isRobot: type: Boolean, default: false
