module App.Msg
    exposing
        ( MarkerEvent
        , Msg
        , Success(..)
        , applyWithDefault
        , init
        , initWithError
        )

import App.Model exposing (Coords)
import Error.Model exposing (Err)
import Geolocation as Geo
import Http
import Json.Decode as Json
import Venue.Model


type alias MarkerEvent =
    { event : String
    , lat : Float
    , lng : Float
    , targetId : Int
    }


type Msg
    = Error Err
    | Msg Success


type Success
    = FetchVenues (List ( Coords, Venue.Model.Marker ))
    | GetLocation Geo.Location
    | OnVenueSelection MarkerEvent
    | FetchVenueData Venue.Model.Venue
    | NewMarker { id : Int, lat : Float, lng : Float }


applyWithDefault : (Success -> a) -> (Err -> a) -> Msg -> a
applyWithDefault onSuccess onFail msg =
    case msg of
        Error err ->
            onFail err

        Msg succ ->
            onSuccess succ


initWithError : Err -> Msg
initWithError =
    Error


init : Success -> Msg
init =
    Msg
