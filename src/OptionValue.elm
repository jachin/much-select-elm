module OptionValue exposing (OptionValue(..), isEmpty, length, optionValueToString, stringToOptionValue)


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
