module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Public
import Styles


defaultVenueView : Html a
defaultVenueView =
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
        ]


view : Html a -> Html a
view venueView =
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
            , venueView
            ]
        ]
