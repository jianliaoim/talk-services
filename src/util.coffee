path = require 'path'
Promise = require 'bluebird'
request = require 'request'
Err = require 'err1st'
_ = require 'lodash'
loader = require './loader'

lockMap = {}

module.exports = util =

  userAgent: 'Talk Api Service V1'

  ###*
   * Get random user agent
   * @return {String}
  ###
  getUserAgent: ->
    userAgents = [
      'Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2228.0 Safari/537.36'
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.1 Safari/537.36'
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.0 Safari/537.36'
      'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2227.0 Safari/537.36'
      'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2226.0 Safari/537.36'
      'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:40.0) Gecko/20100101 Firefox/40.1'
      'Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0'
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10; rv:33.0) Gecko/20100101 Firefox/33.0'
      'Mozilla/5.0 (X11; Linux i586; rv:31.0) Gecko/20100101 Firefox/31.0'
      'Mozilla/5.0 (Windows NT 6.1; WOW64; rv:31.0) Gecko/20130401 Firefox/31.0'
      'Mozilla/5.0 (Windows NT 5.1; rv:31.0) Gecko/20100101 Firefox/31.0'
    ]
    _.sample userAgents

  ###*
   * Handle i18n objects
   * @param  {Object} locales
   * @return {Object} locales
  ###
  i18n: (locales) -> locales

  ###*
   * Get url of static resource
   * @param  {String} str - Relative path of local resource
   * @return {String} url - Url of static resource
  ###
  static: (str) -> loader.config.cdnPrefix + path.join('/', str)

  ###*
   * Get url of apis from services, group by service name
   * @param  {String} category - Service category
   * @param  {String} apiName - Api name
   * @return {String} url - The complete api url
  ###
  getApiUrl: (category, apiName) ->
    loader.config.apiHost + "/services/api/#{category}/#{apiName}"

  getAccountUser: (accountToken, callback) ->
    options =
      url: loader.config.talkAccountApiUrl + '/v1/user/get'
      json: true
      qs: accountToken: accountToken
    request options, (err, res, user) ->
      return callback(new Err('TOKEN_EXPIRED')) unless user?._id
      callback err, user

  lock: (key, timeout = 10000) ->
    lockMap[key] = 1
    setTimeout ->
      delete lockMap[key]
    , timeout

  isLocked: (key) -> lockMap[key]

Object.defineProperty util, 'config', get: -> loader.config

Promise.promisifyAll util
