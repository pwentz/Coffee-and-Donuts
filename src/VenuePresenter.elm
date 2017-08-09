module VenuePresenter exposing (present)

import Html exposing (..)
import Html.Attributes exposing (..)
import Models exposing (Err(..), FullVenueData, Model(..))
import Public
import Styles
import Util
import Venues.View


present : Model -> Maybe (Venues.View.Model a)
present model =
    case model of
        Error err ->
            Just (Venues.View.Error err)

        Model model ->
            let
                venueView venue =
                    Venues.View.Venue
                        { banner = banner venue
                        , primaryInfo =
                            div
                                [ Styles.contentColumn ]
                                [ name venue
                                , location venue
                                ]
                        , hours = hours venue
                        , rating = rating venue
                        , attributes = attributes venue
                        }
            in
            Maybe.map venueView model.currentVenue


name : FullVenueData -> Html msg
name venue =
    h1
        [ Styles.venueHeader ]
        [ text venue.name ]


banner : FullVenueData -> Html msg
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


location : FullVenueData -> Html msg
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


hours : FullVenueData -> Html msg
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


rating : FullVenueData -> Html msg
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


attributes : FullVenueData -> Html msg
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
