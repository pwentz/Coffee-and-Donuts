module Error.View exposing (ViewResult, apply, present)

import App.Model exposing (Model)
import Error.Model as Err exposing (Err)
import Html exposing (..)


type ViewResult msg
    = Successful App.Model.Data
    | Failure (Html msg)


apply : (App.Model.Data -> Html a) -> ViewResult a -> Html a
apply f viewResult =
    case viewResult of
        Failure errorView ->
            errorView

        Successful data ->
            f data


present : Model -> ViewResult msg
present model =
    App.Model.applyWithDefault Successful (Failure << view) model


view : Err -> Html msg
view err =
    let
        toRender msg =
            p [] [ text msg ]
    in
    case err of
        Err.FetchVenue ->
            toRender "Something went wrong while fetching this venue!"

        Err.GetLocation ->
            toRender "Must enable location!"

        Err.FetchVenues ->
            toRender "Something went wrong while fetching venues!"

        Err.Leaflet msg ->
            toRender msg
