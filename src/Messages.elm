module Messages exposing (..)

import Geolocation as Geo
import Http
import Models exposing (FullVenueData, ShortVenueData)


type Msg
    = FetchVenues (Result Http.Error (List (List ShortVenueData)))
    | GetLocation (Result Geo.Error Geo.Location)
    | UpdateMessage String
    | OnVenueSelection
        { event : String
        , lat : Float
        , lng : Float
        , targetId : Int
        }
    | FetchVenueData (Result Http.Error FullVenueData)
    | NewMarker Int
