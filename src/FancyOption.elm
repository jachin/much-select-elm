module FancyOption exposing (FancyOption, activate, decoder, decoderWithAge, deselect, encode, getMaybeOptionSearchFilter, getOptionDescription, getOptionDisplay, getOptionGroup, getOptionLabel, getOptionSelectedIndex, getOptionValue, getOptionValueAsString, hasSelectedItemIndex, highlightOption, isCustomOption, isEmptyOption, isEmptyOptionOrHasEmptyValue, isOptionHighlighted, isOptionSelectedHighlighted, isSelected, merge, new, newCustomOption, newDisabledOption, newSelectedOption, optionIsHighlightable, optionToValueLabelTuple, removeHighlightFromOption, select, setDescription, setDescriptionWithString, setGroupWithString, setLabel, setLabelWithString, setOptionDisplay, setOptionDisplayAge, setOptionGroup, setOptionLabelToValue, setOptionSearchFilter, setOptionSelectedIndex, setOptionValue, test_optionToDebuggingString, toValueHtml)

import Events exposing (mouseUpPreventDefault)
import Html exposing (Html, div, span, text)
import Html.Attributes exposing (class, classList)
import Json.Decode
import Json.Encode
import OptionDescription exposing (OptionDescription(..))
import OptionDisplay exposing (OptionDisplay(..))
import OptionGroup exposing (OptionGroup(..))
import OptionLabel exposing (OptionLabel, optionLabelToString)
import OptionSearchFilter exposing (OptionSearchFilter)
import OptionValue exposing (OptionValue(..))
import OutputStyle exposing (SingleItemRemoval(..))
import SelectionMode exposing (OutputStyle, SelectionConfig, SelectionMode)


type FancyOption
    = FancyOption OptionDisplay OptionLabel OptionValue OptionDescription OptionGroup (Maybe OptionSearchFilter)
    | CustomFancyOption OptionDisplay OptionLabel OptionValue (Maybe OptionSearchFilter)
    | EmptyFancyOption OptionDisplay OptionLabel


new : String -> Maybe String -> FancyOption
new value maybeCleanLabel =
    case value of
        "" ->
            EmptyFancyOption OptionDisplay.default (OptionLabel.newWithCleanLabel "" maybeCleanLabel)

        _ ->
            FancyOption
                OptionDisplay.default
                (OptionLabel.newWithCleanLabel value maybeCleanLabel)
                (OptionValue value)
                OptionDescription.noDescription
                NoOptionGroup
                Nothing


newCustomOption : String -> String -> Maybe String -> FancyOption
newCustomOption valueString labelString maybeCleanLabel =
    CustomFancyOption
        OptionDisplay.default
        (OptionLabel.newWithCleanLabel labelString maybeCleanLabel)
        (OptionValue.stringToOptionValue valueString)
        Nothing


newSelectedOption : Int -> String -> Maybe String -> FancyOption
newSelectedOption index string maybeString =
    FancyOption
        (OptionDisplay.select index OptionDisplay.default)
        (OptionLabel.newWithCleanLabel string maybeString)
        (OptionValue.stringToOptionValue string)
        OptionDescription.noDescription
        NoOptionGroup
        Nothing


newDisabledOption : String -> Maybe String -> FancyOption
newDisabledOption valueString maybeString =
    FancyOption OptionDisplay.disabled
        (OptionLabel.newWithCleanLabel valueString maybeString)
        (OptionValue valueString)
        OptionDescription.noDescription
        NoOptionGroup
        Nothing


getOptionDisplay : FancyOption -> OptionDisplay
getOptionDisplay option =
    case option of
        FancyOption display _ _ _ _ _ ->
            display

        CustomFancyOption optionDisplay _ _ _ ->
            optionDisplay

        EmptyFancyOption optionDisplay _ ->
            optionDisplay


setOptionDisplay : OptionDisplay -> FancyOption -> FancyOption
setOptionDisplay optionDisplay option =
    case option of
        FancyOption _ optionLabel optionValue optionDescription optionGroup search ->
            FancyOption
                optionDisplay
                optionLabel
                optionValue
                optionDescription
                optionGroup
                search

        CustomFancyOption _ optionLabel optionValue maybeOptionSearchFilter ->
            CustomFancyOption optionDisplay optionLabel optionValue maybeOptionSearchFilter

        EmptyFancyOption _ optionLabel ->
            EmptyFancyOption optionDisplay optionLabel


