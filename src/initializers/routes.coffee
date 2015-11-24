Err = require 'err1st'
logger = require 'graceful-logger'

app = require '../server'

apiCallback = (req, res) ->
  {err, result} = res
  if err
    err = new Err(err) unless err instanceof Err
    logger.info req.method, req.url, err.stack if err.code is 100

    res.status(err.status or 400).json
      code: err.code
      message: err.message
      data: err.data or {}
  else
    res.status(200).json(result)

app.get '/services/settings', to: 'service#settings'

app.use (req, res, callback) ->
  res.err = new Err 'NOT_FOUND'
  apiCallback req, res

app.use (err, req, res, callback) ->
  res.err = err
  apiCallback req, res
