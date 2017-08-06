module Models exposing (..)


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
    , rating : Maybe Float
    , popular : Maybe (List { day : String, hours : String })
    , attributes : Maybe (List String)
    , bestPhoto : Maybe { prefix : String, suffix : String }
    }
