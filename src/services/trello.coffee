Promise = require 'bluebird'
request = require 'request'
Err = require 'err1st'
_ = require 'lodash'

requestAsync = Promise.promisify request

util = require '../util'

_webHost = 'https://trello.com'
_apiHost = util.config.trello?.apiHost or 'https://api.trello.com/1'
_apiKey = util.config.trello?.apiKey

_getTrelloToken = (accountToken) ->
  unless accountToken
    return Promise.reject(new Err('PARAMS_MISSING', 'accountToken'))

  $token = util.getAccountUserAsync accountToken

  .then (user) ->
    accessToken = null

    user?.unions?.some (union) ->
      if union?.refer is 'trello' and union.accessToken
        accessToken = union.accessToken
        return true

    unless accessToken
      throw new Err 'NO_PERMISSION', '你没有绑定 Trello 账号'

    accessToken

_getBoards = (req, res) ->
  $token = _getTrelloToken req.get('accountToken')

  $token.then (token) ->
    options =
      method: 'GET'
      headers: "User-Agent": util.getUserAgent()
      url: _apiHost + '/members/me/boards'
      json: true
      timeout: 30000
      qs:
        key: _apiKey
        token: token

    requestAsync(options).then (res) ->
      unless res.statusCode >= 200 and res.statusCode < 300
        throw new Err("BAD_REQUEST", res.statusCode)
      boards = res.body.map? (board) ->
        modelId: board.id
        modelName: board.name

_createWebhook = (integration, token) ->
  unless integration?.config?.modelId
    return Promise.reject(new Err('FIELD_MISSING', 'integration.config.modelId'))

  options =
    method: 'POST'
    headers: "User-Agent": util.getUserAgent()
    url: _apiHost + '/webhooks'
    json: true
    timeout: 30000
    qs:
      key: _apiKey
      token: token
    body:
      idModel: integration.config.modelId
      description: integration.description or '简聊 x Trello'
      callbackURL: integration.webhookUrl

  requestAsync(options).then (res) ->
    unless res.statusCode >= 200 and res.statusCode < 300
      throw new Err("BAD_REQUEST", res.statusCode)
    integration.data = webhookId: res.body.id

_removeWebhook = (integration, token) ->
  unless integration?.data?.webhookId
    return Promise.reject(new Err('FIELD_MISSING', 'integration.data.webhookId'))

  options =
    method: 'DELETE'
    headers: 'User-Agent': util.getUserAgent()
    url: _apiHost + "/webhooks/#{integration.data.webhookId}"
    json: true
    timeout: 30000
    qs:
      key: _apiKey
      token: token

  requestAsync(options).then (res) ->
    unless res.statusCode >= 200 and res.statusCode < 300
      throw new Err("BAD_REQUEST", res.statusCode)
    integration.config = {}
    integration.data = {}

_beforeCreate = (req) ->
  {integration} = req

  $token = _getTrelloToken req.get('accountToken')

  $token.then (token) -> _createWebhook integration, token
  .then -> integration

_beforeUpdate = (req) ->
  {integration} = req
  unless req.get('config')?.modelId and req.get('config')?.modelId isnt integration.config?.modelId
    # Do not update webhook unless update integration's modelId
    return

  $token = _getTrelloToken req.get('accountToken')

  $token.then (token) ->
    _removeWebhook integration, token

  .then ->
    integration.config = req.get('config') if req.get('config')
    _createWebhook integration

  .then -> integration

_beforeRemove = (req) ->
  {integration} = req
  $token = _getTrelloToken req.get('accountToken')

  $token.then (token) -> _removeWebhook integration, token

  .then -> integration

