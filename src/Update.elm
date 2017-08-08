module Update exposing (..)

import Commands as C
import Dict
import Leaflet as L
import Messages exposing (..)
import Models exposing (Model)
import Public


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchVenues (Ok venues) ->
            let
                updatedModel =
                    { model
                        | shortVenues = List.concat venues
                    }
            in
            updatedModel ! [ C.populateMap updatedModel ]

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
                    , zoom = 17
                    , tileLayer = "https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=" ++ Public.mapboxToken
                    , tileLayerOptions =
                        { maxZoom = 24
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
            updatedModel
                ! [ L.initMap mapData
                  , C.fetchVenues updatedModel
                  ]

        UpdateMessage str ->
            { model | waitingMsg = str } ! []

        OnMarkerEvent eventData ->
            let
                hasMatchingCoords =
                    \marker ->
                        (marker.location.lat == eventData.lat)
                            && (marker.location.lng == eventData.lng)

                targetVenue =
                    model.shortVenues
                        |> List.filter hasMatchingCoords
            in
            case targetVenue of
                [] ->
                    { model | waitingMsg = "Couldn't find target venue" } ! []

                v :: _ ->
                    let
                        assignCurrentIcon markerId =
                            let
                                iconUrl =
                                    if markerId == eventData.targetId then
                                        Public.currentVenueIcon
                                    else
                                        Public.markerIcon
                            in
                            { id = markerId
                            , icon =
                                { url = iconUrl
                                , size = { height = 35, width = 35 }
                                }
                            }

                        markers =
                            model.leafletMarkers
                                |> List.map assignCurrentIcon
                    in
                    case Dict.get v.id model.fullVenues of
                        Nothing ->
                            model
                                ! [ L.updateIcons markers
                                  , C.fetchVenueData v.id
                                  ]

                        venue ->
                            { model | currentVenue = venue } ! [ L.updateIcons markers ]

        FetchVenueData (Ok venueData) ->
            { model
                | currentVenue = Just venueData
                , fullVenues = Dict.insert venueData.id venueData model.fullVenues
            }
                ! []

        FetchVenueData (Err _) ->
            { model | waitingMsg = "Something went wrong getting venue" } ! []

        NewMarker id ->
            { model | leafletMarkers = id :: model.leafletMarkers } ! []
