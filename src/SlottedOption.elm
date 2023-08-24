module SlottedOption exposing (SlottedOption, decoder, encode, getOptionDisplay, getOptionSelectedIndex, getOptionSlot, getOptionValue, getOptionValueAsString, hasSelectedItemIndex, highlightOption, isOptionHighlighted, isOptionSelectedHighlighted, isSelected, new, optionIsHighlightable, removeHighlightFromOption, setOptionDisplay, setOptionSelectedIndex, setOptionValue, test_optionToDebuggingString)

import Json.Decode
import Json.Encode
import OptionDisplay exposing (OptionDisplay)
import OptionSlot exposing (OptionSlot)
import OptionValue exposing (OptionValue)
import SelectionMode exposing (SelectionConfig)


type SlottedOption
    = SlottedOption OptionDisplay OptionValue OptionSlot


new : OptionValue -> OptionSlot -> SlottedOption
new optionValue optionSlot =
    SlottedOption
        OptionDisplay.default
        optionValue
        optionSlot


getOptionDisplay : SlottedOption -> OptionDisplay
getOptionDisplay slottedOption =
    case slottedOption of
        SlottedOption optionDisplay _ _ ->
            optionDisplay


isOptionSelectedHighlighted : SlottedOption -> Bool
isOptionSelectedHighlighted option =
    OptionDisplay.isHighlightedSelected (getOptionDisplay option)


setOptionDisplay : OptionDisplay -> SlottedOption -> SlottedOption
setOptionDisplay optionDisplay slottedOption =
    case slottedOption of
        SlottedOption _ optionValue optionSlot ->
            SlottedOption optionDisplay optionValue optionSlot


isSelected : SlottedOption -> Bool
isSelected slottedOption =
    slottedOption |> getOptionDisplay |> OptionDisplay.isSelected


getOptionSelectedIndex : SlottedOption -> Int
getOptionSelectedIndex slottedOption =
    slottedOption |> getOptionDisplay |> OptionDisplay.getSelectedIndex


hasSelectedItemIndex : Int -> SlottedOption -> Bool
hasSelectedItemIndex selectedItemIndex option =
    getOptionSelectedIndex option == selectedItemIndex


setOptionSelectedIndex : Int -> SlottedOption -> SlottedOption
setOptionSelectedIndex selectedIndex option =
    setOptionDisplay (option |> getOptionDisplay |> OptionDisplay.setSelectedIndex selectedIndex) option


getOptionValue : SlottedOption -> OptionValue
getOptionValue slottedOption =
    case slottedOption of
        SlottedOption _ optionValue _ ->
            optionValue


getOptionValueAsString : SlottedOption -> String
getOptionValueAsString slottedOption =
    slottedOption |> getOptionValue |> OptionValue.optionValueToString


setOptionValue : OptionValue -> SlottedOption -> SlottedOption
setOptionValue optionValue slottedOption =
    case slottedOption of
        SlottedOption optionDisplay _ optionSlot ->
            SlottedOption optionDisplay optionValue optionSlot


highlightOption : SlottedOption -> SlottedOption
highlightOption option =
    setOptionDisplay (OptionDisplay.addHighlight (getOptionDisplay option)) option


removeHighlightFromOption : SlottedOption -> SlottedOption
removeHighlightFromOption option =
    setOptionDisplay (OptionDisplay.removeHighlight (getOptionDisplay option)) option


isOptionHighlighted : SlottedOption -> Bool
isOptionHighlighted option =
    OptionDisplay.isHighlighted (getOptionDisplay option)


optionIsHighlightable : SelectionConfig -> SlottedOption -> Bool
optionIsHighlightable selectionConfig option =
    OptionDisplay.isHighlightable (SelectionMode.getSelectionMode selectionConfig) (getOptionDisplay option)


select : Int -> SlottedOption -> SlottedOption
select selectionIndex option =
    setOptionDisplay (OptionDisplay.select selectionIndex (getOptionDisplay option)) option


deselect : SlottedOption -> SlottedOption
deselect option =
    setOptionDisplay (OptionDisplay.deselect (getOptionDisplay option)) option


getOptionSlot : SlottedOption -> OptionSlot
getOptionSlot slottedOption =
    case slottedOption of
        SlottedOption _ _ optionSlot ->
            optionSlot


decoder : OptionDisplay.OptionAge -> Json.Decode.Decoder SlottedOption
decoder age =
    Json.Decode.map3
        SlottedOption
        (OptionDisplay.decoder age)
        (Json.Decode.field
            "value"
            OptionValue.decoder
        )
        (Json.Decode.field "slot" OptionSlot.decoder)


encode : SlottedOption -> Json.Encode.Value
encode option =
    Json.Encode.object
        [ ( "value", Json.Encode.string (getOptionValueAsString option) )
        , ( "slot", OptionSlot.encode (getOptionSlot option) )
        ]


test_optionToDebuggingString : SlottedOption -> String
test_optionToDebuggingString slottedOption =
    slottedOption |> getOptionValue |> OptionValue.optionValueToString
