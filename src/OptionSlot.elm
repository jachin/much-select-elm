module OptionSlot exposing (OptionSlot, decoder, empty, toSlotNameAttribute)

import Html
import Html.Attributes
import Html.Attributes.Extra
import Json.Decode exposing (Decoder)


type OptionSlot
    = OptionSlot String


toString : OptionSlot -> String
toString optionSlot =
    case optionSlot of
        OptionSlot option ->
            option


decoder : Decoder OptionSlot
decoder =
    Json.Decode.string
        |> Json.Decode.map OptionSlot


empty : OptionSlot
empty =
    OptionSlot ""


toSlotNameAttribute : OptionSlot -> Html.Attribute msg
toSlotNameAttribute optionSlot =
    case optionSlot of
        OptionSlot string ->
            if string == "" then
                Html.Attributes.Extra.empty

            else
                Html.Attributes.attribute "name" string
