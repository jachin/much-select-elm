module DropdownOptions exposing (DropdownItemEventListeners, DropdownOptions, dropdownOptionsToDatalistOption, dropdownOptionsToSlottedOptionsHtml, figureOutWhichOptionsToShowInTheDropdown, figureOutWhichOptionsToShowInTheDropdownThatAreNotSelected, getSearchFilters, groupInOrder, head, isEmpty, length, maybeFirstOptionSearchFilter, moveHighlightedOptionDown, moveHighlightedOptionDownIfThereAreOptions, moveHighlightedOptionUp, optionsToCustomHtml, test_fromOptions, test_getOptions, valuesAsStrings)

import Events exposing (mouseDownPreventDefault, mouseUpPreventDefault, onClickPreventDefault, onClickPreventDefaultAndStopPropagation)
import Html exposing (Html, div, node, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onMouseEnter, onMouseLeave)
import Html.Lazy
import List.Extra
import Maybe.Extra
import Option exposing (Option, OptionGroup, getOptionGroup)
import OptionDisplay exposing (OptionDisplay(..))
import OptionLabel exposing (optionLabelToString)
import OptionPresentor exposing (tokensToHtml)
import OptionSearchFilter exposing (OptionSearchFilter)
import OptionSlot
import OptionValue exposing (OptionValue)
import OptionsUtilities exposing (filterOptionsToShowInDropdown, findClosestHighlightableOptionGoingDown, findClosestHighlightableOptionGoingUp, findHighlightedOrSelectedOptionIndex, highlightOptionInList)
import OutputStyle
import PositiveInt
import SelectionMode exposing (SelectionConfig, getMaxDropdownItems)


type DropdownOptions
    = DropdownOptions (List Option)
    | DropdownOptionsThatAreNotSelected (List Option)


