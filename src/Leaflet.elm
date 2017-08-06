port module Leaflet exposing (..)

import Json.Encode exposing (Value)


type alias Icon =
    { url : String
    , size : { height : Int, width : Int }
    }


type alias Marker =
    { id : Int
    , lat : Float
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
        { attribution : String
        , maxZoom : Int
        , id : String
        , accessToken : String
        }
    }


port initMap : MapData -> Cmd msg


port addMarker : Marker -> Cmd msg


port addMarkers : List Marker -> Cmd msg


port onMapCreation : (Value -> msg) -> Sub msg


port onMarkerEvent : (Value -> msg) -> Sub msg
