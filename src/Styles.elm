module Styles exposing (..)

import Css exposing (..)
import Html exposing (Attribute)
import Html.Attributes


styles cssPairs =
    asPairs cssPairs
        |> Html.Attributes.style


contentColumn : Attribute msg
contentColumn =
    styles
        [ float left
        , width (pct 25)
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
        , width (pct 75)
        , float right
        ]


mainHeader : Attribute msg
mainHeader =
    styles
        [ textAlign center
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
        ]


filler : Attribute msg
filler =
    styles
        [ height (vh 40)
        ]
