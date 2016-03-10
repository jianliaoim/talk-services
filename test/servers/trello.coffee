express = require 'express'
_ = require 'lodash'
should = require 'should'

boards = [
  {
    "name": "ToDoNow",
    "desc": "",
    "descData": null,
    "closed": false,
    "idOrganization": null,
    "pinned": null,
    "invitations": null,
    "shortLink": "GkR7AsMR",
    "powerUps": [
      "calendar"
    ],
    "dateLastActivity": "2016-03-08T09:32:52.044Z",
    "idTags": [],
    "id": "4f83f6fab28be1c82841b3c0",
    "invited": false,
    "starred": false,
    "url": "https://trello.com/b/GkR7AsMR/todonow",
    "prefs": {
      "permissionLevel": "private",
      "voting": "disabled",
      "comments": "members",
      "invitations": "members",
      "selfJoin": false,
      "cardCovers": true,
      "calendarFeedEnabled": false,
      "background": "green",
      "backgroundImage": null,
      "backgroundImageScaled": null,
      "backgroundTile": false,
      "backgroundBrightness": "dark",
      "backgroundColor": "#519839",
      "canBePublic": true,
      "canBeOrg": true,
      "canBePrivate": true,
      "canInvite": true
    },
    "memberships": [
      {
        "id": "4f83f6fab28be1c82841b3c8",
        "idMember": "4f0a922ff25c53695a0cb1c2",
        "memberType": "admin",
        "unconfirmed": false,
        "deactivated": false
      }
    ],
    "subscribed": false,
    "labelNames": {
      "green": "",
      "yellow": "",
      "orange": "",
      "red": "",
      "purple": "",
      "blue": "",
      "sky": "",
      "lime": "",
      "pink": "",
      "black": ""
    },
    "dateLastView": "2016-03-08T09:37:53.442Z",
    "shortUrl": "https://trello.com/b/GkR7AsMR"
  },
  {
    "name": "Welcome Board",
    "desc": "",
    "descData": null,
    "closed": true,
    "idOrganization": null,
    "pinned": null,
    "invitations": null,
    "shortLink": "OWsaWkrk",
    "powerUps": [
      "voting"
    ],
    "dateLastActivity": null,
    "idTags": [],
    "id": "4f0a922ff25c53695a0cb1d7",
    "invited": false,
    "starred": false,
    "url": "https://trello.com/b/OWsaWkrk/welcome-board",
    "prefs": {
      "permissionLevel": "private",
      "voting": "members",
      "comments": "members",
      "invitations": "members",
      "selfJoin": true,
      "cardCovers": true,
      "calendarFeedEnabled": false,
      "background": "blue",
      "backgroundImage": null,
      "backgroundImageScaled": null,
      "backgroundTile": false,
      "backgroundBrightness": "dark",
      "backgroundColor": "#0079BF",
      "canBePublic": true,
      "canBeOrg": true,
      "canBePrivate": true,
      "canInvite": true
    },
    "memberships": [
      {
        "id": "4f0a922ff25c53695a0cb1d6",
        "idMember": "4e6a7fad05d98b02ba00845c",
        "memberType": "normal",
        "unconfirmed": false,
        "deactivated": false
      },
      {
        "id": "4f0a922ff25c53695a0cb1e1",
        "idMember": "4f0a922ff25c53695a0cb1c2",
        "memberType": "admin",
        "unconfirmed": false,
        "deactivated": false
      }
    ],
    "subscribed": false,
    "labelNames": {
      "green": "",
      "yellow": "",
      "orange": "",
      "red": "",
      "purple": "",
      "blue": "",
      "sky": "",
      "lime": "",
      "pink": "",
      "black": ""
    },
    "dateLastView": "2012-04-10T09:03:00.057Z",
    "shortUrl": "https://trello.com/b/OWsaWkrk"
  }
]

webhooks =
  '4f0a922ff25c53695a0cb1d7':
    "id": "56dfc3818d119dd1563685dc",
    "description": "New webhook",
    "idModel": "4f0a922ff25c53695a0cb1d7",
    "callbackURL": "https://jianliao.com/webhook",
    "active": true
  '4f83f6fab28be1c82841b3c0':
    "id": "56dfc3818d119dd1563685dd",
    "description": "New new webhook",
    "idModel": "4f83f6fab28be1c82841b3c0",
    "callbackURL": "https://jianliao.com/webhook",
    "active": true

app = express()

app.get '/members/me/boards', (req, res) -> res.send boards

app.post '/webhooks', (req, res) ->
  should(req.body.idModel).not.empty
  should(webhooks[req.body.idModel]).not.empty
  res.send webhooks[req.body.idModel]

app.delete '/webhooks/:id', (req, res) ->
  should(webhooks[req.params.id]).not.empty
  res.send {}

module.exports = app
