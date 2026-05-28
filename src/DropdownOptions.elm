module DropdownOptions exposing (DropdownOptions, dropdownOptionsToDatalistOption, dropdownOptionsToSlottedOptionsHtml, figureOutWhichOptionsToShowInTheDropdown, figureOutWhichOptionsToShowInTheDropdownThatAreNotSelected, filterOptionsToShowInDropdownBySearchScore, getSearchFilters, groupInOrder, head, isEmpty, length, maybeFirstOptionSearchFilter, moveHighlightedOptionDown, moveHighlightedOptionDownIfThereAreOptions, moveHighlightedOptionUp, optionsToCustomHtml, test_fromOptions, test_getOptions)

import DropdownItemEventListeners exposing (DropdownItemEventListeners)
import Events exposing (mouseDownPreventDefault, mouseUpPreventDefault, onClickPreventDefault)
import FancyOption
import Html exposing (Html, div, node, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onMouseEnter, onMouseLeave)
import Html.Extra
import Html.Lazy
import List.Extra
import Option exposing (Option(..))
import OptionDisplay exposing (OptionDisplay(..))
import OptionGroup exposing (OptionGroup)
import OptionList exposing (OptionList)
import OptionSearchFilter exposing (OptionSearchFilter)
import OptionSlot
import OutputStyle
import PartAttribute
import PositiveInt
import SelectionMode exposing (SelectionConfig, getMaxDropdownItems)


type DropdownOptions
    = AllTheOptions OptionList
    | FilteredOptions PositiveInt.PositiveInt OptionList
    | FilterFoundNoOptions
    | NoOptions
    | OptionsThatAreNotSelected OptionList
    | OptionsAreAllSelected


{-| This function is responsible for figuring out which options should be shown in the dropdown.

Once it does it's work it wraps it in a special type, flagging this list of options as just
the options that are supposed to be shown in the dropdown.

-}
figureOutWhichOptionsToShowInTheDropdown : SelectionConfig -> OptionList -> DropdownOptions
figureOutWhichOptionsToShowInTheDropdown selectionConfig optionList =
    case SelectionMode.getOutputStyle selectionConfig of
        SelectionMode.Datalist ->
            AllTheOptions optionList

        SelectionMode.CustomHtml ->
            customHtmlHelper selectionConfig optionList


customHtmlHelper : SelectionConfig -> OptionList -> DropdownOptions
customHtmlHelper selectionConfig optionList =
    let
        optionsThatCouldBeShown = filterOptionsToShowInDropdown selectionConfig optionList
    in
    case SelectionMode.getSelectionMode selectionConfig of
        SelectionMode.SingleSelect ->
            case getMaxDropdownItems selectionConfig of
                OutputStyle.FixedMaxDropdownItems maxDropdownItems ->
                    limitTheNumberOfVisibleOptions optionList lastIndexOfOptions maxDropdownItems optionsThatCouldBeShown

                OutputStyle.NoLimitToDropdownItems ->
                    DropdownOptions optionsThatCouldBeShown

        SelectionMode.MultiSelect ->
            if OptionList.any (Option.isSelected >> not) optionList then
                DropdownOptionsAreAllSelected optionList

            else
                case getMaxDropdownItems selectionConfig of
                    OutputStyle.FixedMaxDropdownItems maxDropdownItems ->
                        limitTheNumberOfVisibleOptions optionList lastIndexOfOptions maxDropdownItems optionsThatCouldBeShown

                    OutputStyle.NoLimitToDropdownItems ->
                        DropdownOptions optionsThatCouldBeShown


figureOutWhichOptionsToShowInTheDropdownThatAreNotSelected : SelectionConfig -> OptionList -> DropdownOptions
figureOutWhichOptionsToShowInTheDropdownThatAreNotSelected selectionConfig optionList =
    let
        visibleOptions =
            figureOutWhichOptionsToShowInTheDropdown selectionConfig optionList |> getOptions
    in
    DropdownOptionsThatAreNotSelected (OptionList.unselectedOptions visibleOptions)


