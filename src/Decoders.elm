module Decoders exposing (..)

import App.Msg as Msg exposing (MarkerEvent, Msg)
import Error.Model as Err
import Json.Decode as Json
import Json.Encode exposing (Value)
import Result
import Venue.Model


decodeJsError : Value -> Msg
decodeJsError val =
    let
        hasMsg =
            Json.decodeValue Json.string val

        dispatch res =
            case res of
                Err msg ->
                    Msg.initWithError <|
                        Err.Leaflet msg

                Ok errMsg ->
                    Msg.initWithError <|
                        Err.Leaflet errMsg
    in
    dispatch hasMsg


decodeOnMarkerCreation : Value -> Msg
decodeOnMarkerCreation val =
    let
        didGoThrough =
            Json.decodeValue
                (Json.map3
                    (\id lat lng -> { id = id, lat = lat, lng = lng })
                    (Json.field "id" Json.int)
                    (Json.field "lat" Json.float)
                    (Json.field "lng" Json.float)
                )
                val

        dispatch res =
            case res of
                Err _ ->
                    Msg.initWithError <|
                        Err.Leaflet "failed on marker creation"

                Ok eventData ->
                    (Msg.init << Msg.NewMarker) eventData
    in
    dispatch didGoThrough


decodeMarkerEvent : Value -> Msg
decodeMarkerEvent val =
    let
        didGoThrough =
            Json.decodeValue
                (Json.map4
                    MarkerEvent
                    (Json.field "event" Json.string)
                    (Json.field "lat" Json.float)
                    (Json.field "lng" Json.float)
                    (Json.field "targetId" Json.int)
                )
                val

        dispatch res =
            case res of
                Err _ ->
                    Msg.initWithError (Err.Leaflet "failed on marker event")

                Ok eventData ->
                    (Msg.init << Msg.OnVenueSelection) eventData
    in
    dispatch didGoThrough


foursquareVenuesDecoder : Json.Decoder (List ( ( Float, Float ), Venue.Model.Marker ))
foursquareVenuesDecoder =
    Json.map
        List.concat
        (Json.at [ "response", "groups" ] <|
            Json.list <|
                Json.at [ "items" ] <|
                    Json.list <|
                        Json.field "venue" venueDecoder
        )


venueDecoder : Json.Decoder ( ( Float, Float ), Venue.Model.Marker )
venueDecoder =
    let
        venueMarker venueId name =
            { venueId = venueId
            , name = name
            , markerId = Nothing
            }
    in
    Json.map2
        (,)
        (Json.field "location" <|
            Json.map2
                (\lat lng -> ( lat, lng ))
                (Json.field "lat" Json.float)
                (Json.field "lng" Json.float)
        )
        (Json.map2
            venueMarker
            (Json.field "id" Json.string)
            (Json.field "name" Json.string)
        )


type alias VenuePhoto =
    { prefix : String
    , suffix : String
    , width : Int
    , height : Int
    }


fullVenueDecoder : Json.Decoder Venue.Model.Venue
fullVenueDecoder =
    Json.map8
        Venue.Model.Venue
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
