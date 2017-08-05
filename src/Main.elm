module Main exposing (..)

import Html exposing (..)
import Html.Events as Events
import Html.Attributes exposing (..)
import Json.Decode as Json
import Json.Encode exposing (Value)
import Http as Http
import Geolocation as Geo
import Task
import Public
import Secrets
import Leaflet as L


main =
    program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
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
            (Json.decodeValue
                (Json.map3
                    (\e lat lng -> { event = e, lat = lat, lng = lng })
                    (Json.field "event" Json.string)
                    (Json.field "lat" Json.float)
                    (Json.field "lng" Json.float)
                )
                val
            )
    in
        case didGoThrough of
            Ok eventData ->
                OnMarkerClick eventData

            Err _ ->
                UpdateMessage "It failed!"



-- MODEL


type alias ShortVenueData =
    { id : String
    , name : String
    , location :
        { lat : Float
        , lng : Float
        }
    }


type alias Model =
    { venues : List ShortVenueData
    , location :
        { lat : Float
        , lng : Float
        }
    , waitingMsg : String
    , currentVenue : Maybe FullVenueData
    }


type alias FullVenueData =
    { name : String
    , location : List String
    , rating : Float
    , hours : String
    , popular : List { day : String, hours : String }
    , attributes : List String
    , bestPhoto : { prefix : String, suffix : String }
    }


init : ( Model, Cmd Msg )
init =
    ( { venues = []
      , waitingMsg = ""
      , location = { lat = 0.0, lng = 0.0 }
      , currentVenue = Nothing
      }
    , getLocation
    )


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
            (Json.map2
                (\lat lng -> { lat = lat, lng = lng })
                (Json.field "lat" Json.float)
                (Json.field "lng" Json.float)
            )
        )


fullVenueDecoder =
    Json.map7
        FullVenueData
        (Json.field "name" Json.string)
        (Json.field "location"
            (Json.field "formattedAddress" (Json.list Json.string))
        )
        (Json.field "rating" Json.float)
        (Json.at [ "hours", "status" ] Json.string)
        (Json.at [ "popular", "timeframes" ]
            (Json.list
                (Json.map2
                    (\day times ->
                        { day = day
                        , hours = (Maybe.withDefault "Not Listed" << List.head) times
                        }
                    )
                    (Json.field "days" Json.string)
                    (Json.field "open"
                        (Json.list (Json.field "renderedTime" Json.string))
                    )
                )
            )
        )
        (Json.at [ "attributes", "groups" ]
            (Json.list (Json.field "name" Json.string))
        )
        (Json.field "bestPhoto"
            (Json.map2 (\pre suff -> { prefix = pre, suffix = suff })
                (Json.field "prefix" Json.string)
                (Json.field "suffix" Json.string)
            )
        )



-- VIEW


view : Model -> Html msg
view model =
    div
        []
        [ h2
            []
            [ text "Coffee & Donuts" ]
        , h5
            []
            [ text model.waitingMsg ]
        , div
            [ id "map"
            , style [ ( "height", "500px" ) ]
            ]
            []
        ]



-- UPDATE


type Msg
    = FetchVenues (Result Http.Error (List (List ShortVenueData)))
    | GetLocation (Result Geo.Error Geo.Location)
    | StartFetchingVenues
    | UpdateMessage String
    | OnMarkerClick { event : String, lat : Float, lng : Float }
    | FetchVenueData (Result Http.Error FullVenueData)


getLocation : Cmd Msg
getLocation =
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
            Http.get url (Json.at [ "response", "venue" ] fullVenueDecoder)
    in
        Http.send FetchVenueData request


populateMap : Model -> Cmd Msg
populateMap model =
    let
        venueMarkerData =
            (\x ->
                { lat = x.location.lat
                , lng = x.location.lng
                , icon = Nothing
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
            )

        venueMarkers =
            List.map venueMarkerData model.venues
    in
        L.addMarkers venueMarkers


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StartFetchingVenues ->
            ( model, fetchVenues model )

        FetchVenues (Ok venues) ->
            let
                updatedModel =
                    { model
                        | venues = List.concat venues
                    }
            in
                ( updatedModel
                , populateMap updatedModel
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
                mapData =
                    { divId = "map"
                    , lat = location.latitude
                    , lng = location.longitude
                    , zoom = 16
                    , tileLayer = "https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=" ++ Public.mapboxToken
                    , tileLayerOptions =
                        { attribution = ""
                        , maxZoom = 22
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
                ( updatedModel, (L.initMap mapData) )

        UpdateMessage str ->
            ( { model | waitingMsg = str }, Cmd.none )

        OnMarkerClick eventData ->
            let
                hasMatchingCoords =
                    (\marker ->
                        (marker.location.lat == eventData.lat)
                            && (marker.location.lng == eventData.lng)
                    )

                targetMarker =
                    model.venues
                        |> List.filter hasMatchingCoords
            in
                case targetMarker of
                    [] ->
                        ( { model | waitingMsg = "Couldn't find target marker" }, Cmd.none )

                    x :: _ ->
                        ( model, (fetchVenueData x.id) )

        FetchVenueData (Ok venueData) ->
            ( { model | currentVenue = Just venueData }, Cmd.none )

        FetchVenueData (Err _) ->
            ( { model | waitingMsg = "Something went wrong getting venue" }, Cmd.none )
