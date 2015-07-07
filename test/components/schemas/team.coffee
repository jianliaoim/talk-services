{Schema} = require 'mongoose'

module.exports = TeamSchema = new Schema
  creator: type: Schema.Types.ObjectId, ref: 'User'
  name: type: String
  source: String
  sourceId: String
  sourceName: type: String
  color: type: String, default: 'ocean'
  inviteCode: type: String
  nonJoinable: type: Boolean
  createdAt: type: Date
  updatedAt: type: Date
,
  toObject:
    virtuals: true
    getters: true
  toJSON:
    virtuals: true
    getters: true

TeamSchema.virtual '_creatorId'
  .get -> @creator?._id or @creator
  .set (_id) -> @creator = _id

TeamSchema.virtual 'hasVisited'
  .get -> @_hasVisited
  .set (@_hasVisited) -> @_hasVisited

TeamSchema.virtual 'rooms'
  .get -> @_rooms
  .set (@_rooms) -> @_rooms

TeamSchema.virtual 'members'
  .get -> @_members
  .set (@_members) -> @_members

TeamSchema.virtual 'unread'
  .get -> @_unread
  .set (@_unread) -> @_unread

TeamSchema.virtual 'hasUnread'
  .get ->
    return @_hasUnread if @_hasUnread?
    if @_unread then true else false
  .set (@_hasUnread) -> @_hasUnread

TeamSchema.virtual 'latestMessages'
  .get -> @_latestMessages
  .set (@_latestMessages) -> @_latestMessages

TeamSchema.virtual 'prefs'
  .get -> @_prefs
  .set (@_prefs) -> @_prefs

TeamSchema.virtual 'signCode'
  .get -> @_signCode
  .set (@_signCode) -> @_signCode

TeamSchema.virtual 'signCodeExpireAt'
  .get -> @_signCodeExpireAt
  .set (@_signCodeExpireAt) -> @_signCodeExpireAt

TeamSchema.statics.addMember = (_teamId, _userId, callback) ->
  @findOne _id: _teamId, callback

TeamSchema.statics.removeMember = (_teamId, _userId, callback) ->
  @findOne _id: _teamId, callback
