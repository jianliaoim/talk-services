path = require 'path'
loader = require './loader'

module.exports = util =

  userAgent: 'Talk Api Service V1'

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

Object.defineProperty util, 'config', get: -> loader.config
