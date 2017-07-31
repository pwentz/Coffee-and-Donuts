module Main exposing (..)

import Html exposing (..)
import Html.Events as Events
import Html.Attributes exposing (..)
import Mapbox.Maps.SlippyMap as Mapbox
import Mapbox.Endpoint as Endpoint


main =
    beginnerProgram
        { model = initialModel
        , view = view
        , update = update
        }



-- MODEL


type alias Model =
    { nothing : String
    }


initialModel : Model
initialModel =
    { nothing = ""
    }


mapboxToken : String
mapboxToken =
    "pk.eyJ1IjoicHdlbnR6IiwiYSI6ImNpdHp1bWNwdzBmeWUybm82czM5dXJrbmgifQ.9VjnHsAL0MgpDCDPrJou0A"


embeddedSlippyMap : Html msg
embeddedSlippyMap =
    Mapbox.slippyMap Endpoint.streets mapboxToken Nothing Nothing (Mapbox.Size 1000 1000)



-- VIEW


view : Model -> Html msg
view model =
    div
        []
        [ h1
            []
            [ text "Coffee & Donuts" ]
        , div
            []
            [ embeddedSlippyMap ]
        ]



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model