{-| This function is responsible for figuring out which options should be shown in the dropdown.

Once it does it's work it wraps it in a special type, flagging this list of options as just
the options that are supposed to be shown in the dropdown.

-}
figureOutWhichOptionsToShowInTheDropdown : SelectionConfig -> List Option -> DropdownOptions
figureOutWhichOptionsToShowInTheDropdown selectionConfig options =
    let
        optionsThatCouldBeShown =
            options
                |> filterOptionsToShowInDropdown selectionConfig
                |> OptionsUtilities.sortOptionsByBestScore

        lastIndexOfOptions =
            List.length optionsThatCouldBeShown - 1
    in
    case getMaxDropdownItems selectionConfig of
        OutputStyle.FixedMaxDropdownItems maxDropdownItems ->
            let
                maxNumberOfDropdownItems =
                    PositiveInt.toInt maxDropdownItems
            in
            if List.length optionsThatCouldBeShown <= maxNumberOfDropdownItems then
                DropdownOptions optionsThatCouldBeShown

            else
                case findHighlightedOrSelectedOptionIndex optionsThatCouldBeShown of
                    Just index ->
                        case index of
                            0 ->
                                DropdownOptions (List.take maxNumberOfDropdownItems optionsThatCouldBeShown)

                            _ ->
                                if index == List.length optionsThatCouldBeShown - 1 then
                                    DropdownOptions (List.drop (List.length options - maxNumberOfDropdownItems) optionsThatCouldBeShown)

                                else
                                    let
                                        isEven =
                                            modBy 2 maxNumberOfDropdownItems
                                                == 0

                                        half =
                                            if isEven then
                                                maxNumberOfDropdownItems // 2

                                            else
                                                (maxNumberOfDropdownItems // 2) + 1
                                    in
                                    if index + half > lastIndexOfOptions then
                                        -- The "window" runs off the "tail" of the list, so just take the last options
                                        DropdownOptions (List.drop (List.length options - maxNumberOfDropdownItems) optionsThatCouldBeShown)

                                    else if index - half < 0 then
                                        -- The "window" runs off the "head" of the list, so just take the first options
                                        DropdownOptions (List.take maxNumberOfDropdownItems optionsThatCouldBeShown)

                                    else
                                        DropdownOptions (options |> List.drop (index + 1 - half) |> List.take maxNumberOfDropdownItems)

                    Nothing ->
                        DropdownOptions (List.take maxNumberOfDropdownItems options)

        OutputStyle.NoLimitToDropdownItems ->
            DropdownOptions optionsThatCouldBeShown


figureOutWhichOptionsToShowInTheDropdownThatAreNotSelected : SelectionConfig -> List Option -> DropdownOptions
figureOutWhichOptionsToShowInTheDropdownThatAreNotSelected selectionConfig options =
    let
        visibleOptions =
            figureOutWhichOptionsToShowInTheDropdown selectionConfig options |> getOptions
    in
    DropdownOptionsThatAreNotSelected (OptionsUtilities.notSelectedOptions visibleOptions)


getOptions : DropdownOptions -> List Option
getOptions dropdownOptions =
    case dropdownOptions of
        DropdownOptions options ->
            options

        DropdownOptionsThatAreNotSelected options ->
            options


isEmpty : DropdownOptions -> Bool
isEmpty dropdownOptions =
    dropdownOptions |> getOptions |> List.isEmpty


length : DropdownOptions -> Int
length dropdownOptions =
    dropdownOptions |> getOptions |> List.length


head : DropdownOptions -> Maybe Option
head dropdownOptions =
    dropdownOptions |> getOptions |> List.head


valuesAsStrings : DropdownOptions -> List String
valuesAsStrings dropdownOptions =
    dropdownOptions |> getOptions |> List.map Option.getOptionValueAsString


test_getOptions : DropdownOptions -> List Option
test_getOptions dropdownOptions =
    getOptions dropdownOptions


test_fromOptions : List Option -> DropdownOptions
test_fromOptions options =
    DropdownOptions options


getSearchFilters : DropdownOptions -> List (Maybe OptionSearchFilter)
getSearchFilters dropdownOptions =
    dropdownOptions
        |> getOptions
        |> List.map
            (\option ->
                Option.getMaybeOptionSearchFilter option
            )


groupInOrder : DropdownOptions -> List ( OptionGroup, DropdownOptions )
groupInOrder dropdownOptions =
    let
        helper : Option -> Option -> Bool
        helper optionA optionB =
            getOptionGroup optionA == getOptionGroup optionB
    in
    List.Extra.groupWhile helper (getOptions dropdownOptions)
        |> List.map
            (\( firstOption, restOfOptions ) ->
                ( getOptionGroup firstOption
                , DropdownOptions (firstOption :: restOfOptions)
                )
            )


maybeFirstOptionSearchFilter : DropdownOptions -> Maybe OptionSearchFilter
maybeFirstOptionSearchFilter dropdownOptions =
    case dropdownOptions of
        DropdownOptions options ->
            List.head options
                |> Maybe.andThen Option.getMaybeOptionSearchFilter

        DropdownOptionsThatAreNotSelected options ->
            List.head options
                |> Maybe.andThen Option.getMaybeOptionSearchFilter


moveHighlightedOptionUp : SelectionConfig -> List Option -> List Option
moveHighlightedOptionUp selectionConfig allOptions =
    let
        visibleOptions =
            figureOutWhichOptionsToShowInTheDropdown selectionConfig allOptions |> getOptions

        maybeHigherSibling =
            visibleOptions
                |> findHighlightedOrSelectedOptionIndex
                |> Maybe.andThen (\index -> findClosestHighlightableOptionGoingUp selectionConfig index visibleOptions)
    in
    case maybeHigherSibling of
        Just option ->
            highlightOptionInList option allOptions

        Nothing ->
            case List.head visibleOptions of
                Just firstOption ->
                    highlightOptionInList firstOption allOptions

                Nothing ->
                    allOptions


moveHighlightedOptionDown : SelectionConfig -> List Option -> List Option
moveHighlightedOptionDown selectionConfig allOptions =
    let
        visibleOptions =
            figureOutWhichOptionsToShowInTheDropdown selectionConfig allOptions |> getOptions

        maybeLowerSibling =
            visibleOptions
                |> findHighlightedOrSelectedOptionIndex
                |> Maybe.andThen (\index -> findClosestHighlightableOptionGoingDown selectionConfig index visibleOptions)
    in
    case maybeLowerSibling of
        Just option ->
            highlightOptionInList option allOptions

        Nothing ->
            -- If there is not a lower sibling to highlight, jump up to the top of the list, and see
            --  if there is a sibling to highlight at the top of the dropdown. There might not be,
            --  the dropdown might be empty or all the options might be selected.
            case findClosestHighlightableOptionGoingDown selectionConfig 0 visibleOptions of
                Just firstOption ->
                    highlightOptionInList firstOption allOptions

                Nothing ->
                    allOptions


moveHighlightedOptionDownIfThereAreOptions : SelectionConfig -> List Option -> List Option
moveHighlightedOptionDownIfThereAreOptions selectionConfig options =
    let
        visibleOptions =
            figureOutWhichOptionsToShowInTheDropdown selectionConfig options
    in
    if length visibleOptions > 1 then
        moveHighlightedOptionDown
            selectionConfig
            options

    else
        options


type alias DropdownItemEventListeners msg =
    { mouseOverMsgConstructor : OptionValue -> msg
    , mouseOutMsgConstructor : OptionValue -> msg
    , mouseDownMsgConstructor : OptionValue -> msg
    , mouseUpMsgConstructor : OptionValue -> msg
    , noOpMsgConstructor : msg
    }


optionsToCustomHtml : DropdownItemEventListeners msg -> SelectionConfig -> DropdownOptions -> List (Html msg)
optionsToCustomHtml dropdownItemEventListeners selectionConfig dropdownOptions =
    case dropdownOptions of
        DropdownOptions options ->
            List.map (optionToCustomHtml dropdownItemEventListeners selectionConfig) options

        DropdownOptionsThatAreNotSelected options ->
            List.map (optionToCustomHtml dropdownItemEventListeners selectionConfig) options


valueDataAttribute : Option -> Html.Attribute msg
valueDataAttribute option =
    Html.Attributes.attribute "data-value" (Option.getOptionValueAsString option)


optionToCustomHtml :
    DropdownItemEventListeners msg
    -> SelectionConfig
    -> Option
    -> Html msg
optionToCustomHtml eventHandlers selectionConfig_ option_ =
    Html.Lazy.lazy2
        (\selectionConfig option ->
            let
                descriptionHtml : Html msg
                descriptionHtml =
                    if option |> Option.getOptionDescription |> Option.optionDescriptionToBool then
                        case Option.getMaybeOptionSearchFilter option of
                            Just optionSearchFilter ->
                                div
                                    [ class "description"
                                    , Html.Attributes.attribute "part" "dropdown-option-description"
                                    ]
                                    [ span [] (tokensToHtml optionSearchFilter.descriptionTokens)
                                    ]

                            Nothing ->
                                div
                                    [ class "description"
                                    , Html.Attributes.attribute "part" "dropdown-option-description"
                                    ]
                                    [ span []
                                        [ option
                                            |> Option.getOptionDescription
                                            |> Option.optionDescriptionToString
                                            |> text
                                        ]
                                    ]

                    else
                        text ""

                labelHtml : Html msg
                labelHtml =
                    case Option.getMaybeOptionSearchFilter option of
                        Just optionSearchFilter ->
                            span [] (tokensToHtml optionSearchFilter.labelTokens)

                        Nothing ->
                            span [] [ Option.getOptionLabel option |> optionLabelToString |> text ]
            in
            case Option.getOptionDisplay option of
                OptionShown _ ->
                    div
                        [ onMouseEnter (option |> Option.getOptionValue |> eventHandlers.mouseOverMsgConstructor)
                        , onMouseLeave (option |> Option.getOptionValue |> eventHandlers.mouseOutMsgConstructor)
                        , mouseDownPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseDownMsgConstructor)
                        , mouseUpPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseUpMsgConstructor)
                        , onClickPreventDefault eventHandlers.noOpMsgConstructor
                        , Html.Attributes.attribute "part" "dropdown-option"
                        , class "option"
                        , valueDataAttribute option
                        ]
                        [ labelHtml, descriptionHtml ]

                OptionHidden ->
                    text ""

                OptionSelected _ _ ->
                    case SelectionMode.getSelectionMode selectionConfig of
                        SelectionMode.SingleSelect ->
                            div
                                [ onMouseEnter (option |> Option.getOptionValue |> eventHandlers.mouseOverMsgConstructor)
                                , onMouseLeave (option |> Option.getOptionValue |> eventHandlers.mouseOutMsgConstructor)
                                , mouseDownPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseDownMsgConstructor)
                                , mouseUpPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseUpMsgConstructor)
                                , Html.Attributes.attribute "part" "dropdown-option selected"
                                , class "selected"
                                , class "option"
                                , valueDataAttribute option
                                ]
                                [ labelHtml, descriptionHtml ]

                        SelectionMode.MultiSelect ->
                            text ""

                OptionSelectedPendingValidation _ ->
                    div
                        [ Html.Attributes.attribute "part" "dropdown-option disabled"
                        , class "disabled"
                        , class "option"
                        , valueDataAttribute option
                        ]
                        [ labelHtml, descriptionHtml ]

                OptionSelectedAndInvalid _ _ ->
                    text ""

                OptionSelectedHighlighted _ ->
                    case SelectionMode.getSelectionMode selectionConfig of
                        SelectionMode.SingleSelect ->
                            div
                                [ onMouseEnter (option |> Option.getOptionValue |> eventHandlers.mouseOverMsgConstructor)
                                , onMouseLeave (option |> Option.getOptionValue |> eventHandlers.mouseOutMsgConstructor)
                                , mouseDownPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseDownMsgConstructor)
                                , mouseUpPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseUpMsgConstructor)
                                , Html.Attributes.attribute "part" "dropdown-option selected highlighted"
                                , class "selected"
                                , class "highlighted"
                                , class "option"
                                , valueDataAttribute option
                                ]
                                [ labelHtml, descriptionHtml ]

                        SelectionMode.MultiSelect ->
                            text ""

                OptionHighlighted ->
                    div
                        [ onMouseEnter (option |> Option.getOptionValue |> eventHandlers.mouseOverMsgConstructor)
                        , onMouseLeave (option |> Option.getOptionValue |> eventHandlers.mouseOutMsgConstructor)
                        , mouseDownPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseDownMsgConstructor)
                        , mouseUpPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseUpMsgConstructor)
                        , Html.Attributes.attribute "part" "dropdown-option highlighted"
                        , class "highlighted"
                        , class "option"
                        , valueDataAttribute option
                        ]
                        [ labelHtml, descriptionHtml ]

                OptionDisabled _ ->
                    div
                        [ Html.Attributes.attribute "part" "dropdown-option disabled"
                        , class "disabled"
                        , class "option"
                        , valueDataAttribute option
                        ]
                        [ labelHtml, descriptionHtml ]

                OptionActivated ->
                    div
                        [ onMouseEnter (option |> Option.getOptionValue |> eventHandlers.mouseOverMsgConstructor)
                        , onMouseLeave (option |> Option.getOptionValue |> eventHandlers.mouseOutMsgConstructor)
                        , mouseDownPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseDownMsgConstructor)
                        , mouseUpPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseUpMsgConstructor)
                        , onClickPreventDefaultAndStopPropagation eventHandlers.noOpMsgConstructor
                        , Html.Attributes.attribute "part" "dropdown-option active"
                        , class "option"
                        , class "active"
                        , class "highlighted"
                        , valueDataAttribute option
                        ]
                        [ labelHtml, descriptionHtml ]
        )
        selectionConfig_
        option_


