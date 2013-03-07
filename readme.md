## The Stack

* Node v0.8.8
* Express v3.x
* CoffeeScript v1.3.3
* Jade v0.26.0
* Connect Assets v2.2.1

## Requirements

* [NodeJs](http://nodejs.org)
* [CoffeeScript](http://coffeescript.org)
* [Mocha](http://visionmedia.github.com/mocha/)

## Included Packages

Via npm: (`npm install`)
* [Express](http://expressjs.com)
* [Jade](http://jade-lang.com/)
* [connect-assets](http://github.com/TrevorBurnham/connect-assets)
* [Mocha](http://visionmedia.github.com/mocha/)
* [Should.Js](https://github.com/visionmedia/should.js/)

## Usage

### Local

To build source files, build redis, and execute all servers (with automatic reloading on changes) just run:

    cake go

### Heroku

To deploy to heroku (you will need a verified heroku account for redistogo):

    heroku create
    heroku addons:add redistogo:nano
    git push heroku master
    heroku open

## Thanks to

* [Jeremy Ashkenas](https://github.com/jashkenas) for creating coffee-script
* [TJ Holowaychuk](https://github.com/visionmedia) for creating express
* [express-coffee](https://github.com/twilson63/express-coffee) upon which this is based.
