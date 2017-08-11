module Venue.Presenter exposing (withDefault)

import App.Model exposing (Model)
import Error.View as ErrView exposing (ViewResult)
import Html exposing (..)
import Html.Attributes exposing (..)
import Public
import Styles
import Util
import Venue.Model


withDefault : Html a -> ViewResult a -> Html a
withDefault defaultView viewResult =
    let
        onCurrentVenue venue =
            div
                [ Styles.contentRow ]
                [ banner venue
                , div
                    [ Styles.contentColumn ]
                    [ name venue
                    , location venue
                    ]
                , hours venue
                , rating venue
                , attributes venue
                ]

        venueView appData =
            appData.currentVenue
                |> Maybe.map onCurrentVenue
                |> Maybe.withDefault defaultView
    in
    ErrView.apply venueView viewResult


name : Venue.Model.Venue -> Html msg
name venue =
    h1
        [ Styles.venueHeader ]
        [ text venue.name ]


banner : Venue.Model.Venue -> Html msg
banner venue =
    let
        getBanner =
            \x -> x.prefix ++ "150x150" ++ x.suffix

        bannerImg =
            venue.bestPhoto
                |> Maybe.map getBanner
                |> Maybe.withDefault Public.defaultBanner
    in
    div
        [ style
            [ ( "position", "relative" )
            , ( "height", "100%" )
            , ( "width", "100%" )
            ]
        , Styles.contentColumn
        ]
        [ div
            [ Styles.venueBannerWrapper ]
            [ img
                [ Styles.venueBanner
                , src bannerImg
                ]
                []
            ]
        ]


location : Venue.Model.Venue -> Html msg
location venue =
    let
        phoneNumber =
            venue.phone
                |> Maybe.map
                    (\x ->
                        if String.length x == 10 then
                            Util.formatPhoneNumber x
                        else
                            x
                    )
                |> Maybe.withDefault ""

        locationData =
            phoneNumber
                :: venue.location
                |> List.map (\x -> li [] [ text x ])
                |> (\xs -> ul [ Styles.venueLocationData ] xs)
    in
    locationData


hours : Venue.Model.Venue -> Html msg
hours venue =
    let
        popular =
            venue.popular
                |> Maybe.map
                    (List.map
                        (\x ->
                            li [] [ text <| x.day ++ ": " ++ x.hours ]
                        )
                    )
                |> Maybe.map (\xs -> ul [ Styles.venueHours ] xs)
                |> Maybe.withDefault (p [] [ text "No hours listed" ])
    in
    div
        [ Styles.contentColumn ]
        [ h4
            [ Styles.venueHoursHeader ]
            [ text "Hours" ]
        , popular
        ]


rating : Venue.Model.Venue -> Html msg
rating venue =
    let
        rating =
            venue.rating
                |> Maybe.map
                    (\x ->
                        [ h4
                            [ Styles.venueRatingHeader ]
                            [ text "Rating" ]
                        , p
                            [ Styles.venueRating x ]
                            [ (text << toString) x ]
                        ]
                    )
                |> Maybe.withDefault []
    in
    div
        [ Styles.contentColumn ]
        rating


attributes : Venue.Model.Venue -> Html msg
attributes venue =
    let
        attrs =
            venue.attributes
                |> Maybe.map
                    (List.map
                        (\x ->
                            li [] [ text x ]
                        )
                    )
                |> Maybe.map
                    (\xs ->
                        if List.isEmpty xs then
                            []
                        else
                            [ h4
                                [ Styles.venueAttributesHeader ]
                                [ text "Attributes" ]
                            , ul
                                [ Styles.venueAttributes ]
                                xs
                            ]
                    )
                |> Maybe.withDefault []
    in
    div
        [ Styles.contentColumn ]
        attrs
