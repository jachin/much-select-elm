module OptionPart exposing (OptionPart, decoder, empty, toAttribute)

import Html
import Html.Attributes
import Html.Attributes.Extra
import Json.Decode exposing (Decoder)
import String.Extra


type OptionPart
    = OptionPart String


toAttribute : OptionPart -> Html.Attribute msg
toAttribute optionPart =
    case optionPart of
        OptionPart string ->
            case string of
                "" ->
                    Html.Attributes.attribute "part" "value"

                _ ->
                    Html.Attributes.attribute "part" ("value " ++ string)


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
