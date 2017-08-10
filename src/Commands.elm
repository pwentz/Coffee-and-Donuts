module Commands exposing (..)

import Decoders as Decode
import Geolocation as Geo
import Http
import Json.Decode as Json
import Leaflet as L
import Messages exposing (Msg(FetchVenueData, FetchVenues, GetLocation))
import Models exposing (Coords)
import Public
import Random
import Secrets
import Task
import Tuple


getLocation : Cmd Msg
getLocation =
    Task.attempt GetLocation Geo.now


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
    in
    Http.send FetchVenues request


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
    in
    Http.send FetchVenueData request
