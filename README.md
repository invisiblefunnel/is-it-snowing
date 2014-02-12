# Is it snowing?

Made with :heart: in CLT. Inspired by [jden/snowchatt](https://github.com/jden/snowchatt).

## Development

Register for an api key at [http://www.wunderground.com/weather/api](http://www.wunderground.com/weather/api).

```console
git clone https://github.com/invisiblefunnel/is-it-snowing.git
cd is-it-snowing/
bundle install
cp sample.env .env # update api key and city
shotgun
```

## Deploy

```console
heroku create <app name>
heroku config:set WUNDERGROUND_API_KEY=yourapikey
heroku config:set CITY=Charlotte
heroku config:set STATE=NC
git push heroku master
heroku open
```

[Add your version to the wiki.](https://github.com/invisiblefunnel/is-it-snowing/wiki/Have-you-redeployed-this-app%3F)
