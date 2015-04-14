{Schema} = require 'mongoose'

module.exports = MessageSchema = new Schema
  creator: type: Schema.Types.ObjectId
  team: type: Schema.Types.ObjectId
  room: type: Schema.Types.ObjectId
  to: type: Schema.Types.ObjectId
  content: type: Schema.Types.Mixed
  text: type: String
  file: type: Schema.Types.ObjectId
  quote:  # Message quoted from service
    openId: String  # [optional] open id
    category: String  # [required] Category of integration
    authorName: String  # Replacement of bot name
    authorAvatarUrl: type: String
    userAvatarUrl: type: String  # User avatar from the integration website
    userName: String  # User name from the integration website
    title: String  # Title of quote text, it will be used in search in the first place
    text: type: String  # Quote text, plain text or html
    thumbnailPicUrl: type: String  # Attachment thumbnail picture
    originalPicUrl: type: String  # Attachment original picture
    redirectUrl: type: String  # The original url
  attachments: Array
  isStarred: type: Boolean, default: false
  starredBy: type: Schema.Types.ObjectId
  starredAt: Date
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

MessageSchema.virtual '_fileId'
  .get -> @file?._id or @file
  .set (_id) -> @file = _id

MessageSchema.virtual '_starredById'
  .get -> @starredBy?._id or @starredBy
  .set (_id) -> @starredBy = _id

MessageSchema.virtual '_integrationId'
  .get -> @integration?._id or @integration
  .set (_id) -> @integration = _id

module.exports = MessageSchema
