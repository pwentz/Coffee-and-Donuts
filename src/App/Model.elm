module App.Model
    exposing
        ( Coords
        , Data
        , Model
        , applyWithDefault
        , init
        , initWithError
        )

import Dict exposing (Dict)
import Error.Model as Err exposing (Err)
import Venue.Model


type Model
    = Error Err
    | Model Data


type alias Coords =
    ( Float, Float )


type alias Data =
    { venueMarkers : Dict Coords Venue.Model.Marker
    , fullVenues : Dict String Venue.Model.Venue
    , location : Coords
    , currentVenue : Maybe Venue.Model.Venue
    }


init : Data -> Model
init =
    Model


initWithError : Err -> Model
initWithError =
    Error


applyWithDefault : (Data -> a) -> (Err -> a) -> Model -> a
applyWithDefault onData onError model =
    case model of
        Error err ->
            onError err

        Model data ->
            onData data