isSelected : FancyOption -> Bool
isSelected fancyOption =
    fancyOption |> getOptionDisplay |> OptionDisplay.isSelected


getOptionSelectedIndex : FancyOption -> Int
getOptionSelectedIndex option =
    option |> getOptionDisplay |> OptionDisplay.getSelectedIndex


hasSelectedItemIndex : Int -> FancyOption -> Bool
hasSelectedItemIndex selectedItemIndex option =
    getOptionSelectedIndex option == selectedItemIndex


setOptionSelectedIndex : Int -> FancyOption -> FancyOption
setOptionSelectedIndex selectedIndex option =
    setOptionDisplay (option |> getOptionDisplay |> OptionDisplay.setSelectedIndex selectedIndex) option


setOptionDisplayAge : OptionDisplay.OptionAge -> FancyOption -> FancyOption
setOptionDisplayAge optionAge option =
    setOptionDisplay (option |> getOptionDisplay |> OptionDisplay.setAge optionAge) option


getOptionLabel : FancyOption -> OptionLabel
getOptionLabel fancyOption =
    case fancyOption of
        FancyOption _ optionLabel _ _ _ _ ->
            optionLabel

        CustomFancyOption _ optionLabel _ _ ->
            optionLabel

        EmptyFancyOption _ optionLabel ->
            optionLabel


setLabel : OptionLabel -> FancyOption -> FancyOption
setLabel label option =
    case option of
        FancyOption optionDisplay _ optionValue description group search ->
            FancyOption
                optionDisplay
                label
                optionValue
                description
                group
                search

        CustomFancyOption optionDisplay _ optionValue maybeOptionSearchFilter ->
            CustomFancyOption optionDisplay label optionValue maybeOptionSearchFilter

        EmptyFancyOption optionDisplay _ ->
            EmptyFancyOption optionDisplay label


setLabelWithString : String -> Maybe String -> FancyOption -> FancyOption
setLabelWithString string maybeCleanString option =
    let
        newOptionLabel =
            OptionLabel.newWithCleanLabel string maybeCleanString
    in
    case option of
        FancyOption optionDisplay _ optionValue description group search ->
            FancyOption
                optionDisplay
                newOptionLabel
                optionValue
                description
                group
                search

        CustomFancyOption optionDisplay _ optionValue maybeOptionSearchFilter ->
            CustomFancyOption optionDisplay newOptionLabel optionValue maybeOptionSearchFilter

        EmptyFancyOption optionDisplay _ ->
            EmptyFancyOption optionDisplay newOptionLabel


getOptionValue : FancyOption -> OptionValue
getOptionValue option =
    case option of
        FancyOption _ _ optionValue _ _ _ ->
            optionValue

        CustomFancyOption _ _ optionValue _ ->
            optionValue

        EmptyFancyOption _ _ ->
            EmptyOptionValue


getOptionValueAsString : FancyOption -> String
getOptionValueAsString option =
    case option |> getOptionValue of
        OptionValue string ->
            string

        EmptyOptionValue ->
            ""


setOptionValue : OptionValue -> FancyOption -> FancyOption
setOptionValue optionValue option =
    case option of
        FancyOption optionDisplay optionLabel _ optionDescription optionGroup maybeOptionSearchFilter ->
            FancyOption optionDisplay optionLabel optionValue optionDescription optionGroup maybeOptionSearchFilter

        CustomFancyOption optionDisplay optionLabel _ maybeOptionSearchFilter ->
            CustomFancyOption optionDisplay optionLabel optionValue maybeOptionSearchFilter

        EmptyFancyOption _ _ ->
            option


getOptionDescription : FancyOption -> OptionDescription
getOptionDescription option =
    case option of
        FancyOption _ _ _ optionDescription _ _ ->
            optionDescription

        CustomFancyOption _ _ _ _ ->
            OptionDescription.noDescription

        EmptyFancyOption _ _ ->
            OptionDescription.noDescription


setDescription : OptionDescription -> FancyOption -> FancyOption
setDescription description option =
    case option of
        FancyOption optionDisplay label optionValue _ group search ->
            FancyOption optionDisplay
                label
                optionValue
                description
                group
                search

        CustomFancyOption _ _ _ _ ->
            option

        EmptyFancyOption _ _ ->
            option


