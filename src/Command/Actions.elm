module Command.Actions exposing (..)

import App.Model exposing (Coords)
import Decoders as Decode
import Error.Model as Err
import Geolocation as Geo
import Http
import Json.Decode as Json
import Msg exposing (Msg)
import Public
import Secrets
import Task


getLocation : Cmd Msg
getLocation =
    let
        dispatch res =
            case res of
                Err _ ->
                    Msg.initWithError Err.GetLocation

                Ok location ->
                    (Msg.init << Msg.GetLocation) location
    in
    Task.attempt dispatch Geo.now


fetchVenues : Coords -> Cmd Msg
fetchVenues ( lat, lng ) =
    let
        params =
            "?ll="
                ++ toString lat
                ++ ","
                ++ toString lng
                ++ "&client_id="
                ++ Secrets.foursquareClientId
                ++ "&client_secret="
                ++ Secrets.foursquareClientSecret
                ++ "&limit=10&v=20170701&m=foursquare&section=donuts&openNow=1"

        url =
            "https://api.foursquare.com/v2/venues/explore" ++ params

        request =
            Http.get url Decode.foursquareVenuesDecoder

        dispatch res =
            case res of
                Err _ ->
                    Msg.initWithError Err.FetchVenues

                Ok venues ->
                    (Msg.init << Msg.FetchVenues) venues
    in
    Http.send dispatch request


fetchVenueData : String -> Cmd Msg
fetchVenueData venueId =
    let
        params =
            "?client_id="
                ++ Secrets.foursquareClientId
                ++ "&client_secret="
                ++ Secrets.foursquareClientSecret
                ++ "&v=20170701&m=foursquare"

        url =
            "https://api.foursquare.com/v2/venues/" ++ venueId ++ params

        request =
            Http.get url (Json.at [ "response", "venue" ] Decode.fullVenueDecoder)

        dispatch res =
            case res of
                Err _ ->
                    Msg.initWithError Err.FetchVenue

                Ok venue ->
                    (Msg.init << Msg.FetchVenueData) venue
    in
    Http.send dispatch request
