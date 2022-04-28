module OptionsUtilities exposing (..)

import List.Extra exposing (groupWhile)
import Maybe.Extra
import Option
    exposing
        ( Option(..)
        , OptionDisplay(..)
        , OptionGroup
        , OptionValue(..)
        , deselectOption
        , getMaybeOptionSearchFilter
        , getOptionDisplay
        , getOptionGroup
        , getOptionLabel
        , getOptionSelectedIndex
        , getOptionValue
        , getOptionValueAsString
        , highlightOption
        , isCustomOption
        , isOptionHighlighted
        , isOptionSelected
        , isOptionSelectedHighlighted
        , isOptionValueInListOfStrings
        , merge2Options
        , newSelectedOption
        , optionIsHighlightable
        , optionToValueLabelTuple
        , optionValueToString
        , optionValuesEqual
        , removeHighlightOption
        , selectOption
        , setLabel
        , setLabelWithString
        , setOptionDisplay
        , stringToOptionValue
        )
import OptionLabel exposing (OptionLabel)
import OptionSearchFilter exposing (OptionSearchResult)
import SelectionMode exposing (SelectedItemPlacementMode(..), SelectionMode(..))
import SortRank exposing (SortRank)


moveHighlightedOptionDown : List Option -> List Option -> List Option
moveHighlightedOptionDown allOptions visibleOptions =
    let
        maybeLowerSibling =
            visibleOptions
                |> findHighlightedOrSelectedOptionIndex
                |> Maybe.andThen (\index -> findClosestHighlightableOptionGoingDown index visibleOptions)
    in
    case maybeLowerSibling of
        Just option ->
            highlightOptionInList option allOptions

        Nothing ->
            case List.head visibleOptions of
                Just firstOption ->
                    highlightOptionInList firstOption allOptions

                Nothing ->
                    allOptions


findClosestHighlightableOptionGoingUp : Int -> List Option -> Maybe Option
findClosestHighlightableOptionGoingUp index options =
    List.Extra.splitAt index options
        |> Tuple.first
        |> List.reverse
        |> List.Extra.find optionIsHighlightable


moveHighlightedOptionUp : List Option -> List Option -> List Option
moveHighlightedOptionUp allOptions visibleOptions =
    let
        maybeHigherSibling =
            visibleOptions
                |> findHighlightedOrSelectedOptionIndex
                |> Maybe.andThen (\index -> findClosestHighlightableOptionGoingUp index visibleOptions)
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


findClosestHighlightableOptionGoingDown : Int -> List Option -> Maybe Option
findClosestHighlightableOptionGoingDown index options =
    List.Extra.splitAt index options
        |> Tuple.second
        |> List.Extra.find optionIsHighlightable


adjustHighlightedOptionAfterSearch : List Option -> List Option -> List Option
adjustHighlightedOptionAfterSearch allOptions visibleOptions =
    case List.head visibleOptions of
        Just firstOption ->
            highlightOptionInList firstOption allOptions

        Nothing ->
            allOptions


selectOptionInList : Option -> List Option -> List Option
selectOptionInList option options =
    selectOptionInListByOptionValue (getOptionValue option) options


selectOptionInListWithIndex : Option -> List Option -> List Option
selectOptionInListWithIndex optionToSelect options =
    let
        notLessThanZero i =
            if i < 0 then
                0

            else
                0

        selectionIndex =
            getOptionSelectedIndex optionToSelect
                |> notLessThanZero

        optionValue =
            getOptionValue optionToSelect
    in
    selectOptionInListByOptionValueWithIndex selectionIndex optionValue options



{- Take a list of options to select and select them all.

   If there are other options that are also selected, leave them as selected.
-}


selectOptionsInList : List Option -> List Option -> List Option
selectOptionsInList optionsToSelect options =
    let
        helper : List Option -> Option -> ( List Option, List Option )
        helper newOptions optionToSelect =
            ( selectOptionInList optionToSelect newOptions, [] )
    in
    List.Extra.mapAccuml helper options optionsToSelect
        |> Tuple.first


