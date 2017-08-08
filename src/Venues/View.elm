module Venues.View exposing (..)


type Model
    = FetchVenuesError
    | GetLocationError
    | FetchVenueError
    | VenueData
        { shortVenues : List ShortVenueData
        , fullVenues : Dict String FullVenueData
        , leafletMarkers : List Int
        , location :
            { lat : Float
            , lng : Float
            }
        }
