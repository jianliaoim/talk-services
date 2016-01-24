1. A robot will appear in your team when you add a robot integration. When you send messages to the robot or mention it in topics, a copy of this message will send to your configured URL.


  ```json
  {
      "_id": "549908a78cd040715c48caf2",
      "body": "Winter is coming",                    // Message content
      "room": {
        "_id": "549908a68cd040715c48cadf",
        "topic": "Game of Throne",                      // Name of topic
        // ...
      },
      "creator": {
        "_id": "549908a68cd040715c48cad1",
        "name": "Stack"                                 // Creator of this message
        // ...
      },
      "_teamId": "549908a68cd040715c48cad3",            // Team id
      "createdAt": "2014-12-23T06:16:06.999Z",          // Create time
      "updatedAt": "2014-12-23T06:16:06.999Z"           // Update time
      // ...
  }
  ```

2. if you need send a reply to this message, response with a json structure like the follow example

  ```json
  {
    "content": "Thanks!",                      // Message body (content and text should not both empty)
    "text": "Got it",                          // The attachment's text(display in the attachment field)
    "authorName": "Little Finger",             // User name of the robot (Optional)
    "redirectUrl": "http://you.service.com"    // Redirect url in the attachment (Optional)
  }
  ```

  ![](/images/inte-guide/sample-outgoing-1.png)

3. Each robot has a webhook URL, you can send messages to rooms (with `_roomId`) , private chat (with `_toId`) or a story (with `_storyId`). The robot should have the access permission to these rooms.

  ```json
  {
    "content": "Hello",                             // Message body
    "authorName": "Stack",                          // Creator name
    "title": "Winter is coming",                    // Attachment title
    "text": "",                                     // Attachment content
    "redirectUrl": "https://talk.ai/site",          // Redirect url
    "thumbnailPicUrl": "http://your.image.url",     // A thumbnail picture url
    "_roomId": "549908a68cd040715c48cad3",          // Room id
    "_toId": "549908a68cd040715c48cad2",            // Private chat user id
    "_storyId": "549908a68cd040715c48cad5"          // Story id
  }
  ```