filterOptionsToShowInDropdown : SelectionConfig -> OptionList -> DropdownOptions
filterOptionsToShowInDropdown selectionConfig =
    (filterOptionsToShowInDropdownByOptionDisplay selectionConfig
        >> filterOptionsToShowInDropdownBySearchScore
    )
        |> OptionList.sortOptionsByBestScore


filterOptionsToShowInDropdownByOptionDisplay : SelectionConfig -> OptionList -> OptionList
filterOptionsToShowInDropdownByOptionDisplay selectionConfig =
    case SelectionMode.getSelectionMode selectionConfig of
        SelectionMode.SingleSelect ->
            OptionList.filter
                OptionList.singleSelectOptionDisplayFilter

        SelectionMode.MultiSelect ->
            OptionList.filter
                OptionList.multiSelectOptionDisplayFilter


filterOptionsToShowInDropdownBySearchScore : OptionList -> DropdownOptions
filterOptionsToShowInDropdownBySearchScore optionList =
    case OptionList.findLowestSearchScore optionList of
        Just lowScore ->
            OptionList.filter
                (\option ->
                    Option.isBelowSearchFilterScore (OptionSearchFilter.lowScoreCutOff lowScore) option
                        || Option.isCustomOption option
                )
                optionList

        Nothing ->
            optionList


limitTheNumberOfVisibleOptions : OptionList -> PositiveInt.PositiveInt -> DropdownOptions -> DropdownOptions
limitTheNumberOfVisibleOptions optionList maxDropdownItems dropdownOptions =
    case dropdownOptions of
        AllTheOptions optionsThatCouldBeShown ->
            if PositiveInt.greaterThan maxDropdownItems (OptionList.length optionsThatCouldBeShown) then
                    AllTheOptions optionsThatCouldBeShown

                else
                    case OptionList.findHighlightedOrSelectedOptionIndex optionsThatCouldBeShown of
                        Just index ->
                            case index of
                                0 ->
                                    FilteredOptions maxDropdownItems (OptionList.takePositiveInt maxDropdownItems optionsThatCouldBeShown)

                                _ ->
                                    if index == OptionList.length optionsThatCouldBeShown - 1 then
                                        FilteredOptions maxDropdownItems  (OptionList.drop (OptionList.length optionList - maxDropdownItems) optionsThatCouldBeShown)

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
                                            DropdownOptions (OptionList.drop (OptionList.length optionList - maxNumberOfDropdownItems) optionsThatCouldBeShown)

                                        else if index - half < 0 then
                                            -- The "window" runs off the "head" of the list, so just take the first options
                                            DropdownOptions (OptionList.take maxNumberOfDropdownItems optionsThatCouldBeShown)

                                        else
                                            DropdownOptions (optionList |> OptionList.drop (index + 1 - half) |> OptionList.take maxNumberOfDropdownItems)

                        Nothing ->
                            DropdownOptions (OptionList.take maxNumberOfDropdownItems optionList)

        FilteredOptions optionsLength optionsThatCouldBeShown ->






getOptions : DropdownOptions -> OptionList
getOptions dropdownOptions =
    case dropdownOptions of
        DropdownOptions options ->
            options

        DropdownOptionsThatAreNotSelected options ->
            options

        DropdownOptionsAreAllSelected options ->
            options


isEmpty : DropdownOptions -> Bool
isEmpty dropdownOptions =
    dropdownOptions |> getOptions |> OptionList.isEmpty


length : DropdownOptions -> Int
length dropdownOptions =
    dropdownOptions |> getOptions |> OptionList.length


head : DropdownOptions -> Maybe Option
head dropdownOptions =
    dropdownOptions |> getOptions |> OptionList.head


test_getOptions : DropdownOptions -> OptionList
test_getOptions dropdownOptions =
    getOptions dropdownOptions


test_fromOptions : OptionList -> DropdownOptions
test_fromOptions options =
    DropdownOptions options


getSearchFilters : DropdownOptions -> List (Maybe OptionSearchFilter)
getSearchFilters dropdownOptions =
    dropdownOptions
        |> getOptions
        |> OptionList.getOptions
        |> List.map
            (\option ->
                Option.getMaybeOptionSearchFilter option
            )


