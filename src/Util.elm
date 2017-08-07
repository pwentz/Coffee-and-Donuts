module Util exposing (..)


formatPhoneNumber : String -> String
formatPhoneNumber phoneNumber =
    "("
        ++ String.left 3 phoneNumber
        ++ ")"
        ++ " "
        ++ (String.dropRight 4 << String.dropLeft 3) phoneNumber
        ++ "-"
        ++ String.right 4 phoneNumber