selectOptionsInListWithIndex : List Option -> List Option -> List Option
selectOptionsInListWithIndex optionsToSelect options =
    let
        helper : List Option -> Option -> ( List Option, List Option )
        helper newOptions optionToSelect =
            ( selectOptionInListWithIndex optionToSelect newOptions, [] )
    in
    List.Extra.mapAccuml helper options optionsToSelect
        |> Tuple.first



{- This is kind of a strange one it takes a list of options to leave selected and deselects all the rest. -}


deselectEveryOptionExceptOptionsInList : List Option -> List Option -> List Option
deselectEveryOptionExceptOptionsInList optionsNotToDeselect options =
    List.map
        (\option ->
            let
                test : Option -> Bool
                test optionNotToDeselect =
                    optionValuesEqual optionNotToDeselect (getOptionValue option)
            in
            if List.any test optionsNotToDeselect then
                option

            else
                deselectOption option
        )
        options


deselectAllButTheFirstSelectedOptionInList : List Option -> List Option
deselectAllButTheFirstSelectedOptionInList options =
    case List.head (selectedOptions options) of
        Just oneOptionToLeaveSelected ->
            selectSingleOptionInList (getOptionValue oneOptionToLeaveSelected) options

        Nothing ->
            options



{- Look through the list of options, if we find one that matches the given option value
   then select it and return a new list of options with the found option selected.

   If we do not find the option value return the same list of options.
-}


selectOptionInListByOptionValue : OptionValue -> List Option -> List Option
selectOptionInListByOptionValue value options =
    let
        nextSelectedIndex =
            List.foldl
                (\selectedOption highestIndex ->
                    if getOptionSelectedIndex selectedOption > highestIndex then
                        getOptionSelectedIndex selectedOption

                    else
                        highestIndex
                )
                -1
                options
                + 1
    in
    List.map
        (\option_ ->
            if optionValuesEqual option_ value then
                case option_ of
                    Option _ _ _ _ _ _ ->
                        selectOption nextSelectedIndex option_

                    CustomOption _ _ _ _ ->
                        case value of
                            OptionValue valueStr ->
                                selectOption nextSelectedIndex option_
                                    |> setLabelWithString valueStr Nothing

                            EmptyOptionValue ->
                                selectOption nextSelectedIndex option_

                    EmptyOption _ _ ->
                        selectOption nextSelectedIndex option_

            else if isOptionSelected option_ then
                option_

            else
                removeHighlightOption option_
        )
        options


selectOptionInListByOptionValueWithIndex : Int -> OptionValue -> List Option -> List Option
selectOptionInListByOptionValueWithIndex index value options =
    List.map
        (\option_ ->
            if optionValuesEqual option_ value then
                case option_ of
                    Option _ _ _ _ _ _ ->
                        selectOption index option_

                    CustomOption _ _ _ _ ->
                        case value of
                            OptionValue valueStr ->
                                selectOption index option_
                                    |> setLabelWithString valueStr Nothing

                            EmptyOptionValue ->
                                selectOption index option_

                    EmptyOption _ _ ->
                        selectOption index option_

            else if isOptionSelected option_ then
                option_

            else
                removeHighlightOption option_
        )
        options


selectOptionInListByValueStringWithIndex : Int -> String -> List Option -> List Option
selectOptionInListByValueStringWithIndex index valueString options =
    selectOptionInListByOptionValueWithIndex index (OptionValue valueString) options


deselectOptionInListByOptionValue : OptionValue -> List Option -> List Option
deselectOptionInListByOptionValue value options =
    List.map
        (\option_ ->
            if optionValuesEqual option_ value then
                deselectOption option_

            else
                option_
        )
        options


