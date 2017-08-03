module Main exposing (..)

import Html exposing (..)
import Html.Events as Events
import Html.Attributes exposing (..)
import Json.Decode as Json
import Mapbox.Maps.SlippyMap as Mapbox
import Mapbox.Endpoint as Endpoint
import Http as Http
import Geolocation as Geo
import Task
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
    , location : ShortAddressData
    , waitingMsg : String
    }


init : ( Model, Cmd Msg )
init =
    ( { venues = []
      , waitingMsg = ""
      , location = { lat = 0.0, lng = 0.0 }
      }
    , getLocationAndFetchVenues
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
        , h5
            []
            [ text model.waitingMsg ]
        , div
            []
            [ embeddedSlippyMap ]
        ]



-- UPDATE


type Msg
    = FetchVenues (Result Http.Error (List (List ShortVenueData)))
    | GetLocation (Result Geo.Error Geo.Location)


getLocationAndFetchVenues : Cmd Msg
getLocationAndFetchVenues =
    Task.attempt GetLocation Geo.now


fetchVenues : Model -> Cmd Msg
fetchVenues model =
    let
        params =
            "?ll="
                ++ (toString model.location.lat)
                ++ ","
                ++ (toString model.location.lng)
                ++ "&client_id="
                ++ Secrets.foursquareClientId
                ++ "&client_secret="
                ++ Secrets.foursquareClientSecret
                ++ "&limit=10&v=20170701&m=foursquare&section=donuts&openNow=1"

        url =
            "https://api.foursquare.com/v2/venues/explore" ++ params

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
            ( { model
                | waitingMsg = "Something went wrong while we were getting venues!"
              }
            , Cmd.none
            )

        GetLocation (Err _) ->
            ( { model
                | waitingMsg = "We need your location for the app to function properly!"
              }
            , Cmd.none
            )

        GetLocation (Ok location) ->
            let
                updatedModel =
                    { model
                        | location =
                            { lat = location.latitude
                            , lng = location.longitude
                            }
                    }
            in
                ( updatedModel, (fetchVenues updatedModel) )
