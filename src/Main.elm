module Main exposing (..)

import Command.Actions as Actions
import Command.Model
import Decoders as Decode
import Dict
import Error.View
import Html exposing (Html)
import Leaflet as L
import Messages as Msg exposing (Msg)
import Models exposing (Model(..))
import Update
import Venue.Presenter
import View


view : Model -> Html a
view =
    View.view
        << Venue.Presenter.presentWithDefault View.defaultVenueView
        << Error.View.present


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    Command.Model.init msg model
        |> Command.Model.apply Update.update


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
        ! [ Actions.getLocation ]