setDescriptionWithString : String -> FancyOption -> FancyOption
setDescriptionWithString string option =
    setDescription (OptionDescription.new string) option


getOptionGroup : FancyOption -> OptionGroup
getOptionGroup fancyOption =
    case fancyOption of
        FancyOption _ _ _ _ optionGroup _ ->
            optionGroup

        CustomFancyOption _ _ _ _ ->
            NoOptionGroup

        EmptyFancyOption _ _ ->
            NoOptionGroup


setOptionGroup : OptionGroup -> FancyOption -> FancyOption
setOptionGroup optionGroup option =
    case option of
        FancyOption optionDisplay label optionValue description _ search ->
            FancyOption optionDisplay
                label
                optionValue
                description
                optionGroup
                search

        CustomFancyOption _ _ _ _ ->
            option

        EmptyFancyOption _ _ ->
            option


setGroupWithString : String -> FancyOption -> FancyOption
setGroupWithString string option =
    setOptionGroup (OptionGroup string) option


getMaybeOptionSearchFilter : FancyOption -> Maybe OptionSearchFilter
getMaybeOptionSearchFilter option =
    case option of
        FancyOption _ _ _ _ _ maybeOptionSearchFilter ->
            maybeOptionSearchFilter

        CustomFancyOption _ _ _ _ ->
            Nothing

        EmptyFancyOption _ _ ->
            Nothing


setOptionSearchFilter : Maybe OptionSearchFilter -> FancyOption -> FancyOption
setOptionSearchFilter optionSearchFilter option =
    case option of
        FancyOption optionDisplay optionLabel optionValue optionDescription optionGroup _ ->
            FancyOption optionDisplay optionLabel optionValue optionDescription optionGroup optionSearchFilter

        CustomFancyOption optionDisplay optionLabel optionValue _ ->
            CustomFancyOption optionDisplay optionLabel optionValue optionSearchFilter

        EmptyFancyOption _ _ ->
            option


merge : FancyOption -> FancyOption -> FancyOption
merge optionA optionB =
    let
        optionLabel =
            orOptionLabel optionA optionB

        optionDescription =
            orOptionDescriptions optionA optionB

        optionGroup =
            orOptionGroup optionA optionB

        selectedIndex =
            orSelectedIndex optionA optionB
    in
    optionA
        |> setDescription optionDescription
        |> setLabel optionLabel
        |> setOptionGroup optionGroup
        |> setOptionSelectedIndex selectedIndex


{-| A utility helper, the idea is that an option's label is going to match it's value by default.

If a label does not match the value then it's probably a label that's been set and it something we should
preserver (all else being equal).

TODO: Perhaps this could be addresses with types. Maybe there should be an option label variation that specifies it's a default label.

-}
orOptionLabel : FancyOption -> FancyOption -> OptionLabel
orOptionLabel optionA optionB =
    if isOptionValueEqualToOptionLabel optionA then
        if isOptionValueEqualToOptionLabel optionB then
            getOptionLabel optionA

        else
            getOptionLabel optionB

    else
        getOptionLabel optionA


isOptionValueEqualToOptionLabel : FancyOption -> Bool
isOptionValueEqualToOptionLabel option =
    let
        optionValueString =
            option
                |> getOptionValueAsString

        optionLabelString =
            option
                |> getOptionLabel
                |> optionLabelToString
    in
    optionValueString == optionLabelString


orOptionDescriptions : FancyOption -> FancyOption -> OptionDescription
orOptionDescriptions optionA optionB =
    OptionDescription.orOptionDescriptions
        (getOptionDescription optionA)
        (getOptionDescription optionB)


orOptionGroup : FancyOption -> FancyOption -> OptionGroup
orOptionGroup optionA optionB =
    case getOptionGroup optionA of
        OptionGroup _ ->
            getOptionGroup optionA

        NoOptionGroup ->
            case getOptionGroup optionB of
                OptionGroup _ ->
                    getOptionGroup optionB

                NoOptionGroup ->
                    getOptionGroup optionA


orSelectedIndex : FancyOption -> FancyOption -> Int
orSelectedIndex optionA optionB =
    if getOptionSelectedIndex optionA == getOptionSelectedIndex optionB then
        getOptionSelectedIndex optionA

    else if getOptionSelectedIndex optionA > getOptionSelectedIndex optionB then
        getOptionSelectedIndex optionA

    else
        getOptionSelectedIndex optionB


