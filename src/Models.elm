module Models exposing (..)

import Dict exposing (Dict)


type Model
    = FetchVenueError
    | GetLocationError
    | FetchVenuesError
    | LeafletError String
    | Model AppData


type alias AppData =
    { shortVenues : List ShortVenueData
    , fullVenues : Dict String FullVenueData
    , location :
        { lat : Float
        , lng : Float
        }
    , currentVenue : Maybe FullVenueData
    , leafletMarkers : List Int
    }


type alias ShortVenueData =
    { id : String
    , name : String
    , location :
        { lat : Float
        , lng : Float
        }
    }


type alias FullVenueData =
    { id : String
    , name : String
    , location : List String
    , phone : Maybe String
    , rating : Maybe Float
    , popular : Maybe (List { day : String, hours : String })
    , attributes : Maybe (List String)
    , bestPhoto :
        Maybe
            { prefix : String
            , suffix : String
            , width : Int
            , height : Int
            }
    }
