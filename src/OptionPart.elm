module OptionPart exposing (OptionPart, decoder, empty, fromStringOrEmpty, test_new, toDropdownAttribute, toSelectedValueAttribute, valueDecoder)

import Html
import Html.Attributes
import Json.Decode exposing (Decoder)
import OptionDisplay exposing (OptionDisplay(..))
import String.Extra


type OptionPart
    = OptionPart String


toSelectedValueAttribute : OptionPart -> Html.Attribute msg
toSelectedValueAttribute optionPart =
    case optionPart of
        OptionPart string ->
            case string of
                "" ->
                    Html.Attributes.attribute "part" "selected-value"

                _ ->
                    Html.Attributes.attribute "part" ("selected-value " ++ string)


toDropdownAttribute : OptionDisplay -> OptionPart -> Html.Attribute msg
toDropdownAttribute optionDisplay optionPart =
    let
        valuePart =
            case optionPart of
                OptionPart string ->
                    case string of
                        "" ->
                            ""

                        _ ->
                            string

        partAttribute =
            Html.Attributes.attribute "part"
    in
    case optionDisplay of
        OptionShown _ ->
            partAttribute ("dropdown-option " ++ valuePart)

        OptionHidden ->
            partAttribute ("dropdown-option hidden " ++ valuePart)

        OptionSelected _ _ ->
            partAttribute ("dropdown-option selected selected " ++ valuePart)

        OptionSelectedAndInvalid _ _ ->
            partAttribute ("dropdown-option selected invalid " ++ valuePart)

        OptionSelectedPendingValidation _ ->
            partAttribute ("dropdown-option " ++ valuePart)

        OptionSelectedHighlighted _ ->
            partAttribute ("dropdown-option selected highlighted " ++ valuePart)

        OptionHighlighted ->
            partAttribute ("dropdown-option highlighted " ++ valuePart)

        OptionActivated ->
            partAttribute ("dropdown-option active highlighted " ++ valuePart)

        OptionDisabled _ ->
            partAttribute ("dropdown-option disabled " ++ valuePart)


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


valueDecoder : Decoder OptionPart
valueDecoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\s ->
                case fromString s of
                    Nothing ->
                        Json.Decode.fail "The value is empty so we are unable to make a part of the value"

                    Just part ->
                        Json.Decode.succeed part
            )


fromString : String -> Maybe OptionPart
fromString string =
    let
        partString =
            string |> String.trim |> String.Extra.dasherize
    in
    case partString of
        "" ->
            Nothing

        _ ->
            Just (OptionPart string)


fromStringOrEmpty : String -> OptionPart
fromStringOrEmpty string =
    case fromString string of
        Nothing ->
            empty

        Just part ->
            part


test_new : String -> OptionPart
test_new string =
    OptionPart string
