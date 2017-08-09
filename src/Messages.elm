module Messages exposing (..)

import Geolocation as Geo
import Http
import Json.Decode as Json
import Models exposing (FullVenueData, ShortVenueData)


type alias VenueEvent =
    { event : String
    , lat : Float
    , lng : Float
    , targetId : Int
    }


type Msg
    = FetchVenues (Result Http.Error (List (List ShortVenueData)))
    | GetLocation (Result Geo.Error Geo.Location)
    | OnVenueSelection (Result String VenueEvent)
    | FetchVenueData (Result Http.Error FullVenueData)
    | NewMarker (Result String Int)