dropdownOptionsToDatalistOption : DropdownOptions -> List (Html msg)
dropdownOptionsToDatalistOption dropdownOptions =
    List.map optionToDatalistOption (getOptions dropdownOptions)


optionToDatalistOption : Option -> Html msg
optionToDatalistOption option =
    Html.option [ Html.Attributes.value (Option.getOptionValueAsString option) ] []


dropdownOptionsToSlottedOptionsHtml : DropdownItemEventListeners msg -> DropdownOptions -> List (Html msg)
dropdownOptionsToSlottedOptionsHtml eventHandlers options =
    List.map (optionToSlottedOptionHtml eventHandlers) (getOptions options)


optionToSlottedOptionHtml : DropdownItemEventListeners msg -> Option -> Html msg
optionToSlottedOptionHtml eventHandlers option =
    case Option.getOptionDisplay option of
        OptionShown optionAge ->
            div
                [ onMouseEnter (option |> Option.getOptionValue |> eventHandlers.mouseOverMsgConstructor)
                , onMouseLeave (option |> Option.getOptionValue |> eventHandlers.mouseOutMsgConstructor)
                , mouseDownPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseDownMsgConstructor)
                , mouseUpPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseUpMsgConstructor)
                , onClickPreventDefault eventHandlers.noOpMsgConstructor
                , Html.Attributes.attribute "part" "dropdown-option"
                , class "option"
                , valueDataAttribute option
                ]
                [ node "slot" [ option |> Option.getSlot |> OptionSlot.toSlotNameAttribute ] [] ]

        OptionHidden ->
            text ""

        OptionSelected int optionAge ->
            div
                [ onMouseEnter (option |> Option.getOptionValue |> eventHandlers.mouseOverMsgConstructor)
                , onMouseLeave (option |> Option.getOptionValue |> eventHandlers.mouseOutMsgConstructor)
                , mouseDownPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseDownMsgConstructor)
                , mouseUpPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseUpMsgConstructor)
                , onClickPreventDefault eventHandlers.noOpMsgConstructor
                , Html.Attributes.attribute "part" "dropdown-option"
                , class "option"
                , valueDataAttribute option
                ]
                [ node "slot" [ option |> Option.getSlot |> OptionSlot.toSlotNameAttribute ] [] ]

        OptionSelectedAndInvalid int validationFailureMessages ->
            div
                [ onMouseEnter (option |> Option.getOptionValue |> eventHandlers.mouseOverMsgConstructor)
                , onMouseLeave (option |> Option.getOptionValue |> eventHandlers.mouseOutMsgConstructor)
                , mouseDownPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseDownMsgConstructor)
                , mouseUpPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseUpMsgConstructor)
                , onClickPreventDefault eventHandlers.noOpMsgConstructor
                , Html.Attributes.attribute "part" "dropdown-option"
                , class "option"
                , valueDataAttribute option
                ]
                [ node "slot" [ option |> Option.getSlot |> OptionSlot.toSlotNameAttribute ] [] ]

        OptionSelectedPendingValidation int ->
            div
                [ onMouseEnter (option |> Option.getOptionValue |> eventHandlers.mouseOverMsgConstructor)
                , onMouseLeave (option |> Option.getOptionValue |> eventHandlers.mouseOutMsgConstructor)
                , mouseDownPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseDownMsgConstructor)
                , mouseUpPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseUpMsgConstructor)
                , onClickPreventDefault eventHandlers.noOpMsgConstructor
                , Html.Attributes.attribute "part" "dropdown-option"
                , class "option"
                , valueDataAttribute option
                ]
                [ node "slot" [ option |> Option.getSlot |> OptionSlot.toSlotNameAttribute ] [] ]

        OptionSelectedHighlighted int ->
            div
                [ onMouseEnter (option |> Option.getOptionValue |> eventHandlers.mouseOverMsgConstructor)
                , onMouseLeave (option |> Option.getOptionValue |> eventHandlers.mouseOutMsgConstructor)
                , mouseDownPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseDownMsgConstructor)
                , mouseUpPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseUpMsgConstructor)
                , onClickPreventDefault eventHandlers.noOpMsgConstructor
                , Html.Attributes.attribute "part" "dropdown-option"
                , class "option"
                , valueDataAttribute option
                ]
                [ node "slot" [ option |> Option.getSlot |> OptionSlot.toSlotNameAttribute ] [] ]

        OptionHighlighted ->
            div
                [ onMouseEnter (option |> Option.getOptionValue |> eventHandlers.mouseOverMsgConstructor)
                , onMouseLeave (option |> Option.getOptionValue |> eventHandlers.mouseOutMsgConstructor)
                , mouseDownPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseDownMsgConstructor)
                , mouseUpPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseUpMsgConstructor)
                , onClickPreventDefault eventHandlers.noOpMsgConstructor
                , Html.Attributes.attribute "part" "dropdown-option"
                , class "option"
                , valueDataAttribute option
                ]
                [ node "slot" [ option |> Option.getSlot |> OptionSlot.toSlotNameAttribute ] [] ]

        OptionActivated ->
            div
                [ onMouseEnter (option |> Option.getOptionValue |> eventHandlers.mouseOverMsgConstructor)
                , onMouseLeave (option |> Option.getOptionValue |> eventHandlers.mouseOutMsgConstructor)
                , mouseDownPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseDownMsgConstructor)
                , mouseUpPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseUpMsgConstructor)
                , onClickPreventDefault eventHandlers.noOpMsgConstructor
                , Html.Attributes.attribute "part" "dropdown-option"
                , class "option"
                , valueDataAttribute option
                ]
                [ node "slot" [ option |> Option.getSlot |> OptionSlot.toSlotNameAttribute ] [] ]

        OptionDisabled optionAge ->
            div
                [ onMouseEnter (option |> Option.getOptionValue |> eventHandlers.mouseOverMsgConstructor)
                , onMouseLeave (option |> Option.getOptionValue |> eventHandlers.mouseOutMsgConstructor)
                , mouseDownPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseDownMsgConstructor)
                , mouseUpPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseUpMsgConstructor)
                , onClickPreventDefault eventHandlers.noOpMsgConstructor
                , Html.Attributes.attribute "part" "dropdown-option"
                , class "option"
                , valueDataAttribute option
                ]
                [ node "slot" [ option |> Option.getSlot |> OptionSlot.toSlotNameAttribute ] [] ]