groupInOrder : DropdownOptions -> List ( OptionGroup, DropdownOptions )
groupInOrder dropdownOptions =
    let
        helper : Option -> Option -> Bool
        helper optionA optionB =
            Option.getOptionGroup optionA == Option.getOptionGroup optionB
    in
    List.Extra.groupWhile helper (dropdownOptions |> getOptions |> OptionList.getOptions)
        |> List.map
            (\( firstOption, restOfOptions ) ->
                ( Option.getOptionGroup firstOption
                , DropdownOptions (OptionList.optionsPlusOne firstOption restOfOptions)
                )
            )


maybeFirstOptionSearchFilter : DropdownOptions -> Maybe OptionSearchFilter
maybeFirstOptionSearchFilter dropdownOptions =
    case dropdownOptions of
        DropdownOptions options ->
            OptionList.head options
                |> Maybe.andThen Option.getMaybeOptionSearchFilter

        DropdownOptionsThatAreNotSelected options ->
            OptionList.head options
                |> Maybe.andThen Option.getMaybeOptionSearchFilter

        DropdownOptionsAreAllSelected options ->
            OptionList.head options
                |> Maybe.andThen Option.getMaybeOptionSearchFilter


moveHighlightedOptionUp : SelectionConfig -> OptionList -> OptionList
moveHighlightedOptionUp selectionConfig optionList =
    let
        visibleOptions =
            figureOutWhichOptionsToShowInTheDropdown selectionConfig optionList |> getOptions

        maybeHigherSibling =
            visibleOptions
                |> OptionList.findHighlightedOrSelectedOptionIndex
                |> Maybe.andThen
                    (\index ->
                        OptionList.findClosestHighlightableOptionGoingUp
                            (SelectionMode.getSelectionMode selectionConfig)
                            index
                            visibleOptions
                    )
    in
    case maybeHigherSibling of
        Just option ->
            OptionList.changeHighlightedOption option optionList

        Nothing ->
            case OptionList.head visibleOptions of
                Just firstOption ->
                    OptionList.changeHighlightedOption firstOption optionList

                Nothing ->
                    optionList


moveHighlightedOptionDown : SelectionConfig -> OptionList -> OptionList
moveHighlightedOptionDown selectionConfig allOptions =
    let
        visibleOptions =
            figureOutWhichOptionsToShowInTheDropdown selectionConfig allOptions |> getOptions

        maybeLowerSibling =
            visibleOptions
                |> OptionList.findHighlightedOrSelectedOptionIndex
                |> Maybe.andThen
                    (\index ->
                        OptionList.findClosestHighlightableOptionGoingDown
                            (SelectionMode.getSelectionMode selectionConfig)
                            index
                            visibleOptions
                    )
    in
    case maybeLowerSibling of
        Just option ->
            OptionList.changeHighlightedOption option allOptions

        Nothing ->
            -- If there is not a lower sibling to highlight, jump up to the top of the list, and see
            --  if there is a sibling to highlight at the top of the dropdown. There might not be,
            --  the dropdown might be empty or all the options might be selected.
            case
                OptionList.findClosestHighlightableOptionGoingDown
                    (SelectionMode.getSelectionMode selectionConfig)
                    0
                    visibleOptions
            of
                Just firstOption ->
                    OptionList.changeHighlightedOption firstOption allOptions

                Nothing ->
                    allOptions


moveHighlightedOptionDownIfThereAreOptions : SelectionConfig -> OptionList -> OptionList
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


optionsToCustomHtml : DropdownItemEventListeners msg -> SelectionConfig -> DropdownOptions -> List (Html msg)
optionsToCustomHtml dropdownItemEventListeners selectionConfig dropdownOptions =
    case dropdownOptions of
        DropdownOptions options ->
            OptionList.andMap (optionToCustomHtml dropdownItemEventListeners selectionConfig) options

        DropdownOptionsThatAreNotSelected options ->
            OptionList.andMap (optionToCustomHtml dropdownItemEventListeners selectionConfig) options

        DropdownOptionsAreAllSelected _ ->
            []


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
            case option of
                FancyOption fancyOption ->
                    FancyOption.toDropdownHtml eventHandlers (SelectionMode.getSelectionMode selectionConfig) fancyOption

                _ ->
                    Html.Extra.nothing
        )
        selectionConfig_
        option_


