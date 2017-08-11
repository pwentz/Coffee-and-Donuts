module Main exposing (..)

import App.Model exposing (Model)
import App.Msg exposing (Msg)
import App.Update
import App.View
import Command.Actions as Actions
import Command.Model
import Decoders as Decode
import Dict
import Error.View
import Html exposing (Html)
import Leaflet as L
import Venue.Presenter


view : Model -> Html a
view =
    App.View.view
        << Venue.Presenter.withDefault App.View.defaultVenue
        << Error.View.present


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    Command.Model.init msg model
        |> Command.Model.applyUpdate App.Update.update


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions =
            \_ ->
                Sub.batch
                    [ L.onMarkerCreation Decode.decodeOnMarkerCreation
                    , L.onMarkerEvent Decode.decodeMarkerEvent
                    , L.jsError Decode.decodeJsError
                    ]
        }


init : ( Model, Cmd Msg )
init =
    App.Model.init
        { venueMarkers = Dict.empty
        , fullVenues = Dict.empty
        , location = ( 0, 0 )
        , currentVenue = Nothing
        }
        ! [ Actions.getLocation ]
