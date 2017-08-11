module Error.View exposing (ViewResult, apply, present)

import Error.Model as Err exposing (Err)
import Html exposing (..)
import Models exposing (AppData, Model)


type ViewResult msg
    = Successful AppData
    | Failure (Html msg)


apply : (AppData -> Html a) -> ViewResult a -> Html a
apply f viewResult =
    case viewResult of
        Failure errorView ->
            errorView

        Successful data ->
            f data


present : Model -> ViewResult msg
present model =
    case model of
        Models.Error err ->
            Failure (view err)

        Models.Model appData ->
            Successful appData


view : Err -> Html msg
view err =
    let
        toRender =
            p [] [ text "Oh no!" ]
    in
    case err of
        Err.FetchVenue ->
            toRender

        Err.GetLocation ->
            toRender

        Err.FetchVenues ->
            toRender

        Err.Leaflet _ ->
            toRender