selectHighlightedOption : SelectionMode -> List Option -> List Option
selectHighlightedOption selectionMode options =
    options
        |> List.filter
            (\option ->
                isOptionHighlighted option
            )
        |> List.head
        |> (\maybeOption ->
                case maybeOption of
                    Just option ->
                        case option of
                            Option _ _ value _ _ _ ->
                                case selectionMode of
                                    MultiSelect _ _ ->
                                        selectOptionInListByOptionValue value options
                                            |> clearAnyUnselectedCustomOptions

                                    SingleSelect _ _ _ ->
                                        selectSingleOptionInList value options

                            CustomOption _ _ value _ ->
                                case selectionMode of
                                    MultiSelect _ _ ->
                                        selectOptionInListByOptionValue value options

                                    SingleSelect _ _ _ ->
                                        selectSingleOptionInList value options

                            EmptyOption _ _ ->
                                case selectionMode of
                                    MultiSelect _ _ ->
                                        selectEmptyOption options

                                    SingleSelect _ _ _ ->
                                        selectEmptyOption options

                    Nothing ->
                        options
           )


selectSingleOptionInList : OptionValue -> List Option -> List Option
selectSingleOptionInList value options =
    options
        |> List.map
            (\option_ ->
                if optionValuesEqual option_ value then
                    case option_ of
                        Option _ _ _ _ _ _ ->
                            selectOption 0 option_

                        CustomOption _ _ optionValue _ ->
                            case optionValue of
                                OptionValue valueStr ->
                                    selectOption 0 option_ |> setLabelWithString valueStr Nothing

                                EmptyOptionValue ->
                                    selectOption 0 option_

                        EmptyOption _ _ ->
                            selectOption 0 option_

                else
                    deselectOption option_
            )


selectSingleOptionInListResult : OptionValue -> List Option -> Result String (List Option)
selectSingleOptionInListResult optionValue options =
    if List.any (\option_ -> getOptionValue option_ == optionValue) options then
        (options
            |> List.map
                (\option_ ->
                    if optionValuesEqual option_ optionValue then
                        case option_ of
                            Option _ _ _ _ _ _ ->
                                selectOption 0 option_

                            CustomOption _ _ optionValue_ _ ->
                                case optionValue_ of
                                    OptionValue valueStr ->
                                        selectOption 0 option_ |> setLabelWithString valueStr Nothing

                                    EmptyOptionValue ->
                                        selectOption 0 option_

                            EmptyOption _ _ ->
                                selectOption 0 option_

                    else
                        deselectOption option_
                )
        )
            |> Ok

    else
        Err "That option is not in this list"


selectSingleOptionInListByString : String -> List Option -> List Option
selectSingleOptionInListByString string options =
    selectSingleOptionInList (stringToOptionValue string) options


selectSingleOptionInListByStringOrSelectCustomValue : String -> List Option -> List Option
selectSingleOptionInListByStringOrSelectCustomValue string options =
    case selectSingleOptionInListResult (Option.stringToOptionValue string) options of
        Ok newOptions ->
            newOptions

        Err _ ->
            CustomOption
                (OptionSelected 0)
                (OptionLabel.newWithCleanLabel string Nothing)
                (OptionValue string)
                Nothing
                :: (options
                        |> clearAnyUnselectedCustomOptions
                        |> deselectAllOptionsInOptionsList
                   )


selectEmptyOption : List Option -> List Option
selectEmptyOption options =
    options
        |> List.map
            (\option_ ->
                case option_ of
                    Option _ _ _ _ _ _ ->
                        deselectOption option_

                    CustomOption _ _ _ _ ->
                        deselectOption option_

                    EmptyOption _ _ ->
                        selectOption 0 option_
            )


clearAnyUnselectedCustomOptions : List Option -> List Option
clearAnyUnselectedCustomOptions options =
    List.filter (\option -> not (isCustomOption option && not (isOptionSelected option))) options


addAdditionalOptionsToOptionList : List Option -> List Option -> List Option
addAdditionalOptionsToOptionList currentOptions newOptions =
    let
        currentOptionsWithUpdates =
            List.map
                (\currentOption ->
                    case findOptionByOptionUsingOptionValue currentOption newOptions of
                        Just newOption_ ->
                            merge2Options currentOption newOption_

                        Nothing ->
                            currentOption
                )
                currentOptions

        reallyNewOptions : List Option
        reallyNewOptions =
            List.filter (\newOption_ -> not (isOptionInListOfOptionsByValue newOption_ currentOptions)) newOptions
    in
    reallyNewOptions ++ currentOptionsWithUpdates


