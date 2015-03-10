Service = require '../service'

locales = {}

class RssService extends Service

  setting:
    locales: locales
    title: 'RSS'
    description: '{{__about-rss}}'
    iconUrl: 'https://dn-talk.oss.aliyuncs.com/icons/rss@2x.png'
    fields:
      url:
        type: 'text'
        check:
          url: 'https://talk.ai/integrations/validate?service=rss&url=$0'

  # Validate the url of rss
  validate: ->

module.exports = new RssService
