module Option.DecodersAndEncoders exposing (suite)

import Expect
import Json.Decode
import Option
    exposing
        ( decoder
        , newOption
        , newSelectedOption
        , optionsDecoder
        )
import Test exposing (Test, describe, test)


simpleOptionWithJustLabelAndValue =
    """{"label": "Sup", "value": "Sup"}"""


simpleSelectedOption =
    """{"label": "Sup", "value": "Sup", "selected": "true"}"""


simpleNotSelectedOption =
    """{"label": "Sup", "value": "Sup", "selected": "false"}"""


listOfOptions =
    """[
        {"label": "one", "value": "1", "selected": "false"},
        {"label": "two", "value": "2"},
        {"label": "three", "value": "3", "selected": "true"}]"""


listOfOptionsWithDescriptions =
    """[
        {"label": "straw", "value": "1", "selected": "false", "description": "👒"},
        {"label": "sticks", "value": "2", "description": "🌳"},
        {"label": "bricks", "value": "3", "selected": "true", "description": "🧱"}]
    """


listOfOptionsWithGroups =
    """[
        {"label": "straw", "value": "1", "selected": "false", "group": "Building Material"},
        {"label": "sticks", "value": "2", "group": "Building Material"},
        {"label": "bricks", "value": "3", "selected": "true", "group": "Building Material"}]
    """


suite : Test
suite =
    describe "The Option modules"
        [ describe "decoding"
            [ test "an option with just a label and value" <|
                \_ ->
                    Expect.equal
                        (Ok (newOption "Sup"))
                        (Json.Decode.decodeString decoder simpleOptionWithJustLabelAndValue)
            , test "an option that's selected" <|
                \_ ->
                    Expect.equal
                        (Ok (newSelectedOption "Sup"))
                        (Json.Decode.decodeString decoder simpleSelectedOption)
            , test "an option that's not selected" <|
                \_ ->
                    Expect.equal
                        (Ok (newOption "Sup"))
                        (Json.Decode.decodeString decoder simpleNotSelectedOption)
            , test "a list of options" <|
                \_ ->
                    Expect.equal
                        (Ok
                            [ newOption "1" |> Option.setLabel "one"
                            , newOption "2" |> Option.setLabel "two"
                            , newSelectedOption "3" |> Option.setLabel "three"
                            ]
                        )
                        (Json.Decode.decodeString optionsDecoder listOfOptions)
            , test "a list of options with descriptions" <|
                \_ ->
                    Expect.equal
                        (Ok
                            [ newOption "1"
                                |> Option.setLabel "straw"
                                |> Option.setDescription "👒"
                            , newOption "2"
                                |> Option.setLabel "sticks"
                                |> Option.setDescription "🌳"
                            , newSelectedOption "3"
                                |> Option.setLabel "bricks"
                                |> Option.setDescription "🧱"
                            ]
                        )
                        (Json.Decode.decodeString
                            optionsDecoder
                            listOfOptionsWithDescriptions
                        )
            , test "a list of options with groups" <|
                \_ ->
                    Expect.equal
                        (Ok
                            [ newOption "1"
                                |> Option.setLabel "straw"
                                |> Option.setGroup "Building Material"
                            , newOption "2"
                                |> Option.setLabel "sticks"
                                |> Option.setGroup "Building Material"
                            , newSelectedOption "3"
                                |> Option.setLabel "bricks"
                                |> Option.setGroup "Building Material"
                            ]
                        )
                        (Json.Decode.decodeString
                            optionsDecoder
                            listOfOptionsWithGroups
                        )
            ]
        ]
