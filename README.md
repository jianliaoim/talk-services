talk-services
===

[![NPM version][npm-image]][npm-url]
[![Build Status][travis-image]][travis-url]
[![Talk topic][talk-image]][talk-url]

Integration services of talk.ai

### Events

* `integration.create`
* `integration.update`
* `integration.remove`
* `webhook`  Emitted when receive webhook request
* `before.integration.create`
* `before.integration.update`
* `before.integration.remove`

In general, events are emitted after the api server response the http request, so the name of events are reference to `controller.action` pattern. You can checkout all the `controller.action`s from the [`discover` api](https://talk.ai/v1/discover).

The events with `before` prefix are pre hooks of the process, so their callbacks or return values will have affects on the response of users. Do not use these events unless you think it is necessary.

[npm-url]: https://npmjs.org/package/talk-services
[npm-image]: http://img.shields.io/npm/v/talk-services.svg

[travis-url]: https://travis-ci.org/teambition/talk-services
[travis-image]: http://img.shields.io/travis/teambition/talk-services.svg

[talk-url]: https://guest.talk.ai/rooms/4f5dc4b04w
[talk-image]: https://img.shields.io/talk/t/4f5dc4b04w.svg
