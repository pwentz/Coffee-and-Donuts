module Models exposing (..)

import Dict exposing (Dict)


type alias Model =
    { shortVenues : List ShortVenueData
    , fullVenues : Dict String FullVenueData
    , location :
        { lat : Float
        , lng : Float
        }
    , waitingMsg : String
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
