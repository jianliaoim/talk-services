should = require 'should'
Promise = require 'bluebird'
requireDir = require 'require-dir'

loader = require '../../src/loader'
{req} = require '../util'
$mailgun = loader.load 'mailgun'

payloads = requireDir './mailgun_assets'

describe 'Mailgun#Webhook', ->

  it 'receive delivered', (done) ->

    req.body = payloads['delivered'].body

    $mailgun.then (mailgun) ->
      mailgun.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.text.should.eql '''
Delivered messages

Received: by luna.mailgun.net with SMTP mgrt 8734663311733; Fri, 03 May 2013 18:26:27 +0000
Mime-Version: 1.0
Subject: Test deliver webhook
From: Bob <bob@mail.jianliao.com>
To: Alice <alice@example.com>
Message-Id: <20130503182626.18666.16540@mail.jianliao.com>
X-Mailgun-Variables: {"my_var_1": "Mailgun Variable #1", "my-var-2": "awesome"}
Date: Fri, 03 May 2013 18:26:27 +0000
Sender: bob@mail.jianliao.com
'''
    .nodeify done

  it 'receive dropped', (done) ->

    req.body = payloads['dropped'].body

    $mailgun.then (mailgun) ->
      mailgun.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.text.should.eql '''
Dropped messages
reason: hardfail

Received: by luna.mailgun.net with SMTP mgrt 8755546751405; Fri, 03 May 2013 19:26:59 +0000
Mime-Version: 1.0
Subject: Test drop webhook
From: Bob <bob@mail.jianliao.com>
To: Alice <alice@example.com>
Message-Id: <20130503192659.13651.20287@mail.jianliao.com>
List-Unsubscribe: <mailto:u+na6tmy3ege4tgnldmyytqojqmfsdembyme3tmy3cha4wcndbgaydqyrgoi6wszdpovrhi5dinfzw63tfmv4gs43uomstimdhnvqws3bomnxw2jtuhusteqjgmq6tm@mail.jianliao.com>
X-Mailgun-Sid: WyIwNzI5MCIsICJpZG91YnR0aGlzb25lZXhpc3RzQGdtYWlsLmNvbSIsICI2Il0=
X-Mailgun-Variables: {"my_var_1": "Mailgun Variable #1", "my-var-2": "awesome"}
Date: Fri, 03 May 2013 19:26:59 +0000
Sender: bob@mail.jianliao.com
'''
    .nodeify done

  it 'receive clicks', (done) ->

    req.body = payloads['clicks'].body

    $mailgun.then (mailgun) ->
      mailgun.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.text.should.eql '''
Clicks
url: http://mailgun.net
user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.43 Safari/537.31
'''
    .nodeify done

  it 'receive hard', (done) ->

    req.body = payloads['hard'].body

    $mailgun.then (mailgun) ->
      mailgun.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.text.should.eql '''
Hard bounces
error: 5.1.1 The email account that you tried to reach does not exist. Please try\n5.1.1 double-checking the recipient's email address for typos or\n5.1.1 unnecessary spaces. Learn more at\n5.1.1 http://support.example.com/mail/bin/answer.py

Received: by luna.mailgun.net with SMTP mgrt 8734663311733; Fri, 03 May 2013 18:26:27 +0000
Mime-Version: 1.0
Subject: Test bounces webhook
From: Bob <bob@mail.jianliao.com>
To: Alice <alice@example.com>
Message-Id: <20130503182626.18666.16540@mail.jianliao.com>
List-Unsubscribe: <mailto:u+na6tmy3ege4tgnldmyytqojqmfsdembyme3tmy3cha4wcndbgaydqyrgoi6wszdpovrhi5dinfzw63tfmv4gs43uomstimdhnvqws3bomnxw2jtuhusteqjgmq6tm@mail.jianliao.com>
X-Mailgun-Sid: WyIwNzI5MCIsICJhbGljZUBleGFtcGxlLmNvbSIsICI2Il0=
X-Mailgun-Variables: {"my_var_1": "Mailgun Variable #1", "my-var-2": "awesome"}
Date: Fri, 03 May 2013 18:26:27 +0000
Sender: bob@mail.jianliao.com
'''
    .nodeify done

  it 'receive open', (done) ->

    req.body = payloads['open'].body

    $mailgun.then (mailgun) ->
      mailgun.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.text.should.eql '''
Opens
user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.43 Safari/537.31
'''
    .nodeify done

  it 'receive spam', (done) ->

    req.body = payloads['spam'].body

    $mailgun.then (mailgun) ->
      mailgun.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.text.should.eql '''
Spam complaints

Mime-Version: 1.0
Return-Path: <bounce+ad27a4.345-alice=example.com@mail.jianliao.com>
Received-Spf: pass (mta1122.mail.sk1.example.com:    domain  of  bc=example+example.com=example@mail.jianliao.com    designates  173.193.210.33    as permitted sender)
X-Originating-Ip: [173.193.210.33]
Authentication-Results: mta1122.mail.sk1.example.com  from=mail.jianliao.com;    domainkeys=pass (ok); from=mail.jianliao.com; dkim=pass (ok)
Received: from 127.0.0.1 (EHLO mail-luna33.mailgun.org)    (173.193.210.33)    by  mta1122.mail.sk1.example.com with SMTP;    Mon, 14 Feb 2011 21:57:01 -0800
Dkim-Signature: a=rsa-sha256; v=1; c=relaxed/relaxed; d=mail.jianliao.com;    q=dns/txt; s=mg; t=1297749420;    h=MIME-Version: Subject: From: To: Date: Message-Id:    List-Id:    Sender: Content-Type: Content-Transfer-Encoding;    bh=gYbP9hMgpeW3ea3yNJlie/Yt+URsh5LwB24aU1Oe1Uo=;    b=Vr6ipa2P79dYKAtYtgZSiMXInPvthTzaQBs2XzJLEu7lc0s6bmHEApy3r2dVsI+MoJ+GtjWt  pkQVbwX2ZipJsdGUigT60aiTX45ll1QG5X83N+mKR4cIDmVJD8vtwjJcLfSMdDTuOK6jI41B    NSYVlT1YWPh3sh3Tdl0ZxolDlys=
Domainkey-Signature: a=rsa-sha1; c=nofws; d=mail.jianliao.com; s=mg;    h=MIME-Version: Subject: From: To:    Date:   Message-Id: List-Id: Sender:    Content-Type:   Content-Transfer-Encoding;    b=QhZX2rhdVYccjPsUTMw1WASPEgsDg0KSBGHHwItsZd0xopzvgK2iQAuSJiJXo7yomFgj5R    /Cz/iTv9I4Jdt6JPaEc5wf5X2JWqBCO+F1FTyYcVWzMG+WhGCdFn6sw82ma8VVY7UUU0TGsS    tJe+1JkAQ1ILlm4rdXmS9jlG4H/ZE=
Received: from    web3    (184-106-70-82.static.cloud-ips.com [184.106.70.82])    by  mxa.mailgun.org    with ESMTPSA id EB508F0127B for <alice@example.com>;    Tue, 15 Feb 2011 05:56:45 +0000 (UTC)
Subject: Hi Alice
From: Bob <bob@mail.jianliao.com>
To: Alice <alice@example.com>
Date: Tue, 15 Feb 2011 05:56:45 -0000
Message-Id: <20110215055645.25246.63817@mail.jianliao.com>
Sender: SRS0=1U0y=VM=example.com=example@mail.jianliao.com
Content-Length: 629
'''
    .nodeify done

  it 'receive unsubscribe', (done) ->

    req.body = payloads['unsubscribe'].body

    $mailgun.then (mailgun) ->
      mailgun.receiveEvent 'service.webhook', req
    .then (message) ->
      message.attachments[0].data.text.should.eql '''
Unsubscribes
user-agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.43 Safari/537.31
'''
    .nodeify done
