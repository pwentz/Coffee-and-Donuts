module Venues.View exposing (..)

import Html exposing (Html)
import Models exposing (Err(..))


type Model msg
    = Error Err
    | Venue
        { banner : Html msg
        , primaryInfo : Html msg
        , hours : Html msg
        , rating : Html msg
        , attributes : Html msg
        }
