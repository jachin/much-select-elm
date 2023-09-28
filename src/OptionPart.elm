module OptionPart exposing (OptionPart, decoder, empty, toActiveDropdownAttribute, toDisabledDropdownAttribute, toDropdownAttribute, toHighlightedDropdownAttribute, toValueAttribute)

import Html
import Html.Attributes
import Html.Attributes.Extra
import Json.Decode exposing (Decoder)
import String.Extra


type OptionPart
    = OptionPart String


toValueAttribute : OptionPart -> Html.Attribute msg
toValueAttribute optionPart =
    case optionPart of
        OptionPart string ->
            case string of
                "" ->
                    Html.Attributes.attribute "part" "value"

                _ ->
                    Html.Attributes.attribute "part" ("value " ++ string)


toDropdownAttribute : OptionPart -> Html.Attribute msg
toDropdownAttribute optionPart =
    case optionPart of
        OptionPart string ->
            case string of
                "" ->
                    Html.Attributes.attribute "part" "dropdown-option"

                _ ->
                    Html.Attributes.attribute "part" ("dropdown-option " ++ string)


toHighlightedDropdownAttribute : OptionPart -> Html.Attribute msg
toHighlightedDropdownAttribute optionPart =
    case optionPart of
        OptionPart string ->
            case string of
                "" ->
                    Html.Attributes.attribute "part" "dropdown-option highlighted"

                _ ->
                    Html.Attributes.attribute "part" ("dropdown-option highlighted " ++ string)


toActiveDropdownAttribute : OptionPart -> Html.Attribute msg
toActiveDropdownAttribute optionPart =
    case optionPart of
        OptionPart string ->
            case string of
                "" ->
                    Html.Attributes.attribute "part" "dropdown-option active highlighted"

                _ ->
                    Html.Attributes.attribute "part" ("dropdown-option active highlighted " ++ string)


toDisabledDropdownAttribute : OptionPart -> Html.Attribute msg
toDisabledDropdownAttribute optionPart =
    case optionPart of
        OptionPart string ->
            case string of
                "" ->
                    Html.Attributes.attribute "part" "dropdown-option disabled"

                _ ->
                    Html.Attributes.attribute "part" ("dropdown-option disabled " ++ string)


empty : OptionPart
empty =
    OptionPart ""


decoder : Decoder OptionPart
decoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\s ->
                if s == String.Extra.dasherize s then
                    Json.Decode.succeed (OptionPart s)

                else
                    Json.Decode.fail ("Invalid option part: " ++ s)
            )
