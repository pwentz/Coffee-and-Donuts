module Styles exposing (..)

import Css exposing (..)
import Html exposing (Attribute)
import Html.Attributes


cream : String
cream =
    "#FDF0CA"


lightBlue : String
lightBlue =
    "#8CE6F7"


pink : String
pink =
    "#DD6CB4"


lightBrown : String
lightBrown =
    "#E7AF75"


darkBrown : String
darkBrown =
    "#704F2E"


styles cssPairs =
    asPairs cssPairs
        |> Html.Attributes.style


contentColumn : Attribute msg
contentColumn =
    styles
        [ float left
        , width (pct 30)
        , textAlign center
        ]


map : Attribute msg
map =
    styles
        [ position absolute
        , top (em 0)
        , bottom (em 0)
        , left (em 0)
        , right (em 0)
        ]


mapWrapper : Attribute msg
mapWrapper =
    styles
        [ position relative
        , height (vh 90)
        , width (pct 70)
        , float right
        ]


mainHeader : Attribute msg
mainHeader =
    styles
        [ textAlign center
        , color (hex darkBrown)
        ]


venueHeader : Attribute msg
venueHeader =
    styles
        [ color (hex pink)
        ]


defaultContent : Attribute msg
defaultContent =
    styles
        [ textAlign center
        ]


venueBannerWrapper : Attribute msg
venueBannerWrapper =
    styles
        [ margin auto ]


venueBanner : Attribute msg
venueBanner =
    styles
        [ height (vh 20)
        , width (pct 95)
        ]


venueLocationData : Attribute msg
venueLocationData =
    styles
        [ textAlign center
        , listStyleType none
        , color (hex darkBrown)
        ]


venueAttributesHeader : Attribute msg
venueAttributesHeader =
    styles
        [ color (hex pink)
        ]


venueAttributes : Attribute msg
venueAttributes =
    styles
        [ listStyleType none
        , color (hex darkBrown)
        ]


venueHoursHeader : Attribute msg
venueHoursHeader =
    styles
        [ color (hex pink)
        ]


venueHours : Attribute msg
venueHours =
    styles
        [ listStyleType none
        , color (hex darkBrown)
        ]


venueRating : Float -> Attribute msg
venueRating rating =
    let
        ratingColor =
            if rating >= 7.0 then
                "#399321"
            else if rating >= 4.0 then
                darkBrown
            else
                "#B72539"
    in
    styles
        [ color (hex ratingColor)
        ]


venueRatingHeader : Attribute msg
venueRatingHeader =
    styles
        [ color (hex pink)
        ]


filler : Attribute msg
filler =
    styles
        [ height (vh 40)
        ]