dropdownOptionsToDatalistOption : DropdownOptions -> List (Html msg)
dropdownOptionsToDatalistOption dropdownOptions =
    OptionList.andMap optionToDatalistOption (getOptions dropdownOptions)


optionToDatalistOption : Option -> Html msg
optionToDatalistOption option =
    Html.option [ Html.Attributes.value (Option.getOptionValueAsString option) ] []


dropdownOptionsToSlottedOptionsHtml : DropdownItemEventListeners msg -> DropdownOptions -> List (Html msg)
dropdownOptionsToSlottedOptionsHtml eventHandlers options =
    OptionList.andMap (optionToSlottedOptionHtml eventHandlers) (getOptions options)


optionToSlottedOptionHtml : DropdownItemEventListeners msg -> Option -> Html msg
optionToSlottedOptionHtml eventHandlers option =
    case Option.getOptionDisplay option of
        OptionShown _ ->
            div
                [ onMouseEnter (option |> Option.getOptionValue |> eventHandlers.mouseOverMsgConstructor)
                , onMouseLeave (option |> Option.getOptionValue |> eventHandlers.mouseOutMsgConstructor)
                , mouseDownPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseDownMsgConstructor)
                , mouseUpPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseUpMsgConstructor)
                , onClickPreventDefault eventHandlers.noOpMsgConstructor
                , PartAttribute.part "dropdown-option"
                , class "option"
                , valueDataAttribute option
                ]
                [ node "slot" [ option |> Option.getSlot |> OptionSlot.toSlotNameAttribute ] [] ]

        OptionHidden ->
            text ""

        OptionSelected _ _ ->
            div
                [ onMouseEnter (option |> Option.getOptionValue |> eventHandlers.mouseOverMsgConstructor)
                , onMouseLeave (option |> Option.getOptionValue |> eventHandlers.mouseOutMsgConstructor)
                , mouseDownPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseDownMsgConstructor)
                , mouseUpPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseUpMsgConstructor)
                , onClickPreventDefault eventHandlers.noOpMsgConstructor
                , PartAttribute.part "dropdown-option selected"
                , class "option selected"
                , valueDataAttribute option
                ]
                [ node "slot" [ option |> Option.getSlot |> OptionSlot.toSlotNameAttribute ] [] ]

        OptionSelectedAndInvalid _ _ ->
            text ""

        OptionSelectedPendingValidation _ ->
            div
                [ PartAttribute.part "dropdown-option disabled pending-validation"
                , class "option disabled pending-validation"
                , valueDataAttribute option
                ]
                [ node "slot" [ option |> Option.getSlot |> OptionSlot.toSlotNameAttribute ] [] ]

        OptionSelectedHighlighted _ ->
            div
                [ onMouseEnter (option |> Option.getOptionValue |> eventHandlers.mouseOverMsgConstructor)
                , onMouseLeave (option |> Option.getOptionValue |> eventHandlers.mouseOutMsgConstructor)
                , mouseDownPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseDownMsgConstructor)
                , mouseUpPreventDefault (option |> Option.getOptionValue |> eventHandlers.mouseUpMsgConstructor)
                , onClickPreventDefault eventHandlers.noOpMsgConstructor
                , PartAttribute.part "dropdown-option selected highlighted"
                , class "option selected highlighted"
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
                , PartAttribute.part "dropdown-option selected highlighted"
                , class "option highlighted"
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
                , PartAttribute.part "dropdown-option active highlighted"
                , class "option active highlighted"
                , valueDataAttribute option
                ]
                [ node "slot" [ option |> Option.getSlot |> OptionSlot.toSlotNameAttribute ] [] ]

        OptionDisabled _ ->
            div
                [ PartAttribute.part "dropdown-option disabled"
                , class "option disabled"
                , valueDataAttribute option
                ]
                [ node "slot" [ option |> Option.getSlot |> OptionSlot.toSlotNameAttribute ] [] ]
