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


filler : Attribute msg
filler =
    styles
        [ height (vh 40)
        ]
