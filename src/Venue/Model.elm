module Venue.Model exposing (..)


type alias Marker =
    { venueId : String
    , markerId : Maybe Int
    , name : String
    }


type alias Venue =
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
