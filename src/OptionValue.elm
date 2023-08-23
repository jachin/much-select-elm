module OptionValue exposing (OptionValue(..), isEmpty, length, optionValueToString, stringToOptionValue, decoder)


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
