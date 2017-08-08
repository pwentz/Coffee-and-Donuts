module Main exposing (..)

import Commands as C
import Decoders as Decode
import Dict
import Html
import Leaflet as L
import Messages exposing (Msg)
import Models exposing (Model)
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
    { shortVenues = []
    , fullVenues = Dict.empty
    , waitingMsg = ""
    , location = { lat = 0.0, lng = 0.0 }
    , currentVenue = Nothing
    , leafletMarkers = []
    }
        ! [ C.getLocation ]
