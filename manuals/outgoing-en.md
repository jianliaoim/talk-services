When a message is sent to the bind topic (integration messages, system messages, files are not included), a POST will be sent to the configured URL.

Message Structure

```json
{
    "_id": "549908a78cd040715c48caf2",
    "body": "Winter is coming",                    // Message Body
    "room": {
      "_id": "549908a68cd040715c48cadf",
      "topic": "Game of Throne",                      // Topic Name
      "email": "room.r2e29c2a0@talk.ai"               // Topic Email Address
      // …
    },
    "creator": {
      "_id": "549908a68cd040715c48cad1",
      "name": "Stack"                                 // Sender’s Name
      // …
    },
    "_teamId": "549908a68cd040715c48cad3",            // Team ID
    "createdAt": "2014-12-23T06:16:06.999Z",          // Date Created
    "updatedAt": "2014-12-23T06:16:06.999Z"           // Date Modified
    // …
}
```

If the handler wishes to post a response, the following JSON should be returned as the body of the response.

```json
{
  "text": "Got it",                          // Message reply
  "authorName": "Little Finger",             // Name display in the reply (optional)
  "redirectUrl": "http://you.service.com"    // Link redirect (optianal)
}
```

![](/images/inte-guide/sample-outgoing-1.png)
