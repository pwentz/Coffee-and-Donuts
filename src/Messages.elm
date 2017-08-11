module Messages
    exposing
        ( MarkerEvent
        , Msg
        , Success(..)
        , applyWithDefault
        , init
        , initWithError
        )

import Error.Model exposing (Err)
import Geolocation as Geo
import Http
import Json.Decode as Json
import Models exposing (AppData, Coords, FullVenueData, Model, VenueMarker)


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
    = FetchVenues (List ( Coords, VenueMarker ))
    | GetLocation Geo.Location
    | OnVenueSelection MarkerEvent
    | FetchVenueData FullVenueData
    | NewMarker { id : Int, lat : Float, lng : Float }


applyWithDefault : (Success -> a) -> (Err -> a) -> Msg -> a
applyWithDefault onSuccess onFail msg =
    case msg of
        Error err ->
            onFail err

        Msg succ ->
            onSuccess succ


initWithError : Err -> Msg
initWithError err =
    Error err


init : Success -> Msg
init succ =
    Msg succ
