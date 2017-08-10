module Models exposing (..)

import Dict exposing (Dict)


type Err
    = FetchVenue
    | GetLocation
    | FetchVenues
    | Leaflet String


type Model
    = Error Err
    | Model AppData


type alias Coords =
    ( Float, Float )


type alias AppData =
    { venueMarkers : Dict Coords VenueMarker
    , fullVenues : Dict String FullVenueData
    , location : Coords
    , currentVenue : Maybe FullVenueData
    }


type alias VenueMarker =
    { venueId : String
    , markerId : Maybe Int
    , name : String
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
