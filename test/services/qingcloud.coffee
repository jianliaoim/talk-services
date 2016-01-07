should = require 'should'
loader = require '../../src/loader'
{req} = require '../util'
$qingcloud = loader.load 'qingcloud'

describe 'QingCloud#Webhook', ->

  it 'receive webhook', (done) ->

    req.body = {
      "rules": "{
        'alpr-vp9d2olk': {
          'status': 'alarm',
          'data_processor': 'raw',
          'recent_monitor_data': {
            '/': [[1452147870, 10]]
          },
          'thresholds': '90',
          'meter': 'disk-us',
          'alarm_policy_id':
          'alp-m7z5okaq',
          'disabled': 0,
          'consecutive_periods': 1,
          'alarm_policy_rule_name': '',
          'create_time': '2016-01-07T14:22:58',
          'alarm_policy_rule_id': 'alpr-vp9d2olk',
          'owner': 'usr-9NxdLZZp',
          'condition_type': 'lt'
        },
        'alpr-7xlgpcpc': {
          'status': 'alarm',
          'data_processor': 'raw',
          'recent_monitor_data': [
            [1452147810, 4.8],
            [1452147820, 4.8],
            [1452147830, 4.7],
            [1452147840, 4.7],
            [1452147850, 4.8],
            [1452147860, 4.7]
          ],
          'thresholds': '90',
          'meter': 'memory',
          'alarm_policy_id': 'alp-m7z5okaq',
          'disabled': 0,
          'consecutive_periods': 1,
          'alarm_policy_rule_name': '',
          'create_time': '2016-01-07T14:22:58',
          'alarm_policy_rule_id': 'alpr-7xlgpcpc',
          'owner': 'usr-9NxdLZZp',
          'condition_type': 'lt'
        },
        'alpr-tmzqnnau': {
          'status': 'ok',
          'data_processor': 'raw',
          'recent_monitor_data': [
            [1452147810, 0.3],
            [1452147820, 0.4],
            [1452147830, 0.4],
            [1452147840, 0.3],
            [1452147850, 0.5]
          ],
          'thresholds': '90',
          'meter': 'cpu',
          'alarm_policy_id': 'alp-m7z5okaq',
          'disabled': 0,
          'consecutive_periods': 1,
          'alarm_policy_rule_name': '',
          'create_time': '2016-01-07T14:22:58',
          'alarm_policy_rule_id': 'alpr-tmzqnnau',
          'owner': 'usr-9NxdLZZp',
          'condition_type': 'gt'
          }
        }",
      "resource": "{
        'resource_name': u'\\u7ebf\\u4e0a\\u6d4b\\u8bd5\\u4e00',
        'resource_type': 'instance',
        'resource_id': 'i-k6236wqb'
      }",
      "alarm_policy": "线上测试1",
      "zone": "gd1",
      "trigger_status": "alarm"
    }

    req.integration = _id: 1

    $qingcloud.then (qingcloud) ->
      qingcloud.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql 'QingCloud: i-k6236wqb 线上测试一 instance'
      message.attachments[0].data.text.should.eql '''
      RULE_ID: alpr-vp9d2olk STATUS: alarm
      RULE_ID: alpr-7xlgpcpc STATUS: alarm
      RULE_ID: alpr-tmzqnnau STATUS: ok
      '''

    .nodeify done
