module App.Update exposing (update)

import App.Model exposing (Coords, Model)
import App.Msg as Msg exposing (Msg)
import Command.Actions as Actions
import Dict
import Error.Model as Err
import Leaflet as L
import Public
import Tuple
import Venue.Model


type alias VenueMarkerOptions =
    { events : List L.MarkerEvent
    , display : String
    , venue : ( Coords, Venue.Model.Marker )
    }


update : ( Msg.Success, App.Model.Data ) -> ( Model, Cmd Msg )
update ( msg, { venueMarkers, fullVenues, location, currentVenue } as payload ) =
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
            App.Model.init { payload | venueMarkers = Dict.fromList venues }
                ! [ L.addMarkers <|
                        List.map toMarker venues
                  ]

        Msg.GetLocation location ->
            let
                currentLocation =
                    ( location.latitude, location.longitude )
            in
            App.Model.init { payload | location = currentLocation }
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
                            venueMarkers
                                |> Dict.values
                                |> List.filterMap .markerId
                                |> List.map assignCurrentIcon
                    in
                    case Dict.get (.venueId targetVenue) fullVenues of
                        Nothing ->
                            App.Model.init payload
                                ! [ L.updateIcons markers
                                  , Actions.fetchVenueData (.venueId targetVenue)
                                  ]

                        venue ->
                            App.Model.init { payload | currentVenue = venue } ! [ L.updateIcons markers ]
            in
            venueMarkers
                |> Dict.get ( lat, lng )
                |> Maybe.map applyVenueData
                |> Maybe.withDefault (App.Model.initWithError Err.FetchVenue ! [])

        Msg.FetchVenueData venueData ->
            App.Model.init
                { payload
                    | currentVenue = Just venueData
                    , fullVenues = Dict.insert (.id venueData) venueData (.fullVenues payload)
                }
                ! []

        Msg.NewMarker { id, lat, lng } ->
            let
                updateWithId venue =
                    App.Model.init
                        { payload
                            | venueMarkers =
                                venueMarkers
                                    |> Dict.insert ( lat, lng ) { venue | markerId = Just id }
                        }
                        ! []
            in
            Dict.get ( lat, lng ) venueMarkers
                |> Maybe.map updateWithId
                |> Maybe.withDefault
                    (App.Model.initWithError Err.FetchVenues ! [])