highlightOption : FancyOption -> FancyOption
highlightOption option =
    setOptionDisplay (OptionDisplay.addHighlight (getOptionDisplay option)) option


removeHighlightFromOption : FancyOption -> FancyOption
removeHighlightFromOption option =
    setOptionDisplay (OptionDisplay.removeHighlight (getOptionDisplay option)) option


isOptionHighlighted : FancyOption -> Bool
isOptionHighlighted option =
    OptionDisplay.isHighlighted (getOptionDisplay option)


optionIsHighlightable : SelectionMode -> FancyOption -> Bool
optionIsHighlightable selectionMode option =
    OptionDisplay.isHighlightable selectionMode (getOptionDisplay option)


{-| Custom options are special. We need to reset their label to their value when we select them.
-}
select : Int -> FancyOption -> FancyOption
select selectionIndex option =
    case option of
        FancyOption _ _ _ _ _ _ ->
            setOptionDisplay (OptionDisplay.select selectionIndex (getOptionDisplay option)) option

        CustomFancyOption _ _ _ _ ->
            option
                |> setOptionDisplay (OptionDisplay.select selectionIndex (getOptionDisplay option))
                |> setOptionLabelToValue

        EmptyFancyOption _ _ ->
            setOptionDisplay (OptionDisplay.select selectionIndex (getOptionDisplay option)) option


deselect : FancyOption -> FancyOption
deselect option =
    setOptionDisplay (OptionDisplay.deselect (getOptionDisplay option)) option


isOptionSelectedHighlighted : FancyOption -> Bool
isOptionSelectedHighlighted option =
    OptionDisplay.isHighlightedSelected (getOptionDisplay option)


activate : FancyOption -> FancyOption
activate option =
    setOptionDisplay (getOptionDisplay option |> OptionDisplay.activate) option


isEmptyOption : FancyOption -> Bool
isEmptyOption option =
    case option of
        FancyOption _ _ _ _ _ _ ->
            False

        CustomFancyOption _ _ _ _ ->
            False

        EmptyFancyOption _ _ ->
            True


isEmptyOptionOrHasEmptyValue : FancyOption -> Bool
isEmptyOptionOrHasEmptyValue option =
    isEmptyOption option || (getOptionValue option |> OptionValue.isEmpty)


optionToValueLabelTuple : FancyOption -> ( String, String )
optionToValueLabelTuple option =
    ( getOptionValueAsString option, getOptionLabel option |> optionLabelToString )


isCustomOption : FancyOption -> Bool
isCustomOption option =
    case option of
        FancyOption _ _ _ _ _ _ ->
            False

        CustomFancyOption _ _ _ _ ->
            True

        EmptyFancyOption _ _ ->
            False


setOptionLabelToValue : FancyOption -> FancyOption
setOptionLabelToValue fancyOption =
    case fancyOption of
        CustomFancyOption optionDisplay _ optionValue maybeOptionSearchFilter ->
            CustomFancyOption optionDisplay (OptionValue.toOptionLabel optionValue) optionValue maybeOptionSearchFilter

        _ ->
            fancyOption



-- JSON (Decoders and Encoders)


decoder : Json.Decode.Decoder FancyOption
decoder =
    decoderWithAge OptionDisplay.MatureOption


decoderWithAge : OptionDisplay.OptionAge -> Json.Decode.Decoder FancyOption
decoderWithAge optionAge =
    Json.Decode.oneOf
        [ decodeOptionWithoutAValue optionAge
        , decodeOptionWithAValue optionAge
        ]


decodeOptionWithoutAValue : OptionDisplay.OptionAge -> Json.Decode.Decoder FancyOption
decodeOptionWithoutAValue age =
    Json.Decode.field
        "value"
        OptionValue.decoder
        |> Json.Decode.andThen
            (\value ->
                case value of
                    OptionValue _ ->
                        Json.Decode.fail "It can not be an option without a value because it has a value."

                    EmptyOptionValue ->
                        Json.Decode.map2
                            EmptyFancyOption
                            (OptionDisplay.decoder age)
                            OptionLabel.labelDecoder
            )


