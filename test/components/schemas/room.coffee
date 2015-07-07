{Schema} = require 'mongoose'

module.exports = RoomSchema = new Schema
  creator: type: Schema.Types.ObjectId, ref: 'User'
  topic: type: String
  team: type: Schema.Types.ObjectId, ref: 'Team'
  purpose: type: String
  isGeneral: type: Boolean, default: false
  isArchived: type: Boolean, default: false
  isPrivate: type: Boolean, default: false
  color: type: String, default: 'blue'
  email: type: String, lowercase: true
  guestToken: type: String
  isGuestVisible: type: Boolean, default: true
  pinyin: type: String
  pinyins: type: Array
  py: type: String
  pys: type: Array
  memberCount: type: Number, default: 0
  createdAt: type: Date, default: Date.now
  updatedAt: type: Date, default: Date.now
,
  toObject:
    virtuals: true
    getters: true
  toJSON:
    virtuals: true
    getters: true

# ============================== Virtuals ==============================

RoomSchema.virtual '_teamId'
  .get -> @team?._id or @team
  .set (_id) -> @team = _id

RoomSchema.virtual '_creatorId'
  .get -> @creator?._id or @creator
  .set (_id) -> @creator = _id
