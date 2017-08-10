module Messages exposing (..)

import Geolocation as Geo
import Http
import Json.Decode as Json
import Models exposing (FullVenueData, VenueMarker)


type alias MarkerEvent =
    { event : String
    , lat : Float
    , lng : Float
    , targetId : Int
    }


type alias Coords =
    ( Float, Float )


type Msg
    = FetchVenues (Result Http.Error (List ( Coords, VenueMarker )))
    | GetLocation (Result Geo.Error Geo.Location)
    | OnVenueSelection (Result String MarkerEvent)
    | FetchVenueData (Result Http.Error FullVenueData)
    | NewMarker (Result String { id : Int, lat : Float, lng : Float })
