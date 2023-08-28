module SlottedOption exposing (SlottedOption, decoder, decoderWithAge, encode, getOptionDisplay, getOptionSelectedIndex, getOptionSlot, getOptionValue, getOptionValueAsString, hasSelectedItemIndex, highlightOption, isOptionHighlighted, isOptionSelectedHighlighted, isSelected, new, optionIsHighlightable, removeHighlightFromOption, setOptionDisplay, setOptionSelectedIndex, setOptionValue, test_optionToDebuggingString, toValueHtml)

import Events exposing (mouseUpPreventDefault)
import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class, classList)
import Json.Decode
import Json.Encode
import OptionDisplay exposing (OptionDisplay(..))
import OptionSlot exposing (OptionSlot)
import OptionValue exposing (OptionValue)
import OutputStyle exposing (SingleItemRemoval(..))
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


decoder : Json.Decode.Decoder SlottedOption
decoder =
    decoderWithAge OptionDisplay.MatureOption


decoderWithAge : OptionDisplay.OptionAge -> Json.Decode.Decoder SlottedOption
decoderWithAge age =
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


toValueHtml : (OptionValue -> msg) -> (OptionValue -> msg) -> SingleItemRemoval -> SlottedOption -> Html msg
toValueHtml toggleSelectedMsg deselectOptionInternal enableSingleItemRemoval option =
    let
        removalHtml optionValue =
            case enableSingleItemRemoval of
                EnableSingleItemRemoval ->
                    span [ mouseUpPreventDefault <| deselectOptionInternal optionValue, class "remove-option" ] [ text "" ]

                DisableSingleItemRemoval ->
                    text ""

        partAttr =
            Html.Attributes.attribute "part" "value"

        highlightPartAttr =
            Html.Attributes.attribute "part" "value highlighted-value"
    in
    case option of
        SlottedOption optionDisplay optionValue optionSlot ->
            case optionDisplay of
                OptionShown optionAge ->
                    text ""

                OptionHidden ->
                    text ""

                OptionSelected _ _ ->
                    div
                        [ class "value"
                        , partAttr
                        ]
                        [ valueLabelHtml
                            toggleSelectedMsg
                            (OptionValue.optionValueToString optionValue)
                            optionValue
                        , removalHtml optionValue
                        ]

                OptionSelectedAndInvalid int validationFailureMessages ->
                    text ""

                OptionSelectedPendingValidation int ->
                    text ""

                OptionSelectedHighlighted int ->
                    div
                        [ classList
                            [ ( "value", True )
                            , ( "highlighted-value", True )
                            ]
                        , highlightPartAttr
                        ]
                        [ valueLabelHtml
                            toggleSelectedMsg
                            (OptionValue.optionValueToString optionValue)
                            optionValue
                        , removalHtml optionValue
                        ]

                OptionHighlighted ->
                    text ""

                OptionActivated ->
                    text ""

                OptionDisabled _ ->
                    text ""


valueLabelHtml : (OptionValue -> msg) -> String -> OptionValue -> Html msg
valueLabelHtml toggleSelectedMsg labelText optionValue =
    span
        [ class "value-label"
        , mouseUpPreventDefault
            (toggleSelectedMsg optionValue)
        ]
        [ text labelText ]
