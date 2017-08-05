## Coffee & Donuts

Small web app that grabs your location and shows you all the places nearby that sell
coffee and donuts (but mostly donuts).


### Installation

There are a few ways to install Elm if you don't have it on your machine.

The simplest is via npm
```
npm install -g elm
```

If you don't have npm, you can install it [here](https://www.npmjs.com/get-npm?utm_source=house&utm_medium=homepage&utm_campaign=free%20orgs&utm_term=Install%20npm)

If you'd like to avoid npm, you can [install Elm from the Elm website](https://guide.elm-lang.org/install.html)

### Build

To build the app into a playable format, run the following from the root directory...

```
elm-make src/Main.elm --output app.js
elm-reactor
```

..and head on over to `http://localhost:8000/index.html`

### Warning

This app hits the [Foursquare API](https://developer.foursquare.com/) to collect data on venues. In order to run locally,
you must provide a few access tokens and store them in a `Secrets.elm` file. A Foursquare client id and
client secret must be provided under the names `foursquareClientId` and `foursquareClientSecret`, respectively.
To get these, you must [register for an account](https://foursquare.com/login?continue=%2Fdevelopers%2Fapps) if you don't already have one,
and then [create an app](https://foursquare.com/developers/register) with Foursquare. I apologize for the inconvenience.


### Tests

To run the tests, you first need to download [elm-test](https://github.com/rtfeldman/node-test-runner) if you don't
have it already

```
npm install -g elm-test
```

Once that's installed, you can run the tests with the following command
```
elm test
```
