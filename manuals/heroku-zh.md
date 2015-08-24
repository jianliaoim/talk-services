可以手动复制下面的命令然后在终端中执行:
```shell
$ heroku addons:create deployhooks:http --url LOCALE_LINK
```

注意: 如果您有多个Heroku应用, 你需要在命令中指定对应的应用.
```shell
$ heroku addons:create deployhooks:http --url LOCALE_LINK --app your-heroku-app-name
```
