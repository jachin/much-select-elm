module ValueString exposing (ValueString, fromOptionValue, length, reset, toOptionValue, toString)

import Option exposing (OptionValue)


type ValueString
    = ValueString String


reset : ValueString
reset =
    ValueString ""


toOptionValue : ValueString -> OptionValue
toOptionValue (ValueString str) =
    Option.stringToOptionValue str


length : ValueString -> Int
length (ValueString str) =
    String.length str


toString : ValueString -> String
toString (ValueString str) =
    str


fromOptionValue : OptionValue -> ValueString
fromOptionValue optionValue =
    ValueString (Option.optionValueToString optionValue)
