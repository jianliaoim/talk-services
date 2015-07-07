{Schema} = require 'mongoose'

module.exports = MemberSchema = new Schema
  user: type: Schema.Types.ObjectId, ref: 'User'
  room: type: Schema.Types.ObjectId, ref: 'Room'
  team: type: Schema.Types.ObjectId, ref: 'Team'
  isQuit: type: Boolean, default: false
  createdAt: type: Date, default: Date.now
  updatedAt: type: Date, default: Date.now
,
  toObject:
    virtuals: true
    getters: true
  toJSON:
    virtuals: true
    getters: true

MemberSchema.virtual('_userId')
  .get -> @user?._id or @user
  .set (_id) -> @user = _id

MemberSchema.virtual('_roomId')
  .get -> @room?._id or @room
  .set (_id) -> @room = _id

MemberSchema.virtual('_teamId')
  .get -> @team?._id or @team
  .set (_id) -> @team = _id
