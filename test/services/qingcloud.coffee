should = require 'should'
loader = require '../../src/loader'
{req} = require '../util'
$qingcloud = loader.load 'qingcloud'

describe 'QingCloud#Webhook', ->

  it 'receive webhook', (done) ->

    req.body = {
      "alarm_policy": "inst",
      "resource": {
        "resource_id": "i-fsda5aiv",
        "resource_name": "",
        "resource_type": "instance"
      },
      "rules": {
        "alpr-lr3gv19q": {
          "alarm_policy_id": "alp-7x97ldud",
          "alarm_policy_rule_id": "alpr-lr3gv19q",
          "alarm_policy_rule_name": "",
          "condition_type": "gt",
          "consecutive_periods": 1,
          "create_time": "2015-06-05T16:28:55",
          "data_processor": "raw",
          "disabled": 0,
          "meter": "disk-us",
          "owner": "usr-qkMLt5Oo",
          "recent_monitor_data": {"/": [[1433771551, 6]]},
          "status": "ok",
          "thresholds": "90"
        },
        "alpr-u8vue5g6": {
          "alarm_policy_id": "alp-7x97ldud",
          "alarm_policy_rule_id": "alpr-u8vue5g6",
          "alarm_policy_rule_name": "",
          "condition_type": "lt",
          "consecutive_periods": 1,
          "create_time": "2015-06-05T16:28:55",
          "data_processor": "raw",
          "disabled": 0,
          "meter": "memory",
          "owner": "usr-qkMLt5Oo",
          "recent_monitor_data": [[1433771500, 10.3],
           [1433771510, 10.4],
           [1433771520, 10.3],
           [1433771530, 10.4],
           [1433771540, 10.3]],
          "status": "alarm",
          "thresholds": "90"
        },
        "alpr-wkjaaqvh": {
          "alarm_policy_id": "alp-7x97ldud",
          "alarm_policy_rule_id": "alpr-wkjaaqvh",
          "alarm_policy_rule_name": "",
          "condition_type": "gt",
          "consecutive_periods": 1,
          "create_time": "2015-06-05T16:28:55",
          "data_processor": "raw",
          "disabled": 0,
          "meter": "cpu",
          "owner": "usr-qkMLt5Oo",
          "recent_monitor_data": [[1433771500, 0.2],
           [1433771510, 0.5],
           [1433771520, 0.2],
           [1433771530, 0.4],
           [1433771540, 0.2]],
          "status": "ok",
          "thresholds": "90"
        }
      },
      "trigger_status": "alarm",
      "zone": "beta"
    }

    req.integration = _id: 1

    $qingcloud.then (qingcloud) ->
      qingcloud.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.title.should.eql 'QingCloud: i-fsda5aiv instance'
      message.attachments[0].data.text.should.eql '''
      RULE_ID: alpr-lr3gv19q STATUS: ok
      RULE_ID: alpr-u8vue5g6 STATUS: alarm
      RULE_ID: alpr-wkjaaqvh STATUS: ok
      '''
    .nodeify done
