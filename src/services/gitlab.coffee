service = require '../service'

module.exports = service.register 'gitlab', ->
  @title = 'GitLab'

  @summary = service.i18n
    zh: '用于仓库管理系统的开源项目。'
    en: 'GitLab is a web-based Git repository manager with wiki and issue tracking features.'

  @description = service.i18n
    zh: 'GitLab 是一个用于仓库管理系统的开源项目，添加后可以收到来自 GitLab 的推送。'
    en: 'GitLab is a software repository manager. You may connect webhooks of GitLab repos.'

  @iconUrl = service.static('images/gitlab@2x.png')

  @setField 'url', type: 'text', readOnly: true, autoGen: true

  @registerEvent 'webhook', (req, res, callback) ->