addAdditionalOptionsToOptionListWithAutoSortRank : List Option -> List Option -> List Option
addAdditionalOptionsToOptionListWithAutoSortRank currentOptions newOptions =
    let
        nextHighestAutoSortRank : Int
        nextHighestAutoSortRank =
            findHighestAutoSortRank currentOptions + 1
    in
    List.indexedMap
        (\index option ->
            let
                maybeNewSortRank : Maybe SortRank
                maybeNewSortRank =
                    SortRank.newMaybeAutoSortRank (nextHighestAutoSortRank + index)

                optionLabel : OptionLabel
                optionLabel =
                    getOptionLabel option

                updatedOptionLabel : OptionLabel
                updatedOptionLabel =
                    case maybeNewSortRank of
                        Just newSortRank ->
                            OptionLabel.setSortRank newSortRank optionLabel

                        Nothing ->
                            optionLabel
            in
            setLabel updatedOptionLabel option
        )
        newOptions
        |> addAdditionalOptionsToOptionList currentOptions


findHighestAutoSortRank : List Option -> Int
findHighestAutoSortRank options =
    List.foldr
        (\option currentMax ->
            max
                (option
                    |> getOptionLabel
                    |> OptionLabel.getSortRank
                    |> SortRank.getAutoIndexForSorting
                )
                currentMax
        )
        0
        options


removeOptionsFromOptionList : List Option -> List Option -> List Option
removeOptionsFromOptionList options optionsToRemove =
    List.filter (\option -> not (optionListContainsOptionWithValue option optionsToRemove)) options


unhighlightSelectedOptions : List Option -> List Option
unhighlightSelectedOptions =
    List.map
        (\option ->
            case option of
                Option optionDisplay _ _ _ _ _ ->
                    case optionDisplay of
                        OptionShown ->
                            option

                        OptionHidden ->
                            option

                        OptionSelected _ ->
                            option

                        OptionSelectedHighlighted selectedIndex ->
                            setOptionDisplay (OptionSelected selectedIndex) option

                        OptionHighlighted ->
                            option

                        OptionDisabled ->
                            option

                CustomOption optionDisplay _ _ _ ->
                    case optionDisplay of
                        OptionShown ->
                            option

                        OptionHidden ->
                            option

                        OptionSelected _ ->
                            option

                        OptionSelectedHighlighted selectedIndex ->
                            setOptionDisplay (OptionSelected selectedIndex) option

                        OptionHighlighted ->
                            option

                        OptionDisabled ->
                            option

                EmptyOption optionDisplay _ ->
                    case optionDisplay of
                        OptionShown ->
                            option

                        OptionHidden ->
                            option

                        OptionSelected _ ->
                            option

                        OptionSelectedHighlighted selectedIndex ->
                            setOptionDisplay (OptionSelected selectedIndex) option

                        OptionHighlighted ->
                            option

                        OptionDisabled ->
                            option
        )


deselectOptions : List Option -> List Option -> List Option
deselectOptions optionsToDeselect allOptions =
    let
        shouldDeselectOption option =
            -- figure out if options match my looking at their value's
            List.any
                (\optionToDeselect -> getOptionValue optionToDeselect == getOptionValue option)
                optionsToDeselect
    in
    List.map
        (\option ->
            if shouldDeselectOption option then
                deselectOption option

            else
                option
        )
        allOptions


selectedOptions : List Option -> List Option
selectedOptions options =
    options
        |> List.filter isOptionSelected
        |> List.sortBy getOptionSelectedIndex


unselectedOptions : List Option -> List Option
unselectedOptions options =
    options
        |> List.filter (\option -> isOptionSelected option |> not)


