Err = require 'err1st'

meta =
  DEFAULT_ERROR: 500100
  CREATE_ERROR: 500101
  UPDATE_ERROR: 500102
  DELETE_ERROR: 500103

  NOT_FOUND: [404404, 'Not found']

Err.meta meta
Err.localeMeta 'zh', require '../../locales/zh'
Err.localeMeta 'en', require '../../locales/en'
