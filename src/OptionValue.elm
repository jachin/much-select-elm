module OptionValue exposing (OptionValue(..), decoder, equals, isEmpty, length, optionValueToString, stringToOptionValue, test_newOptionValue)

import Json.Decode


type OptionValue
    = OptionValue String
    | EmptyOptionValue


optionValueToString : OptionValue -> String
optionValueToString optionValue =
    case optionValue of
        OptionValue valueString ->
            valueString

        EmptyOptionValue ->
            ""


stringToOptionValue : String -> OptionValue
stringToOptionValue string =
    case string of
        "" ->
            EmptyOptionValue

        _ ->
            OptionValue string


length : OptionValue -> Int
length optionValue =
    case optionValue of
        OptionValue string ->
            String.length string

        EmptyOptionValue ->
            0


equals : OptionValue -> OptionValue -> Bool
equals a b =
    a == b


isEmpty : OptionValue -> Bool
isEmpty optionValue =
    case optionValue of
        OptionValue _ ->
            False

        EmptyOptionValue ->
            True


decoder : Json.Decode.Decoder OptionValue
decoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\valueStr ->
                case String.trim valueStr of
                    "" ->
                        Json.Decode.succeed EmptyOptionValue

                    str ->
                        Json.Decode.succeed (OptionValue str)
            )


test_newOptionValue : String -> OptionValue
test_newOptionValue string =
    OptionValue string