_onWebhook = (req) ->
  return if req.method is 'HEAD'
  throw new Err('PARAMS_MISSING', 'action.type') unless req.body?.action?.type

  action = req.body.action

  message = {}
  attachment = category: 'quote', data: {}

  switch
    when action.type is 'addAttachmentToCard'
      attachment.data.title = "#{action.memberCreator?.fullName} attached #{action.data?.attachment?.name} to #{action.data?.card?.name}"
      attachment.data.redirectUrl = "#{_webHost}/c/#{action.data?.card?.shortLink}"
      attachment.data.imageUrl = action.data?.attachment?.previewUrl2x
    when action.type is 'addChecklistToCard'
      attachment.data.title = "#{action.memberCreator?.fullName} added checklist to #{action.data?.card?.name}"
      attachment.data.text = action.data?.checklist?.name
      attachment.data.redirectUrl = "#{_webHost}/c/#{action.data?.card?.shortLink}"
    when action.type is 'commentCard'
      attachment.data.title = "#{action.memberCreator?.fullName} comment on #{action.data?.card?.name}"
      attachment.data.text = action.data?.text
      attachment.data.redirectUrl = "#{_webHost}/c/#{action.data?.card?.shortLink}"
    when action.type is 'createCard'
      attachment.data.title = "#{action.memberCreator?.fullName} created #{action.data?.card?.name}"
      attachment.data.redirectUrl = "#{_webHost}/c/#{action.data?.card?.shortLink}"
    when action.type is 'createCheckItem'
      attachment.data.title = "#{action.memberCreator?.fullName} added new check item to #{action.data?.card?.name}"
      attachment.data.text = action.data?.checkItem?.name
      attachment.data.redirectUrl = "#{_webHost}/c/#{action.data?.card?.shortLink}"
    when action.type is 'updateBoard' and _.has(action.data?.old, 'closed')
      attachment.data.title = "#{action.memberCreator?.fullName} #{if action.data?.old?.closed then 'reopened' else 'closed'} board #{action.data?.board?.name}"
      attachment.data.redirectUrl = "#{_webHost}/b/#{action.data?.board?.shortLink}"
    when action.type is 'updateBoard' and _.has(action.data?.old, 'name')
      attachment.data.title = "#{action.memberCreator?.fullName} renamed board #{action.data?.board?.name} from #{action.data.old.name}"
      attachment.data.redirectUrl = "#{_webHost}/b/#{action.data?.board?.shortLink}"
    when action.type is 'updateCard' and _.has(action.data?.old, 'closed')
      attachment.data.title = "#{action.memberCreator?.fullName} #{if action.data?.old?.closed then 'reopened' else 'closed'} card #{action.data?.card?.name}"
      attachment.data.redirectUrl = "#{_webHost}/c/#{action.data?.card?.shortLink}"
    when action.type is 'updateCard' and _.has(action.data?.old, 'due')
      attachment.data.title = "#{action.memberCreator?.fullName} set #{action.data?.card?.name} to be due 2016-03-09T04:00:00.000Z"
      attachment.data.redirectUrl = "#{_webHost}/c/#{action.data?.card?.shortLink}"
    when action.type is 'updateCard' and _.has(action.data?.old, 'idList')
      attachment.data.title = "#{action.memberCreator?.fullName} moved #{action.data?.card?.name} from #{action.data?.listBefore?.name} to #{action.data?.listAfter?.name}"
      attachment.data.redirectUrl = "#{_webHost}/c/#{action.data?.card?.shortLink}"
    when action.type is 'updateCard' and _.has(action.data?.old, 'name')
      attachment.data.title = "#{action.memberCreator?.fullName} renamed #{action.data?.card?.name} from #{action.data?.old?.name}"
      attachment.data.redirectUrl = "#{_webHost}/c/#{action.data?.card?.shortLink}"
    when action.type is 'updateCheckItem' and _.has(action.data?.old, 'name')
      attachment.data.title = "#{action.memberCreator?.fullName} renamed #{action.data?.checkItem?.name} from #{action.data?.old?.name}"
      attachment.data.redirectUrl = "#{_webHost}/c/#{action.data?.card?.shortLink}"
    when action.type is 'updateCheckItemStateOnCard'
      attachment.data.title = "#{action.memberCreator?.fullName} #{action.data?.checkItem?.state} #{action.data?.checkItem?.name}"
      attachment.data.redirectUrl = "#{_webHost}/c/#{action.data?.card?.shortLink}"
    when action.type is 'updateChecklist' and _.has(action.data?.old, 'name')
      attachment.data.title = "#{action.memberCreator?.fullName} renamed #{action.data?.checklist?.name} from #{action.data?.old?.name}"
      attachment.data.redirectUrl = "#{_webHost}/b/#{action.data?.board?.shortLink}"
    when action.type is 'updateComment' and _.has(action.data?.old, 'text')
      attachment.data.title = "#{action.memberCreator?.fullName} updated comment on #{action.data?.card?.name}"
      attachment.data.text = action.data?.action?.text
      attachment.data.redirectUrl = "#{_webHost}/c/#{action.data?.card?.shortLink}"

  message.attachments = [attachment]
  return message

module.exports = ->

  @title = 'Trello'

  @summary = util.i18n
    zh: '实时接收来自 Trello 看板中的动态消息'
    en: 'This integration helps you receive real-time tasks, schedules and comments from Trello'

  @description = util.i18n
    zh: '实时接收来自 Trello 看板中的动态消息'
    en: 'This integration helps you receive real-time tasks, schedules and comments from Trello'

  @iconUrl = util.static 'images/icons/trello@2x.png'

  @_fields.push
    key: 'config'
    onLoad: get: @getApiUrl 'getBoards'

  @registerEvent 'service.webhook', _onWebhook

  @registerEvent 'before.integration.create', _beforeCreate

  @registerEvent 'before.integration.update', _beforeUpdate

  @registerEvent 'before.integration.remove', _beforeRemove

  @registerApi 'getBoards', _getBoards

