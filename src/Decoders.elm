module Decoders exposing (..)

import Json.Decode as Json
import Json.Encode exposing (Value)
import Messages exposing (Msg(NewMarker, OnVenueSelection))
import Models exposing (FullVenueData, Model(..), ShortVenueData)


decodeOnMarkerCreation : Value -> Msg
decodeOnMarkerCreation val =
    let
        result =
            Json.decodeValue Json.int val
    in
    NewMarker result


decodeMarkerEvent : Value -> Msg
decodeMarkerEvent val =
    let
        eventDataMapping =
            \e lat lng id ->
                { event = e
                , lat = lat
                , lng = lng
                , targetId = id
                }

        didGoThrough =
            Json.decodeValue
                (Json.map4
                    eventDataMapping
                    (Json.field "event" Json.string)
                    (Json.field "lat" Json.float)
                    (Json.field "lng" Json.float)
                    (Json.field "targetId" Json.int)
                )
                val
    in
    OnVenueSelection didGoThrough


foursquareVenuesDecoder : Json.Decoder (List (List ShortVenueData))
foursquareVenuesDecoder =
    Json.at [ "response", "groups" ] <|
        Json.list <|
            Json.at [ "items" ] <|
                Json.list <|
                    Json.field "venue" venueDecoder


venueDecoder : Json.Decoder ShortVenueData
venueDecoder =
    Json.map3
        ShortVenueData
        (Json.field "id" Json.string)
        (Json.field "name" Json.string)
        (Json.field "location"
            (Json.map2
                (\lat lng -> { lat = lat, lng = lng })
                (Json.field "lat" Json.float)
                (Json.field "lng" Json.float)
            )
        )


type alias VenuePhoto =
    { prefix : String
    , suffix : String
    , width : Int
    , height : Int
    }


fullVenueDecoder : Json.Decoder FullVenueData
fullVenueDecoder =
    Json.map8
        FullVenueData
        (Json.field "id" Json.string)
        (Json.field "name" Json.string)
        (Json.field "location" <|
            Json.field "formattedAddress" (Json.list Json.string)
        )
        (Json.field "contact" <|
            Json.maybe <|
                Json.field "phone" Json.string
        )
        (Json.maybe <|
            Json.field "rating" Json.float
        )
        (Json.maybe <|
            Json.at [ "popular", "timeframes" ] <|
                Json.list <|
                    Json.map2
                        (\day times ->
                            { day = day
                            , hours = (Maybe.withDefault "Not Listed" << List.head) times
                            }
                        )
                        (Json.field "days" Json.string)
                        (Json.field "open" <|
                            Json.list <|
                                Json.field "renderedTime" Json.string
                        )
        )
        (Json.maybe <|
            Json.at [ "attributes", "groups" ] <|
                Json.list <|
                    Json.field "name" Json.string
        )
        (Json.maybe <|
            Json.field "bestPhoto" <|
                Json.map4
                    VenuePhoto
                    (Json.field "prefix" Json.string)
                    (Json.field "suffix" Json.string)
                    (Json.field "width" Json.int)
                    (Json.field "height" Json.int)
        )