decodeOptionWithAValue : OptionDisplay.OptionAge -> Json.Decode.Decoder FancyOption
decodeOptionWithAValue age =
    Json.Decode.map6 FancyOption
        (OptionDisplay.decoder age)
        OptionLabel.labelDecoder
        (Json.Decode.field
            "value"
            OptionValue.decoder
        )
        OptionDescription.decoder
        OptionGroup.decoder
        (Json.Decode.succeed Nothing)


encode : FancyOption -> Json.Decode.Value
encode option =
    Json.Encode.object
        [ ( "value", Json.Encode.string (getOptionValueAsString option) )
        , ( "label", Json.Encode.string (getOptionLabel option |> optionLabelToString) )
        , ( "labelClean", Json.Encode.string (getOptionLabel option |> OptionLabel.optionLabelToSearchString) )
        , ( "group", Json.Encode.string (getOptionGroup option |> OptionGroup.toString) )
        , ( "description", Json.Encode.string (getOptionDescription option |> OptionDescription.toString) )
        , ( "descriptionClean", Json.Encode.string (getOptionDescription option |> OptionDescription.toSearchString) )
        , ( "isSelected", Json.Encode.bool (isSelected option) )
        ]



-- HTML (View Helpers)


toValueHtml : (OptionValue -> msg) -> (OptionValue -> msg) -> SingleItemRemoval -> FancyOption -> Html msg
toValueHtml toggleSelectedMsg deselectOptionInternal enableSingleItemRemoval fancyOption =
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
    case fancyOption of
        FancyOption optionDisplay optionLabel optionValue optionDescription optionGroup maybeOptionSearchFilter ->
            case optionDisplay of
                OptionShown _ ->
                    text ""

                OptionHidden ->
                    text ""

                OptionSelected _ _ ->
                    div
                        [ class "value"
                        , partAttr
                        ]
                        [ valueLabelHtml toggleSelectedMsg (OptionLabel.getLabelString optionLabel) optionValue, removalHtml optionValue ]

                OptionSelectedAndInvalid _ _ ->
                    text ""

                OptionSelectedPendingValidation _ ->
                    text ""

                OptionSelectedHighlighted int ->
                    div
                        [ classList
                            [ ( "value", True )
                            , ( "highlighted-value", True )
                            ]
                        , highlightPartAttr
                        ]
                        [ valueLabelHtml toggleSelectedMsg (OptionLabel.getLabelString optionLabel) optionValue, removalHtml optionValue ]

                OptionHighlighted ->
                    text ""

                OptionActivated ->
                    text ""

                OptionDisabled _ ->
                    text ""

        CustomFancyOption optionDisplay optionLabel optionValue maybeOptionSearchFilter ->
            case optionDisplay of
                OptionShown _ ->
                    text ""

                OptionHidden ->
                    text ""

                OptionSelected _ _ ->
                    div
                        [ class "value"
                        , partAttr
                        ]
                        [ valueLabelHtml toggleSelectedMsg (OptionLabel.getLabelString optionLabel) optionValue, removalHtml optionValue ]

                OptionSelectedAndInvalid _ _ ->
                    text ""

                OptionSelectedPendingValidation _ ->
                    text ""

                OptionSelectedHighlighted _ ->
                    div
                        [ classList
                            [ ( "value", True )
                            , ( "highlighted-value", True )
                            ]
                        , highlightPartAttr
                        ]
                        [ valueLabelHtml toggleSelectedMsg (OptionLabel.getLabelString optionLabel) optionValue, removalHtml optionValue ]

                OptionHighlighted ->
                    text ""

                OptionActivated ->
                    text ""

                OptionDisabled _ ->
                    text ""

        EmptyFancyOption optionDisplay optionLabel ->
            case optionDisplay of
                OptionShown _ ->
                    text ""

                OptionHidden ->
                    text ""

                OptionSelected _ _ ->
                    div [ class "value", partAttr ] [ text (OptionLabel.getLabelString optionLabel) ]

                OptionSelectedAndInvalid _ _ ->
                    text ""

                OptionSelectedPendingValidation _ ->
                    text ""

                OptionSelectedHighlighted _ ->
                    text ""

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



-- TEST HELPERS


test_optionToDebuggingString : FancyOption -> String
test_optionToDebuggingString fancyOption =
    case fancyOption |> getOptionGroup |> OptionGroup.toString of
        "" ->
            fancyOption |> getOptionLabel |> optionLabelToString

        group ->
            group ++ " - " ++ (fancyOption |> getOptionLabel |> optionLabelToString)
