module Main exposing (..)

import Commands as C
import Decoders as Decode
import Dict
import Html
import Leaflet as L
import Messages exposing (Msg)
import Models exposing (Model(..))
import Update
import VenuePresenter
import View


main =
    Html.program
        { init = init
        , view = View.view << VenuePresenter.present
        , update = Update.update
        , subscriptions =
            \_ ->
                Sub.batch
                    [ L.onMarkerCreation Decode.decodeOnMarkerCreation
                    , L.onMarkerEvent Decode.decodeMarkerEvent
                    ]
        }


init : ( Model, Cmd Msg )
init =
    Model
        { venueMarkers = Dict.empty
        , fullVenues = Dict.empty
        , location = ( 0, 0 )
        , currentVenue = Nothing
        }
        ! [ C.getLocation ]
