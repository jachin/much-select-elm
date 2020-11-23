module Option.DecodersAndEncoders exposing (suite)

import Expect
import Json.Decode
import Option exposing (decoder, newOption, newSelectedOption)
import Test exposing (Test, describe, test)


simpleOptionWithJustLabelAndValue =
    """{"label": "Sup", "value": "Sup"}"""


simpleSelectedOption =
    """{"label": "Sup", "value": "Sup", "selected": "true"}"""


simpleNotSelectedOption =
    """{"label": "Sup", "value": "Sup", "selected": "false"}"""


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
            ]
        ]
