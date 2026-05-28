module OptionValue exposing (OptionValue(..), decoder, equals, isEmpty, optionValueToString, stringToOptionValue, test_newOptionValue, toOptionLabel)

import Json.Decode
import OptionLabel exposing (OptionLabel)


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


toOptionLabel : OptionValue -> OptionLabel
toOptionLabel optionValue =
    case optionValue of
        OptionValue valueString ->
            OptionLabel.newWithCleanLabel valueString (Just valueString)

        EmptyOptionValue ->
            OptionLabel.newWithCleanLabel "" Nothing


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