toggleSelectedHighlightByOptionValue : List Option -> OptionValue -> List Option
toggleSelectedHighlightByOptionValue options optionValue =
    options
        |> List.map
            (\option_ ->
                case option_ of
                    Option optionDisplay _ optionValue_ _ _ _ ->
                        if optionValue == optionValue_ then
                            case optionDisplay of
                                OptionShown ->
                                    option_

                                OptionHidden ->
                                    option_

                                OptionSelected selectedIndex ->
                                    option_ |> setOptionDisplay (OptionSelectedHighlighted selectedIndex)

                                OptionSelectedHighlighted selectedIndex ->
                                    option_ |> setOptionDisplay (OptionSelected selectedIndex)

                                OptionHighlighted ->
                                    option_

                                OptionDisabled ->
                                    option_

                        else
                            option_

                    CustomOption optionDisplay _ optionValue_ _ ->
                        if optionValue == optionValue_ then
                            case optionDisplay of
                                OptionShown ->
                                    option_

                                OptionHidden ->
                                    option_

                                OptionSelected selectedIndex ->
                                    option_ |> setOptionDisplay (OptionSelectedHighlighted selectedIndex)

                                OptionSelectedHighlighted selectedIndex ->
                                    option_ |> setOptionDisplay (OptionSelected selectedIndex)

                                OptionHighlighted ->
                                    option_

                                OptionDisabled ->
                                    option_

                        else
                            option_

                    EmptyOption _ _ ->
                        option_
            )


deselectAllSelectedHighlightedOptions : List Option -> List Option
deselectAllSelectedHighlightedOptions options =
    options
        |> List.map
            (\option_ ->
                case option_ of
                    Option optionDisplay _ _ _ _ _ ->
                        case optionDisplay of
                            OptionShown ->
                                option_

                            OptionHidden ->
                                option_

                            OptionSelected _ ->
                                option_

                            OptionSelectedHighlighted _ ->
                                option_ |> setOptionDisplay OptionShown

                            OptionHighlighted ->
                                option_

                            OptionDisabled ->
                                option_

                    CustomOption optionDisplay _ _ _ ->
                        case optionDisplay of
                            OptionShown ->
                                option_

                            OptionHidden ->
                                option_

                            OptionSelected _ ->
                                option_

                            OptionSelectedHighlighted _ ->
                                option_ |> setOptionDisplay OptionShown

                            OptionHighlighted ->
                                option_

                            OptionDisabled ->
                                option_

                    EmptyOption _ _ ->
                        option_
            )


deselectLastSelectedOption : List Option -> List Option
deselectLastSelectedOption options =
    let
        maybeLastSelectedOptionValue =
            options
                |> selectedOptions
                |> List.Extra.last
                |> Maybe.map getOptionValue
    in
    case maybeLastSelectedOptionValue of
        Just optionValueToDeselect ->
            deselectOptionInListByOptionValue optionValueToDeselect options

        Nothing ->
            options


hasSelectedHighlightedOptions : List Option -> Bool
hasSelectedHighlightedOptions options =
    List.any isOptionSelectedHighlighted options



{--Clean up custom options, remove all the custom options that are not selected --}


removeUnselectedCustomOptions : List Option -> List Option
removeUnselectedCustomOptions options =
    let
        unselectedCustomOptions =
            options
                |> customOptions
                |> unselectedOptions
    in
    removeOptionsFromOptionList options unselectedCustomOptions


customSelectedOptions : List Option -> List Option
customSelectedOptions =
    customOptions >> selectedOptions


customOptions : List Option -> List Option
customOptions options =
    List.filter isCustomOption options


groupOptionsInOrder : List Option -> List ( OptionGroup, List Option )
groupOptionsInOrder options =
    let
        helper : Option -> Option -> Bool
        helper optionA optionB =
            getOptionGroup optionA == getOptionGroup optionB
    in
    groupWhile helper options
        |> List.map (\( first, rest ) -> ( getOptionGroup first, first :: rest ))


