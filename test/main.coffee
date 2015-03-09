require './services/gitlab'

service = require '../src/index'

console.log JSON.stringify(service.getAllSettings(), null, 2)
