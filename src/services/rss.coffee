Service = require '../service'

locales = {}

class RssService extends Service

  setting:
    locales: locales
    title: 'RSS'
    description: '{{__about-rss}}'
    iconUrl: 'https://dn-talk.oss.aliyuncs.com/icons/rss@2x.png'
    requires:
      url: 'text'
    options:
      iconUrl: 'text'

module.exports = new RssService