optionListContainsOptionWithValueString : String -> List Option -> Bool
optionListContainsOptionWithValueString valueString options =
    let
        optionValue =
            stringToOptionValue valueString
    in
    List.filter (\option_ -> getOptionValue option_ == optionValue) options
        |> List.isEmpty
        |> not


{-| Return true if the option's (needle's) value matches one of the option's value in the haystack.
-}
optionListContainsOptionWithValue : Option -> List Option -> Bool
optionListContainsOptionWithValue needle haystack =
    let
        optionValue =
            getOptionValue needle
    in
    List.filter (\option_ -> getOptionValue option_ == optionValue) haystack
        |> List.isEmpty
        |> not


hasSelectedOption : List Option -> Bool
hasSelectedOption options =
    options |> selectedOptions |> List.isEmpty |> not


highlightOptionInListByValue : OptionValue -> List Option -> List Option
highlightOptionInListByValue value options =
    List.map
        (\option_ ->
            if optionValuesEqual option_ value then
                highlightOption option_

            else
                removeHighlightOption option_
        )
        options


removeHighlightOptionInList : OptionValue -> List Option -> List Option
removeHighlightOptionInList value options =
    List.map
        (\option_ ->
            if optionValuesEqual option_ value then
                removeHighlightOption option_

            else
                option_
        )
        options


prependCustomOption : Maybe String -> String -> List Option -> List Option
prependCustomOption maybeCustomOptionHint searchString options =
    let
        label =
            case maybeCustomOptionHint of
                Just customOptionHint ->
                    let
                        parts =
                            String.split "{{}}" customOptionHint
                    in
                    case parts of
                        [] ->
                            "Add " ++ searchString ++ "…"

                        [ _ ] ->
                            customOptionHint ++ searchString

                        first :: second :: _ ->
                            first ++ searchString ++ second

                Nothing ->
                    "Add " ++ searchString ++ "…"
    in
    [ CustomOption
        OptionShown
        (OptionLabel.newWithCleanLabel label Nothing)
        (OptionValue searchString)
        Nothing
    ]
        ++ options


findHighlightedOption : List Option -> Maybe Option
findHighlightedOption options =
    List.Extra.find (\option -> isOptionHighlighted option) options


findHighlightedOptionIndex : List Option -> Maybe Int
findHighlightedOptionIndex options =
    List.Extra.findIndex (\option -> isOptionHighlighted option) options


findSelectedOptionIndex : List Option -> Maybe Int
findSelectedOptionIndex options =
    List.Extra.findIndex (\option -> isOptionSelected option) options


findHighlightedOrSelectedOptionIndex : List Option -> Maybe Int
findHighlightedOrSelectedOptionIndex options =
    case findHighlightedOptionIndex options of
        Just index ->
            Just index

        Nothing ->
            findSelectedOptionIndex options


filterOptionsToShowInDropdown : SelectionMode -> List Option -> List Option
filterOptionsToShowInDropdown selectionMode =
    filterOptionsToShowInDropdownByOptionDisplay selectionMode >> filterOptionsToShowInDropdownBySearchScore


filterOptionsToShowInDropdownByOptionDisplay : SelectionMode -> List Option -> List Option
filterOptionsToShowInDropdownByOptionDisplay selectionMode =
    case selectionMode of
        SingleSelect _ _ _ ->
            List.filter
                (\option ->
                    case getOptionDisplay option of
                        OptionShown ->
                            True

                        OptionHidden ->
                            False

                        OptionSelected _ ->
                            True

                        OptionSelectedHighlighted _ ->
                            True

                        OptionHighlighted ->
                            True

                        OptionDisabled ->
                            True
                )

        MultiSelect _ _ ->
            List.filter
                (\option ->
                    case getOptionDisplay option of
                        OptionShown ->
                            True

                        OptionHidden ->
                            False

                        OptionSelected _ ->
                            False

                        OptionSelectedHighlighted _ ->
                            False

                        OptionHighlighted ->
                            True

                        OptionDisabled ->
                            True
                )


