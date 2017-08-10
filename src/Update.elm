module Update exposing (..)

import Commands as C
import Dict
import Leaflet as L
import Messages as Msg exposing (Msg)
import Models exposing (AppData, Coords, Err(..), Model(..), VenueMarker)
import Public
import Tuple


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model of
        Model data ->
            updateModel msg data

        _ ->
            model ! []


type alias VenueMarkerOptions =
    { events : List L.MarkerEvent
    , display : String
    , venue : ( Coords, VenueMarker )
    }


updateModel : Msg -> AppData -> ( Model, Cmd Msg )
updateModel msg payload =
    case msg of
        Msg.FetchVenues (Ok venues) ->
            let
                markerEvents =
                    [ { event = "mouseover"
                      , action = Just "openPopup"
                      , subscribe = False
                      }
                    , { event = "click"
                      , action = Nothing
                      , subscribe = True
                      }
                    ]

                toMarker =
                    L.defaultMarker
                        << VenueMarkerOptions markerEvents Public.markerIcon
            in
            Model { payload | venueMarkers = Dict.fromList venues }
                ! [ L.addMarkers <|
                        List.map toMarker venues
                  ]

        Msg.GetLocation (Ok location) ->
            let
                currentLocation =
                    ( location.latitude, location.longitude )
            in
            Model { payload | location = currentLocation }
                ! [ L.initMap (L.defaultMap currentLocation "map")
                  , C.fetchVenues currentLocation
                  ]

        Msg.OnVenueSelection (Ok { lat, lng, targetId, event }) ->
            let
                applyVenueData targetVenue =
                    let
                        assignCurrentIcon markerId =
                            { id = markerId
                            , icon =
                                L.icon
                                    (if markerId == targetId then
                                        Public.currentVenueIcon
                                     else
                                        Public.markerIcon
                                    )
                            }

                        markers =
                            payload.venueMarkers
                                |> Dict.values
                                |> List.filterMap .markerId
                                |> List.map assignCurrentIcon
                    in
                    case Dict.get targetVenue.venueId payload.fullVenues of
                        Nothing ->
                            Model payload
                                ! [ L.updateIcons markers
                                  , C.fetchVenueData targetVenue.venueId
                                  ]

                        venue ->
                            Model { payload | currentVenue = venue } ! [ L.updateIcons markers ]
            in
            payload.venueMarkers
                |> Dict.get ( lat, lng )
                |> Maybe.map applyVenueData
                |> Maybe.withDefault (Models.Error FetchVenue ! [])

        Msg.FetchVenueData (Ok venueData) ->
            Model
                { payload
                    | currentVenue = Just venueData
                    , fullVenues = Dict.insert venueData.id venueData payload.fullVenues
                }
                ! []

        Msg.NewMarker (Ok { id, lat, lng }) ->
            let
                targetVenue =
                    payload.venueMarkers
                        |> Dict.get ( lat, lng )
            in
            case targetVenue of
                Nothing ->
                    Models.Error Models.FetchVenues ! []

                Just v ->
                    Model
                        { payload
                            | venueMarkers =
                                payload.venueMarkers
                                    |> Dict.insert ( lat, lng ) { v | markerId = Just id }
                        }
                        ! []

        Msg.FetchVenueData (Err _) ->
            Models.Error Models.FetchVenue ! []

        Msg.NewMarker (Err desc) ->
            Models.Error (Leaflet desc) ! []

        Msg.OnVenueSelection (Err desc) ->
            Models.Error (Leaflet desc) ! []

        Msg.FetchVenues (Err _) ->
            Models.Error Models.FetchVenues ! []

        Msg.GetLocation (Err _) ->
            Models.Error Models.GetLocation ! []
