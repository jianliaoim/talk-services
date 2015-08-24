We'll be adding a deploy hook from the Heroku command-line tool. Log in to Heroku from your command shell and run the following command to set up the HTTP Post hook:
```shell
$ heroku addons:create deployhooks:http --url LOCALE_LINK
```

Note: If you have multiple Heroku apps, you'll need to specify the app (see below) or run the above command from the app's folder.
```shell
$ heroku addons:create deployhooks:http --url LOCALE_LINK --app your-heroku-app-name
```
