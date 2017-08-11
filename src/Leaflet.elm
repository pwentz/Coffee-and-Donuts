port module Leaflet exposing (..)

import App.Model exposing (Coords)
import Json.Encode exposing (Value)
import Public
import Tuple
import Venue.Model


type alias Icon =
    { url : String
    , size : { height : Int, width : Int }
    }


type alias Marker =
    { lat : Float
    , lng : Float
    , icon : Maybe Icon
    , draggable : Bool
    , popup : Maybe String
    , events : List MarkerEvent
    }


type alias MarkerEvent =
    { event : String
    , action : Maybe String
    , subscribe : Bool
    }


type alias MapData =
    { divId : String
    , lat : Float
    , lng : Float
    , zoom : Int
    , tileLayer : String
    , tileLayerOptions :
        { maxZoom : Int
        , id : String
        , accessToken : String
        }
    }


port initMap : MapData -> Cmd msg


port addMarker : Marker -> Cmd msg


port updateIcon : { id : Int, icon : Icon } -> Cmd msg


port updateIcons : List { id : Int, icon : Icon } -> Cmd msg


port addMarkers : List Marker -> Cmd msg


port onMarkerCreation : (Value -> msg) -> Sub msg


port onMarkerEvent : (Value -> msg) -> Sub msg


defaultMap : Coords -> String -> MapData
defaultMap ( lat, lng ) mapId =
    { divId = mapId
    , lat = lat
    , lng = lng
    , zoom = 17
    , tileLayer = "https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=" ++ Public.mapboxToken
    , tileLayerOptions =
        { maxZoom = 24
        , id = "mapbox.streets"
        , accessToken = Public.mapboxToken
        }
    }


defaultMarker : { venue : ( Coords, Venue.Model.Marker ), events : List MarkerEvent, display : String } -> Marker
defaultMarker { venue, events, display } =
    { lat = (Tuple.first << Tuple.first) venue
    , lng = (Tuple.second << Tuple.first) venue
    , icon = Just (icon display)
    , draggable = False
    , popup = Just <| (.name << Tuple.second) venue
    , events = events
    }


icon : String -> Icon
icon iconUrl =
    { url = iconUrl
    , size = { height = 35, width = 35 }
    }
