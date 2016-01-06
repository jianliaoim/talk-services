should = require 'should'
service = require '../../src/service'
{prepare, cleanup, req} = require '../util'
qingcloud = service.load 'qingcloud'

describe 'QingCloud#Webhook', ->

  before prepare

  it 'receive webhook', (done) ->
    qingcloud.sendMessage = (message) ->
      message.attachments[0].data.title.should.eql 'QingCloud: i-o28sbzxr 第二台 instance'
      message.attachments[0].data.text.should.eql '''
      RULE_ID: alpr-j8yxbt63 STATUS: alarm
      RULE_ID: alpr-xah9dmrp STATUS: alarm
      RULE_ID: alpr-805s7jlf STATUS: ok
      '''

      done()

    req.body = {
      "rules": "{
        'alpr-j8yxbt63': {
          'status': 'alarm',
          'data_processor': 'raw',
          'recent_monitor_data': [[1452082560, 0.3], [1452082570, 0.6], [1452082580, 0.4], [1452082590, 0.6]],
          'thresholds': '90',
          'meter': 'cpu',
          'alarm_policy_id': 'alp-nrxvvw5r',
          'disabled': 0,
          'consecutive_periods': 1,
          'alarm_policy_rule_name': '',
          'create_time': '2016-01-06T20:15:24',
          'alarm_policy_rule_id': 'alpr-j8yxbt63',
          'owner': 'usr-9NxdLZZp',
          'condition_type': 'lt'
        },
        'alpr-xah9dmrp': {
          'status': 'alarm',
          'data_processor': 'raw',
          'recent_monitor_data': {'/': [[1452082611, 10]]},
          'thresholds': '90',
          'meter': 'disk-us',
          'alarm_policy_id': 'alp-nrxvvw5r',
          'disabled': 0,
          'consecutive_periods': 1,
          'alarm_policy_rule_name': '',
          'create_time': '2016-01-06T20:15:24',
          'alarm_policy_rule_id': 'alpr-xah9dmrp',
          'owner': 'usr-9NxdLZZp',
          'condition_type': 'lt'
        },
        'alpr-805s7jlf': {
          'status': 'ok',
          'data_processor': 'raw',
          'recent_monitor_data': [[1452082560, 4.7], [1452082570, 4.8], [1452082580, 4.7], [1452082590, 4.7], [1452082600, 4.7]],
          'thresholds': '90',
          'meter': 'memory',
          'alarm_policy_id': 'alp-nrxvvw5r',
          'disabled': 0,
          'consecutive_periods': 1,
          'alarm_policy_rule_name': '',
          'create_time': '2016-01-06T20:15:24',
          'alarm_policy_rule_id': 'alpr-805s7jlf',
          'owner': 'usr-9NxdLZZp',
          'condition_type': 'gt'
        }
      }",
      "resource": "{
        'resource_name': u'\\u7b2c\\u4e8c\\u53f0',
        'resource_type': 'instance',
        'resource_id': 'i-o28sbzxr'
      }",
      "alarm_policy": "第二台",
      "zone": "gd1",
      "trigger_status": "alarm"
    }

    req.integration = _id: 1

    qingcloud.receiveEvent 'service.webhook', req
    .catch done

  after cleanup
