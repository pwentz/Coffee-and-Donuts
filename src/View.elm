module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Models exposing (Err(..), Model)
import Public
import Styles
import Venues.View


renderError : Err -> Html a
renderError err =
    let
        toRender =
            p [] [ text "Oh no!" ]
    in
    case err of
        FetchVenue ->
            toRender

        GetLocation ->
            toRender

        FetchVenues ->
            toRender

        Leaflet _ ->
            toRender


renderContent : Maybe (Venues.View.Model a) -> Html a
renderContent viewModel =
    case viewModel of
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
                ]

        Just (Venues.View.Venue { banner, name, location, hours, rating, attributes }) ->
            div
                [ Styles.contentRow ]
                [ banner
                , div
                    [ Styles.contentColumn ]
                    [ name
                    , location
                    ]
                , hours
                , rating
                , attributes
                ]

        Just (Venues.View.Error err) ->
            renderError err


view : Maybe (Venues.View.Model a) -> Html a
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
