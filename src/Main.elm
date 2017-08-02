module Main exposing (..)

import Html exposing (..)
import Html.Events as Events
import Html.Attributes exposing (..)
import Json.Decode as Json
import Mapbox.Maps.SlippyMap as Mapbox
import Mapbox.Endpoint as Endpoint
import Http as Http
import Secrets


main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MODEL


type alias ShortVenueData =
    { id : String
    , name : String
    , location : ShortAddressData
    }


type alias ShortAddressData =
    { lat : Float
    , lng : Float
    }


type alias Model =
    { venues : List ShortVenueData
    }


init : ( Model, Cmd Msg )
init =
    ( { venues = [] }
    , fetchVenues
    )


embeddedSlippyMap : Html msg
embeddedSlippyMap =
    Mapbox.slippyMap Endpoint.streets Secrets.mapboxToken Nothing Nothing (Mapbox.Size 1000 1000)


foursquareVenuesDecoder =
    Json.at [ "response", "groups" ]
        (Json.list
            (Json.at [ "items" ]
                (Json.list (Json.field "venue" venueDecoder))
            )
        )


venueDecoder =
    Json.map3
        ShortVenueData
        (Json.field "id" Json.string)
        (Json.field "name" Json.string)
        (Json.field "location"
            (Json.map2 ShortAddressData
                (Json.field "lat" Json.float)
                (Json.field "lng" Json.float)
            )
        )



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
    = FetchVenues (Result Http.Error (List (List ShortVenueData)))


foursquareParams : String
foursquareParams =
    "?ll=40.7,-74&client_id="
        ++ Secrets.foursquareClientId
        ++ "&client_secret="
        ++ Secrets.foursquareClientSecret
        ++ "&limit=10&v=20170701&m=foursquare&section=donuts&openNow=1"


fetchVenues : Cmd Msg
fetchVenues =
    let
        url =
            "https://api.foursquare.com/v2/venues/explore" ++ foursquareParams

        request =
            Http.get url foursquareVenuesDecoder
    in
        Http.send FetchVenues request


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchVenues (Ok venues) ->
            ( { model
                | venues = List.concat venues
              }
            , Cmd.none
            )

        FetchVenues (Err _) ->
            ( model, Cmd.none )
