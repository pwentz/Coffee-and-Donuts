module Update exposing (update)

import Command.Actions as Actions
import Dict
import Error.Model as Err
import Leaflet as L
import Messages as Msg exposing (Msg)
import Models exposing (AppData, Coords, Model(..), VenueMarker)
import Public


type alias VenueMarkerOptions =
    { events : List L.MarkerEvent
    , display : String
    , venue : ( Coords, VenueMarker )
    }


update : ( Msg.Success, AppData ) -> ( Model, Cmd Msg )
update ( msg, payload ) =
    case msg of
        Msg.FetchVenues venues ->
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

        Msg.GetLocation location ->
            let
                currentLocation =
                    ( location.latitude, location.longitude )
            in
            Model { payload | location = currentLocation }
                ! [ L.initMap (L.defaultMap currentLocation "map")
                  , Actions.fetchVenues currentLocation
                  ]

        Msg.OnVenueSelection { lat, lng, targetId, event } ->
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
                                  , Actions.fetchVenueData targetVenue.venueId
                                  ]

                        venue ->
                            Model { payload | currentVenue = venue } ! [ L.updateIcons markers ]
            in
            payload.venueMarkers
                |> Dict.get ( lat, lng )
                |> Maybe.map applyVenueData
                |> Maybe.withDefault (Models.Error Err.FetchVenue ! [])

        Msg.FetchVenueData venueData ->
            Model
                { payload
                    | currentVenue = Just venueData
                    , fullVenues = Dict.insert venueData.id venueData payload.fullVenues
                }
                ! []

        Msg.NewMarker { id, lat, lng } ->
            let
                targetVenue =
                    payload.venueMarkers
                        |> Dict.get ( lat, lng )
            in
            case targetVenue of
                Nothing ->
                    Models.Error Err.FetchVenues ! []

                Just v ->
                    Model
                        { payload
                            | venueMarkers =
                                payload.venueMarkers
                                    |> Dict.insert ( lat, lng ) { v | markerId = Just id }
                        }
                        ! []
