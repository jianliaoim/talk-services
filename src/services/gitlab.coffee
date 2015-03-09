Service = require '../service'

locales =
  en:
    "about-gitlab": 'GitLab is a software repository manager. You may connect webhooks of GitLab repos.'
  zh:
    "about-gitlab": 'GitLab 是一个用于仓库管理系统的开源项目，添加后可以收到来自 GitLab 的推送。'

class GitLabService extends Service

  setting:
    locales: locales
    title: 'GitLab'
    description: "{{__about-gitlab}}"
    iconUrl: 'https://dn-talk.oss.aliyuncs.com/icons/gitlab@2x.png'
    requires:
      url: 'text'

  robot:
    name: 'GitLab'
    email: 'gitlabbot@talk.ai'
    avatarUrl: 'https://dn-talk.oss.aliyuncs.com/icons/gitlab@2x.png'

  receiveWebhook: (req, res, callback) ->
    payload = req.body

module.exports = new GitLabService
