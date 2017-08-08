module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Models exposing (Model)
import Public
import Styles
import VenuePresenter as Present


contentRow : Model -> Html msg
contentRow model =
    case model.currentVenue of
        Nothing ->
            div
                [ Styles.defaultContent ]
                [ div
                    [ style [ ( "margin", "auto" ) ] ]
                    [ img
                        [ Styles.defaultBanner
                        , src Public.defaultBanner
                        ]
                        []
                    ]
                , h4
                    []
                    [ text model.waitingMsg ]
                ]

        Just venue ->
            div
                [ Styles.contentRow ]
                [ Present.banner venue
                , div
                    [ Styles.contentColumn ]
                    [ Present.name venue
                    , Present.location venue
                    ]
                , Present.hours venue
                , Present.rating venue
                , Present.attributes venue
                ]


view : Model -> Html msg
view model =
    div
        []
        [ h2
            [ Styles.mainHeader ]
            [ text "Coffee & Donuts" ]
        , div
            []
            [ div
                [ Styles.mapWrapper ]
                [ div
                    [ id "map"
                    , Styles.map
                    ]
                    []
                ]
            , div
                [ Styles.divider ]
                []
            , contentRow model
            ]
        ]
