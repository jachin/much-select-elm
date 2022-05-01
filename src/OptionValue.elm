module OptionValue exposing (OptionValue(..), length, optionValueToString, stringToOptionValue)


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
    OptionValue string


length : OptionValue -> Int
length optionValue =
    case optionValue of
        OptionValue string ->
            String.length string

        EmptyOptionValue ->
            0
