module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Models exposing (Model)
import Public
import Styles
import VenuePresenter exposing (ViewModel(..))


renderContent : ViewModel a -> Html a
renderContent viewModel =
    case viewModel of
        DefaultView ->
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

        VenueView { banner, primaryInfo, hours, rating, attributes } ->
            div
                [ Styles.contentRow ]
                [ banner
                , primaryInfo
                , hours
                , rating
                , attributes
                ]

        ErrorView desc ->
            div
                []
                [ p
                    []
                    [ text desc ]
                ]


view : ViewModel a -> Html a
view viewModel =
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
            , renderContent viewModel
            ]
        ]