filterOptionsToShowInDropdownBySearchScore : List Option -> List Option
filterOptionsToShowInDropdownBySearchScore options =
    case findLowestSearchScore options of
        Just lowScore ->
            List.filter (isOptionBelowScore (OptionSearchFilter.lowScoreCutOff lowScore)) options

        Nothing ->
            options


findLowestSearchScore : List Option -> Maybe Int
findLowestSearchScore options =
    let
        lowSore =
            options
                |> List.filter (\option -> not (isCustomOption option))
                |> optionSearchResults
                |> List.foldl
                    (\searchResult lowScore ->
                        if OptionSearchFilter.getLowScore searchResult < lowScore then
                            OptionSearchFilter.getLowScore searchResult

                        else
                            lowScore
                    )
                    OptionSearchFilter.impossiblyLowScore
    in
    if lowSore == OptionSearchFilter.impossiblyLowScore then
        Nothing

    else
        Just lowSore


optionSearchResults : List Option -> List OptionSearchResult
optionSearchResults options =
    options
        |> List.map getMaybeOptionSearchFilter
        |> Maybe.Extra.values
        |> List.map .searchResult


isOptionBelowScore : Int -> Option -> Bool
isOptionBelowScore score option =
    case getMaybeOptionSearchFilter option of
        Just optionSearchFilter ->
            score >= OptionSearchFilter.getLowScore optionSearchFilter.searchResult

        Nothing ->
            False


highlightOptionInList : Option -> List Option -> List Option
highlightOptionInList option options =
    List.map
        (\option_ ->
            if option == option_ then
                highlightOption option_

            else
                removeHighlightOption option_
        )
        options


highlightFirstOptionInList : List Option -> List Option
highlightFirstOptionInList options =
    case List.head options of
        Just firstOption ->
            highlightOptionInList firstOption options

        Nothing ->
            options


isOptionValueInListOfOptionsByValue : OptionValue -> List Option -> Bool
isOptionValueInListOfOptionsByValue optionValue options =
    List.any (\option -> (option |> getOptionValue |> optionValueToString) == (optionValue |> optionValueToString)) options


isOptionInListOfOptionsByValue : Option -> List Option -> Bool
isOptionInListOfOptionsByValue option options =
    isOptionValueInListOfOptionsByValue (getOptionValue option) options


findOptionByOptionValue : OptionValue -> List Option -> Maybe Option
findOptionByOptionValue optionValue options =
    List.Extra.find (\option -> (option |> getOptionValue) == optionValue) options


findOptionByOptionUsingOptionValue : Option -> List Option -> Maybe Option
findOptionByOptionUsingOptionValue option options =
    findOptionByOptionValue (getOptionValue option) options


findOptionByOptionUsingValueString : String -> List Option -> Maybe Option
findOptionByOptionUsingValueString valueString options =
    findOptionByOptionValue (stringToOptionValue valueString) options


deselectAllOptionsInOptionsList : List Option -> List Option
deselectAllOptionsInOptionsList options =
    List.map
        deselectOption
        options


replaceOptions : SelectionMode -> List Option -> List Option -> List Option
replaceOptions selectionMode oldOptions newOptions =
    let
        oldSelectedOptions =
            selectedOptions oldOptions
    in
    case selectionMode of
        SingleSelect _ selectedItemPlacementMode _ ->
            let
                maybeSelectedOptionValue =
                    selectedOptions (newOptions ++ oldOptions)
                        |> List.head
                        |> Maybe.map getOptionValue
            in
            case maybeSelectedOptionValue of
                Just selectedOptionValue ->
                    mergeTwoListsOfOptionsPreservingSelectedOptions
                        selectedItemPlacementMode
                        oldSelectedOptions
                        newOptions
                        |> selectSingleOptionInList selectedOptionValue
                        |> List.filter
                            (\option ->
                                isOptionSelected option || List.member option newOptions
                            )

                Nothing ->
                    mergeTwoListsOfOptionsPreservingSelectedOptions
                        selectedItemPlacementMode
                        oldSelectedOptions
                        newOptions

        MultiSelect _ _ ->
            mergeTwoListsOfOptionsPreservingSelectedOptions
                SelectedItemStaysInPlace
                oldSelectedOptions
                newOptions


