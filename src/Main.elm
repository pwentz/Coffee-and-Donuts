module Main exposing (..)

import Decoders as Decode
import Dict exposing (Dict)
import Geolocation as Geo
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events
import Http as Http
import Json.Decode as Json
import Json.Encode exposing (Value)
import Leaflet as L
import Models exposing (FullVenueData, ShortVenueData)
import Public
import Random
import Secrets
import Styles
import Task
import Tuple
import VenuePresenter as Present


main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { shortVenues : List ShortVenueData
    , fullVenues : Dict String FullVenueData
    , location :
        { lat : Float
        , lng : Float
        }
    , waitingMsg : String
    , currentVenue : Maybe FullVenueData
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ L.onMapCreation decodeOnMapCreation
        , L.onMarkerEvent decodeMarkerEvent
        ]


decodeOnMapCreation : Value -> Msg
decodeOnMapCreation val =
    let
        result =
            Json.decodeValue Json.bool val
    in
    case result of
        Ok _ ->
            StartFetchingVenues

        Err _ ->
            UpdateMessage "Something went wrong creating your map!"


decodeMarkerEvent : Value -> Msg
decodeMarkerEvent val =
    let
        didGoThrough =
            Json.decodeValue
                (Json.map3
                    (\e lat lng -> { event = e, lat = lat, lng = lng })
                    (Json.field "event" Json.string)
                    (Json.field "lat" Json.float)
                    (Json.field "lng" Json.float)
                )
                val
    in
    case didGoThrough of
        Ok eventData ->
            OnMarkerEvent eventData

        Err _ ->
            UpdateMessage "It failed!"



-- MODEL


init : ( Model, Cmd Msg )
init =
    { shortVenues = []
    , fullVenues = Dict.empty
    , waitingMsg = ""
    , location = { lat = 0.0, lng = 0.0 }
    , currentVenue = Nothing
    }
        ! [ getLocation ]



-- VIEW


contentRow : Model -> Html msg
contentRow model =
    case model.currentVenue of
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
                , h4
                    []
                    [ text model.waitingMsg ]
                ]

        Just venue ->
            div
                [ Styles.contentRow ]
                [ Present.banner venue
                , div
                    [ Styles.contentColumn ]
                    [ Present.name venue
                    , Present.location venue
                    ]
                , Present.hours venue
                , Present.rating venue
                , Present.attributes venue
                ]


view : Model -> Html msg
view model =
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
            , contentRow model
            ]
        ]



-- UPDATE


type Msg
    = FetchVenues (Result Http.Error (List (List ShortVenueData)))
    | GetLocation (Result Geo.Error Geo.Location)
    | StartFetchingVenues
    | UpdateMessage String
    | OnMarkerEvent { event : String, lat : Float, lng : Float }
    | FetchVenueData (Result Http.Error FullVenueData)


getLocation : Cmd Msg
getLocation =
    Task.attempt GetLocation Geo.now


fetchVenues : Model -> Cmd Msg
fetchVenues model =
    let
        params =
            "?ll="
                ++ toString model.location.lat
                ++ ","
                ++ toString model.location.lng
                ++ "&client_id="
                ++ Secrets.foursquareClientId
                ++ "&client_secret="
                ++ Secrets.foursquareClientSecret
                ++ "&limit=10&v=20170701&m=foursquare&section=donuts&openNow=1"

        url =
            "https://api.foursquare.com/v2/venues/explore" ++ params

        request =
            Http.get url Decode.foursquareVenuesDecoder
    in
    Http.send FetchVenues request


fetchVenueData : String -> Cmd Msg
fetchVenueData venueId =
    let
        params =
            "?client_id="
                ++ Secrets.foursquareClientId
                ++ "&client_secret="
                ++ Secrets.foursquareClientSecret
                ++ "&v=20170701&m=foursquare"

        url =
            "https://api.foursquare.com/v2/venues/" ++ venueId ++ params

        request =
            Http.get url (Json.at [ "response", "venue" ] Decode.fullVenueDecoder)
    in
    Http.send FetchVenueData request


populateMap : Model -> Cmd Msg
populateMap model =
    let
        random =
            Random.initialSeed 0
                |> Random.step (Random.int 0 Random.maxInt)

        icon =
            { url = Public.venueIcon
            , size = { height = 35, width = 35 }
            }

        venueMarkerData =
            \x ( ( id, seed ), markers ) ->
                ( Random.step (Random.int 0 Random.maxInt) seed
                , { id = id
                  , lat = x.location.lat
                  , lng = x.location.lng
                  , icon = Just icon
                  , draggable = False
                  , popup = Just x.name
                  , events =
                        [ { event = "mouseover"
                          , action = Just "openPopup"
                          , subscribe = False
                          }
                        , { event = "click"
                          , action = Nothing
                          , subscribe = True
                          }
                        ]
                  }
                    :: markers
                )

        venueMarkers =
            model.shortVenues
                |> List.foldr venueMarkerData ( random, [] )
                |> Tuple.second
    in
    L.addMarkers venueMarkers


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StartFetchingVenues ->
            model ! [ fetchVenues model ]

        FetchVenues (Ok venues) ->
            let
                updatedModel =
                    { model
                        | shortVenues = List.concat venues
                    }
            in
            updatedModel ! [ populateMap updatedModel ]

        FetchVenues (Err _) ->
            { model
                | waitingMsg = "Something went wrong while we were getting venues!"
            }
                ! []

        GetLocation (Err _) ->
            { model
                | waitingMsg = "We need your location for the app to function properly!"
            }
                ! []

        GetLocation (Ok location) ->
            let
                mapData =
                    { divId = "map"
                    , lat = location.latitude
                    , lng = location.longitude
                    , zoom = 16
                    , tileLayer = "https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=" ++ Public.mapboxToken
                    , tileLayerOptions =
                        { maxZoom = 22
                        , id = "mapbox.streets"
                        , accessToken = Public.mapboxToken
                        }
                    }

                updatedModel =
                    { model
                        | location =
                            { lat = location.latitude
                            , lng = location.longitude
                            }
                    }
            in
            updatedModel ! [ L.initMap mapData ]

        UpdateMessage str ->
            { model | waitingMsg = str } ! []

        OnMarkerEvent eventData ->
            let
                hasMatchingCoords =
                    \marker ->
                        (marker.location.lat == eventData.lat)
                            && (marker.location.lng == eventData.lng)

                targetMarker =
                    model.shortVenues
                        |> List.filter hasMatchingCoords
            in
            case targetMarker of
                [] ->
                    { model | waitingMsg = "Couldn't find target marker" } ! []

                v :: _ ->
                    case Dict.get v.id model.fullVenues of
                        Nothing ->
                            model ! [ fetchVenueData v.id ]

                        venue ->
                            { model | currentVenue = venue } ! []

        FetchVenueData (Ok venueData) ->
            { model
                | currentVenue = Just venueData
                , fullVenues = Dict.insert venueData.id venueData model.fullVenues
            }
                ! []

        FetchVenueData (Err _) ->
            { model | waitingMsg = "Something went wrong getting venue" } ! []
