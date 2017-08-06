module DecodersTest exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, list, int, string)
import Json.Decode as Json
import Test exposing (..)
import Decoders exposing (..)
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
        , describe "FullVenueDecoder"
            [ test "it decodes large venue data" <|
                \_ ->
                    let
                        venue =
                            """
                        { "venue" : {
                            "id" : "4e713390fa766da6339dc53f",
                            "name" : "Brooklyn Bridge Promenade",
                            "location" : {
                              "formattedAddress" : [
                                "337 E Randolph Dr (btwn Lake Shore Dr & Columbus Dr)",
                                "Chicago, IL 60601"
                              ],
                              "lat" : 40.69846219320118,
                              "lng" : -73.99670720100403
                            },
                            "url" : "http://www.chicagoparkdistrict.com/parks/maggie-daley-park/",
                            "rating" : 9.2,
                            "popular" : {
                              "isOpen" : false,
                              "timeframes" : [
                                { "days" : "today",
                                  "open" : [
                                    { "renderedTime" : "9:00 AM-8:00 PM" }
                                  ]
                                },
                                { "days" : "Tues",
                                  "open" : [
                                    { "renderedTime" : "6:00 AM-3:00 PM" }
                                  ]
                                }
                              ]
                            },
                            "attributes" : {
                              "groups" : [
                                  { "type" : "outdoorSeating",
                                    "name" : "Outdoor Seating"
                                  }
                              ]
                            },
                            "bestPhoto" : {
                              "id" : "12345",
                              "prefix" : "https://something/img/",
                              "suffix" : "/1234/stuff.jpg",
                              "width" : 640,
                              "height" : 640
                            }
                        } }
                        """

                        decodedValue =
                            Json.decodeString
                                (Json.at [ "venue" ] fullVenueDecoder)
                                venue

                        expected =
                            { id = "4e713390fa766da6339dc53f"
                            , name = "Brooklyn Bridge Promenade"
                            , location =
                                [ "337 E Randolph Dr (btwn Lake Shore Dr & Columbus Dr)"
                                , "Chicago, IL 60601"
                                ]
                            , rating = Just 9.2
                            , popular =
                                (Just
                                    [ { day = "today"
                                      , hours = "9:00 AM-8:00 PM"
                                      }
                                    , { day = "Tues"
                                      , hours = "6:00 AM-3:00 PM"
                                      }
                                    ]
                                )
                            , attributes =
                                Just [ "Outdoor Seating" ]
                            , bestPhoto =
                                Just
                                    { prefix = "https://something/img/"
                                    , suffix = "/1234/stuff.jpg"
                                    , width = 640
                                    , height = 640
                                    }
                            }
                    in
                        case decodedValue of
                            Ok val ->
                                Expect.equal val expected

                            Err msg ->
                                Expect.fail msg
            , test "it can account for missing data" <|
                \_ ->
                    let
                        venue =
                            """
                          { "venue" : {
                              "id" : "4e713390fa766da6339dc53f",
                              "name" : "Brooklyn Bridge Promenade",
                              "location" : {
                                "formattedAddress" : [
                                  "337 E Randolph Dr (btwn Lake Shore Dr & Columbus Dr)",
                                  "Chicago, IL 60601"
                                ],
                                "lat" : 40.69846219320118,
                                "lng" : -73.99670720100403
                              },
                              "url" : "http://www.chicagoparkdistrict.com/parks/maggie-daley-park/"
                          } }
                          """

                        decodedValue =
                            Json.decodeString
                                (Json.at [ "venue" ] fullVenueDecoder)
                                venue

                        expected =
                            { id = "4e713390fa766da6339dc53f"
                            , name = "Brooklyn Bridge Promenade"
                            , location =
                                [ "337 E Randolph Dr (btwn Lake Shore Dr & Columbus Dr)"
                                , "Chicago, IL 60601"
                                ]
                            , rating = Nothing
                            , popular = Nothing
                            , attributes = Nothing
                            , bestPhoto = Nothing
                            }
                    in
                        case decodedValue of
                            Ok val ->
                                Expect.equal val expected

                            Err msg ->
                                Expect.fail msg
            ]
        ]
