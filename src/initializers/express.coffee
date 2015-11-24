express = require 'express'
morgan = require 'morgan'
bodyParser = require 'body-parser'

app = require '../server'

app.use morgan("[:date] :method :url :status :res[content-length] :response-time ms")
app.use bodyParser.json()
app.use bodyParser.urlencoded(extended: true)