{-| This function is a little strange but here's what it does. It takes 2 lists of option.
First it looks to see if any option values the second list match any option values in the first list
If they do it takes the label, description, and group from the option in second list and uses it to update
the option in the first list.

Then it concatenates the 2 lists together and filters them by unique option value, dropping identical
values later in the list.

The idea here is that the label, description, and group can be updated for existing option and new options
can be added at the same time.

One place this comes up is when we have an initial value for a MuchSelect, and then later the "full" list of options
comes in, including the extra stuff (like label, description, and group).
|

-}
mergeTwoListsOfOptionsPreservingSelectedOptions : SelectedItemPlacementMode -> List Option -> List Option -> List Option
mergeTwoListsOfOptionsPreservingSelectedOptions selectedItemPlacementMode optionsA optionsB =
    let
        updatedOptionsA =
            List.map
                (\optionA ->
                    case findOptionByOptionValue (getOptionValue optionA) optionsB of
                        Just optionB ->
                            merge2Options optionA optionB

                        Nothing ->
                            optionA
                )
                optionsA

        updatedOptionsB =
            List.map
                (\optionB ->
                    case findOptionByOptionValue (getOptionValue optionB) optionsA of
                        Just optionA ->
                            merge2Options optionA optionB

                        Nothing ->
                            optionB
                )
                optionsB

        superList =
            case selectedItemPlacementMode of
                SelectedItemStaysInPlace ->
                    updatedOptionsB ++ updatedOptionsA

                SelectedItemMovesToTheTop ->
                    updatedOptionsA
                        ++ updatedOptionsB

        newOptions =
            List.Extra.uniqueBy getOptionValueAsString superList
    in
    setSelectedOptionInNewOptions superList newOptions


selectedOptionsToTuple : List Option -> List ( String, String )
selectedOptionsToTuple options =
    options |> selectedOptions |> List.map optionToValueLabelTuple


optionsValues : List Option -> List String
optionsValues options =
    List.map getOptionValueAsString options



{- This takes a list of string and a list of options.
   Then it selects any matching options (looking at values of the options).

   It also deselects any options that are NOT in the the list of string.
-}


selectOptionsInOptionsListByString : List String -> List Option -> List Option
selectOptionsInOptionsListByString strings options =
    let
        optionsToSelect =
            List.filter (isOptionValueInListOfStrings strings) options
    in
    selectOptionsInList optionsToSelect options
        |> deselectEveryOptionExceptOptionsInList optionsToSelect


addAndSelectOptionsInOptionsListByString : List String -> List Option -> List Option
addAndSelectOptionsInOptionsListByString strings options =
    let
        helper : Int -> List String -> List Option -> List Option
        helper index valueStrings options_ =
            case valueStrings of
                [] ->
                    options_

                [ valueString ] ->
                    if optionListContainsOptionWithValueString valueString options_ then
                        selectOptionInListByValueStringWithIndex index valueString options_

                    else
                        options_ ++ [ newSelectedOption index valueString Nothing ]

                valueString :: restOfValueStrings ->
                    if optionListContainsOptionWithValueString valueString options_ then
                        helper (index + 1) restOfValueStrings (selectOptionInListByValueStringWithIndex index valueString options_)

                    else
                        helper (index + 1) restOfValueStrings (options_ ++ [ newSelectedOption index valueString Nothing ])
    in
    helper 0 strings options


setSelectedOptionInNewOptions : List Option -> List Option -> List Option
setSelectedOptionInNewOptions oldOptions newOptions =
    let
        oldSelectedOption : List Option
        oldSelectedOption =
            oldOptions |> selectedOptions

        newSelectedOptions : List Option
        newSelectedOptions =
            List.filter (\newOption_ -> optionListContainsOptionWithValue newOption_ oldSelectedOption) newOptions
    in
    selectOptionsInListWithIndex newSelectedOptions newOptions
