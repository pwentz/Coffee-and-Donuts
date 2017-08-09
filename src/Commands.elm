module Commands exposing (..)

import Decoders as Decode
import Geolocation as Geo
import Http
import Json.Decode as Json
import Leaflet as L
import Messages exposing (Msg(FetchVenueData, FetchVenues, GetLocation))
import Models exposing (AppData)
import Public
import Random
import Secrets
import Task
import Tuple


getLocation : Cmd Msg
getLocation =
    Task.attempt GetLocation Geo.now


fetchVenues : AppData -> Cmd Msg
fetchVenues payload =
    let
        params =
            "?ll="
                ++ toString payload.location.lat
                ++ ","
                ++ toString payload.location.lng
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


populateMap : AppData -> Cmd Msg
populateMap payload =
    let
        random =
            Random.initialSeed 0
                |> Random.step (Random.int 0 Random.maxInt)

        icon =
            { url = Public.markerIcon
            , size = { height = 35, width = 35 }
            }

        venueMarkerData =
            \x ( ( id, seed ), markers ) ->
                ( Random.step (Random.int 0 Random.maxInt) seed
                , { id = id
                  , lat = x.location.lat
                  , lng = x.location.lng
                  , icon = Just icon
                  , draggable = False
                  , popup = Just x.name
                  , events =
                        [ { event = "mouseover"
                          , action = Just "openPopup"
                          , subscribe = False
                          }
                        , { event = "click"
                          , action = Nothing
                          , subscribe = True
                          }
                        ]
                  }
                    :: markers
                )

        venueMarkers =
            payload.shortVenues
                |> List.foldr venueMarkerData ( random, [] )
                |> Tuple.second
    in
    L.addMarkers venueMarkers
