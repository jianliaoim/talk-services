redis = require 'redis'
Promise = require 'bluebird'
redisConf = require('../config').redis

client = redis.createClient redisConf.port, redisConf.host

client.select redisConf.db

Promise.promisifyAll client

module.exports = client
