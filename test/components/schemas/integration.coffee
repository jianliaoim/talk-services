mongoose = require 'mongoose'
{Schema} = mongoose
crypto = require 'crypto'

IntegrationSchema = new Schema
  creator: type: Schema.Types.ObjectId
  team: type: Schema.Types.ObjectId
  room: type: Schema.Types.ObjectId
  category: type: String # Integration category: weibo/github
  group: type: String
  hashId: type: String, default: -> crypto.createHash('sha1').update("#{Date.now()}").digest('hex')
  robot: type: Schema.Types.ObjectId
  # For authorized integrations
  token: String
  # Options
  title: type: String
  description: type: String
  iconUrl: String
  # Other properties
  refreshToken: String
  showname: type: String
  openId: String
  notifications: type: Object
  url: String
  events: Array
  # Github
  repos: type: Array
  # Teambition project object id
  project:
    _id: String
    name: String
  # Data saved in system
  data: Object
  errorInfo: String
  errorTimes: type: Number, default: 0
  lastErrorInfo: String
  createdAt: type: Date, default: Date.now
  updatedAt: type: Date, default: Date.now

IntegrationSchema.virtual '_creatorId'
  .get -> @creator?._id or @creator
  .set (_id) -> @creator = _id

IntegrationSchema.virtual '_roomId'
  .get -> @room?._id or @room
  .set (_id) -> @room = _id

IntegrationSchema.virtual '_teamId'
  .get -> @team?._id or @team
  .set (_id) -> @team = _id

IntegrationSchema.virtual '_robotId'
  .get -> @robot?._id or @robot
  .set (_id) -> @robot = _id

module.exports = IntegrationSchema
