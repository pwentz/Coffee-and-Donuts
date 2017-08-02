module MainTest exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, list, int, string)
import Json.Decode as Json
import Test exposing (..)
import Main exposing (..)
import Http


suite : Test
suite =
    describe "Main"
        [ describe "VenueDecoder"
            [ test "it can decode a venue" <|
                \_ ->
                    let
                        venue =
                            """
                { "venue" : {
                    "id" : "4e713390fa766da6339dc53f",
                    "name" : "Brooklyn Bridge Promenade",
                    "location" : {
                      "lat" : 40.69846219320118,
                      "lng" : -73.99670720100403
                    }
                } }
                """

                        decodedOutput =
                            Json.decodeString
                                (Json.at [ "venue" ] venueDecoder)
                                venue
                    in
                        Expect.equal decodedOutput
                            (Ok
                                { id = "4e713390fa766da6339dc53f"
                                , name = "Brooklyn Bridge Promenade"
                                , location =
                                    { lat = 40.69846219320118
                                    , lng = -73.99670720100403
                                    }
                                }
                            )
            ]

        -- , describe "FoursquareVenuesDecoder"
        --     [ test "it can decode a venue from within larger JSON response" <|
        --         \_ ->
        --             let
        --                 venue =
        --                     """
        --                     { "response" :
        --                         "groups" : [
        --                           { "type" : "Recommended Places",
        --                             "name" : "Recommended",
        --                             "items" : [
        --                               { "reasons" : { "count" : 0 },
        --                                 "venue" : {
        --                                     "id" : "4e713390fa766da6339dc53f",
        --                                     "name" : "Brooklyn Bridge Promenade",
        --                                     "location" : {
        --                                       "lat" : 40.69846219320118,
        --                                       "lng" : -73.99670720100403
        --                                     }
        --                                 },
        --                                 "tips" : []
        --                               }
        --                             ]
        --                           }
        --                          ]
        --                     }
        --                      """
        --                 decodedOutput =
        --                     Json.decodeString
        --                         foursquareVenuesDecoder
        --                         venue
        --             in
        --                 Expect.equal decodedOutput
        --                     (Ok
        --                         [ [ { id = "4e713390fa766da6339dc53f"
        --                             , name = "Brooklyn Bridge Promenade"
        --                             , location =
        --                                 { lat = 40.69846219320118
        --                                 , lng = -73.99670720100403
        --                                 }
        --                             }
        --                           ]
        --                         ]
        --                     )
        --     ]
        ]
