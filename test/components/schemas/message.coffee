{Schema} = require 'mongoose'

module.exports = MessageSchema = new Schema
  creator: type: Schema.Types.ObjectId
  team: type: Schema.Types.ObjectId
  room: type: Schema.Types.ObjectId
  to: type: Schema.Types.ObjectId
  body: type: String
  attachments: type: Array
  integration: type: Schema.Types.ObjectId
  createdAt: type: Date, default: Date.now
  updatedAt: type: Date, default: Date.now

MessageSchema.virtual '_creatorId'
  .get -> @creator?._id or @creator
  .set (_id) -> @creator = _id

MessageSchema.virtual '_roomId'
  .get -> @room?._id or @room
  .set (_id) -> @room = _id

MessageSchema.virtual '_toId'
  .get -> @to?._id or @to
  .set (_id) -> @to = _id

MessageSchema.virtual '_teamId'
  .get -> @team?._id or @team
  .set (_id) -> @team = _id

MessageSchema.virtual '_integrationId'
  .get -> @integration?._id or @integration
  .set (_id) -> @integration = _id
