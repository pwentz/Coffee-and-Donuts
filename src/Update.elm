module Update exposing (..)

import Commands as C
import Dict
import Leaflet as L
import Messages exposing (..)
import Models exposing (AppData, Model(..))
import Public


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model of
        Model data ->
            updateModel msg data

        _ ->
            model ! []


updateModel : Msg -> AppData -> ( Model, Cmd Msg )
updateModel msg payload =
    case msg of
        FetchVenues (Ok venues) ->
            let
                updatedModel =
                    { payload
                        | shortVenues = List.concat venues
                    }
            in
            Model updatedModel ! [ C.populateMap updatedModel ]

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
                    { payload
                        | location =
                            { lat = location.latitude
                            , lng = location.longitude
                            }
                    }
            in
            Model updatedModel
                ! [ L.initMap mapData
                  , C.fetchVenues updatedModel
                  ]

        OnVenueSelection (Ok eventData) ->
            let
                hasMatchingCoords =
                    \marker ->
                        (marker.location.lat == eventData.lat)
                            && (marker.location.lng == eventData.lng)

                targetVenue =
                    payload.shortVenues
                        |> List.filter hasMatchingCoords
            in
            case targetVenue of
                [] ->
                    Model payload ! []

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
                            payload.leafletMarkers
                                |> List.map assignCurrentIcon
                    in
                    case Dict.get v.id payload.fullVenues of
                        Nothing ->
                            Model payload
                                ! [ L.updateIcons markers
                                  , C.fetchVenueData v.id
                                  ]

                        venue ->
                            Model { payload | currentVenue = venue } ! [ L.updateIcons markers ]

        FetchVenueData (Ok venueData) ->
            Model
                { payload
                    | currentVenue = Just venueData
                    , fullVenues = Dict.insert venueData.id venueData payload.fullVenues
                }
                ! []

        NewMarker (Ok id) ->
            Model { payload | leafletMarkers = id :: payload.leafletMarkers } ! []

        FetchVenueData (Err _) ->
            FetchVenueError ! []

        NewMarker (Err desc) ->
            LeafletError desc ! []

        OnVenueSelection (Err desc) ->
            LeafletError desc ! []

        FetchVenues (Err _) ->
            FetchVenuesError ! []

        GetLocation (Err _) ->
            GetLocationError ! []
