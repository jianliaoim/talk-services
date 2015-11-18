_ = require 'lodash'
app = require './app'

projects =
  "5632dc1a065565ad690266a0":
    _id: "5632dc1a065565ad690266a0",
    name: "Discover Teambition",
    _creatorId: "55c060be2944cfe95e75a088",
    logo: "http://project.ci/api/images/covers/cover-other.jpg",
    py: "discoverteambition",
    pinyin: "discoverteambition"
  "5632dc1a065565ad690266a1":
    _id: "5632dc1a065565ad690266a1",
    name: "Discover Teambition 2",
    _creatorId: "55c060be2944cfe95e75a088",
    logo: "http://project.ci/api/images/covers/cover-other.jpg",
    py: "discoverteambition",
    pinyin: "discoverteambition"

hooks =
  "5632dc1a065565ad690266a0":
    _id: "5632dc1a065565ad690266a2"
  "5632dc1a065565ad690266a1":
    _id: "5632dc1a065565ad690266a3"

app.get '/tb/api/projects', (req, res) ->
  req.headers.authorization.should.containEql "OAuth2 some account token"
  res.status(200).json _.values(projects)

app.post '/tb/api/projects/:_id/hooks', (req, res) ->
  req.headers.authorization.should.containEql "OAuth2 some account token"
  res.status(200).json hooks[req.params._id]

app.put '/tb/api/projects/:_id/hooks/:_hookId', (req, res) ->
  req.headers.authorization.should.containEql "OAuth2 some account token"
  req.params._hookId.should.eql hooks[req.params._id]._id
  res.status(200).json hooks[req.params._id]

app.delete '/tb/api/projects/:_id/hooks/:_hookId', (req, res) ->
  req.headers.authorization.should.containEql "OAuth2 some account token"
  req.params._hookId.should.eql hooks[req.params._id]._id
  res.status(200).json {}
