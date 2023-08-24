module OptionsUtilities exposing (..)

import List.Extra
import Maybe.Extra
import Option
    exposing
        ( Option(..)
        , deselectOption
        , getMaybeOptionSearchFilter
        , getOptionDisplay
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
        , newSelectedOption
        , optionIsHighlightable
        , optionToValueLabelTuple
        , optionValuesEqual
        , removeHighlightFromOption
        , setLabel
        , setLabelWithString
        , setOptionDisplay
        )
import OptionDisplay exposing (OptionDisplay(..))
import OptionLabel exposing (OptionLabel)
import OptionSearchFilter exposing (OptionSearchFilterWithValue, OptionSearchResult)
import OptionValue
    exposing
        ( OptionValue(..)
        , optionValueToString
        , stringToOptionValue
        )
import OutputStyle exposing (SelectedItemPlacementMode(..))
import PositiveInt
import SearchString exposing (SearchString)
import SelectionMode exposing (SelectionConfig(..), SelectionMode, getSelectedItemPlacementMode)
import SortRank exposing (SortRank)
import TransformAndValidate exposing (ValidationErrorMessage, ValidationFailureMessage)


highlightOptionInListByValue : OptionValue -> List Option -> List Option
highlightOptionInListByValue value options =
    List.map
        (\option_ ->
            if optionValuesEqual option_ value then
                highlightOption option_

            else
                removeHighlightFromOption option_
        )
        options


removeHighlightOptionInList : OptionValue -> List Option -> List Option
removeHighlightOptionInList value options =
    List.map
        (\option_ ->
            if optionValuesEqual option_ value then
                removeHighlightFromOption option_

            else
                option_
        )
        options


prependCustomOption : Maybe String -> SearchString -> List Option -> List Option
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
                            "Add " ++ SearchString.toString searchString ++ "…"

                        [ _ ] ->
                            customOptionHint ++ SearchString.toString searchString

                        first :: second :: _ ->
                            first ++ SearchString.toString searchString ++ second

                Nothing ->
                    "Add " ++ SearchString.toString searchString ++ "…"
    in
    [ CustomOption
        (OptionShown OptionDisplay.MatureOption)
        (OptionLabel.newWithCleanLabel label Nothing)
        (OptionValue (SearchString.toString searchString))
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


filterOptionsToShowInDropdown : SelectionConfig -> List Option -> List Option
filterOptionsToShowInDropdown selectionConfig =
    filterOptionsToShowInDropdownByOptionDisplay selectionConfig
        >> filterOptionsToShowInDropdownBySearchScore


filterOptionsToShowInDropdownByOptionDisplay : SelectionConfig -> List Option -> List Option
filterOptionsToShowInDropdownByOptionDisplay selectionConfig =
    case SelectionMode.getSelectionMode selectionConfig of
        SelectionMode.SingleSelect ->
            List.filter
                (\option ->
                    case getOptionDisplay option of
                        OptionShown age ->
                            case age of
                                OptionDisplay.NewOption ->
                                    False

                                OptionDisplay.MatureOption ->
                                    True

                        OptionHidden ->
                            False

                        OptionSelected _ age ->
                            case age of
                                OptionDisplay.NewOption ->
                                    False

                                OptionDisplay.MatureOption ->
                                    True

                        OptionSelectedPendingValidation _ ->
                            True

                        OptionSelectedAndInvalid _ _ ->
                            False

                        OptionSelectedHighlighted _ ->
                            True

                        OptionHighlighted ->
                            True

                        OptionDisabled age ->
                            case age of
                                OptionDisplay.NewOption ->
                                    False

                                OptionDisplay.MatureOption ->
                                    True

                        OptionActivated ->
                            True
                )

        SelectionMode.MultiSelect ->
            List.filter
                (\option ->
                    case getOptionDisplay option of
                        OptionShown age ->
                            case age of
                                OptionDisplay.NewOption ->
                                    False

                                OptionDisplay.MatureOption ->
                                    True

                        OptionHidden ->
                            False

                        OptionSelected _ age ->
                            case age of
                                OptionDisplay.NewOption ->
                                    False

                                OptionDisplay.MatureOption ->
                                    True

                        OptionSelectedPendingValidation _ ->
                            True

                        OptionSelectedAndInvalid _ _ ->
                            False

                        OptionSelectedHighlighted _ ->
                            False

                        OptionHighlighted ->
                            True

                        OptionDisabled age ->
                            case age of
                                OptionDisplay.NewOption ->
                                    False

                                OptionDisplay.MatureOption ->
                                    True

                        OptionActivated ->
                            True
                )


filterOptionsToShowInDropdownBySearchScore : List Option -> List Option
filterOptionsToShowInDropdownBySearchScore options =
    case findLowestSearchScore options of
        Just lowScore ->
            List.filter
                (\option ->
                    isOptionBelowScore (OptionSearchFilter.lowScoreCutOff lowScore) option
                        || isCustomOption option
                )
                options

        Nothing ->
            options


findLowestSearchScore : List Option -> Maybe Int
findLowestSearchScore options =
    let
        lowSore =
            options
                |> List.filter (\option -> not (isCustomOption option))
                |> optionSearchResultsBestScore
                |> List.foldl
                    (\optionBestScore lowScore ->
                        if optionBestScore < lowScore then
                            optionBestScore

                        else
                            lowScore
                    )
                    OptionSearchFilter.impossiblyLowScore
    in
    if lowSore == OptionSearchFilter.impossiblyLowScore then
        Nothing

    else
        Just lowSore


optionSearchResultsBestScore : List Option -> List Int
optionSearchResultsBestScore options =
    options
        |> List.map getMaybeOptionSearchFilter
        |> Maybe.Extra.values
        |> List.map .bestScore


isOptionBelowScore : Int -> Option -> Bool
isOptionBelowScore score option =
    case getMaybeOptionSearchFilter option of
        Just optionSearchFilter ->
            score >= optionSearchFilter.bestScore

        Nothing ->
            False


sortOptionsByBestScore : List Option -> List Option
sortOptionsByBestScore options =
    List.sortBy
        (\option ->
            if isCustomOption option then
                1

            else
                getMaybeOptionSearchFilter option
                    |> Maybe.map .bestScore
                    |> Maybe.withDefault OptionSearchFilter.impossiblyLowScore
        )
        options


highlightOptionInList : Option -> List Option -> List Option
highlightOptionInList option options =
    List.map
        (\option_ ->
            if option == option_ then
                highlightOption option_

            else
                removeHighlightFromOption option_
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


updateDatalistOptionsWithValue : OptionValue -> Int -> List Option -> List Option
updateDatalistOptionsWithValue optionValue selectedValueIndex options =
    if List.any (Option.hasSelectedItemIndex selectedValueIndex) options then
        updateDatalistOptionWithValueBySelectedValueIndex [] optionValue selectedValueIndex options

    else
        newSelectedDatalistOption optionValue selectedValueIndex :: options


updateDatalistOptionsWithValueAndErrors : List ValidationFailureMessage -> OptionValue -> Int -> List Option -> List Option
updateDatalistOptionsWithValueAndErrors errors optionValue selectedValueIndex options =
    if List.any (Option.hasSelectedItemIndex selectedValueIndex) options then
        updateDatalistOptionWithValueBySelectedValueIndex errors optionValue selectedValueIndex options

    else
        newSelectedDatalistOptionWithErrors errors optionValue selectedValueIndex :: options


updateDatalistOptionsWithPendingValidation : OptionValue -> Int -> List Option -> List Option
updateDatalistOptionsWithPendingValidation optionValue selectedValueIndex options =
    if List.any (Option.hasSelectedItemIndex selectedValueIndex) options then
        updateDatalistOptionWithValueBySelectedValueIndexPendingValidation optionValue selectedValueIndex options

    else
        newSelectedDatalistOptionPendingValidation optionValue selectedValueIndex :: options


addNewEmptyOptionAtIndex : Int -> List Option -> List Option
addNewEmptyOptionAtIndex index options =
    let
        firstPart =
            List.take index options

        secondPart =
            List.drop index options
    in
    (firstPart
        ++ [ DatalistOption (OptionSelected index OptionDisplay.MatureOption) EmptyOptionValue ]
        ++ secondPart
    )
        |> reIndexSelectedOptions


updateDatalistOptionWithValueBySelectedValueIndex : List ValidationFailureMessage -> OptionValue -> Int -> List Option -> List Option
updateDatalistOptionWithValueBySelectedValueIndex errors optionValue selectedIndex options =
    if List.isEmpty errors then
        List.map
            (\option ->
                if Option.getOptionSelectedIndex option == selectedIndex then
                    Option.setOptionValue optionValue option
                        |> Option.setOptionDisplay (OptionSelected selectedIndex OptionDisplay.MatureOption)

                else
                    option
            )
            options

    else
        List.map
            (\option ->
                if Option.getOptionSelectedIndex option == selectedIndex then
                    option
                        |> Option.setOptionValue optionValue
                        |> Option.setOptionValueErrors errors

                else
                    option
            )
            options


updateDatalistOptionWithValueBySelectedValueIndexPendingValidation : OptionValue -> Int -> List Option -> List Option
updateDatalistOptionWithValueBySelectedValueIndexPendingValidation optionValue selectedIndex options =
    List.map
        (\option ->
            if Option.getOptionSelectedIndex option == selectedIndex then
                Option.setOptionValue optionValue option
                    |> Option.setOptionDisplay (OptionSelectedPendingValidation selectedIndex)

            else
                option
        )
        options


deselectAllOptionsInOptionsList : List Option -> List Option
deselectAllOptionsInOptionsList options =
    List.map
        deselectOption
        options


replaceOptions : SelectionConfig -> List Option -> List Option -> List Option
replaceOptions selectionConfig oldOptions newOptions =
    let
        oldSelectedOptions =
            case SelectionMode.getSelectionMode selectionConfig of
                SelectionMode.SingleSelect ->
                    if hasSelectedOption newOptions then
                        []

                    else
                        selectedOptions oldOptions

                SelectionMode.MultiSelect ->
                    selectedOptions oldOptions
                        |> transformOptionsToOutputStyle (SelectionMode.getOutputStyle selectionConfig)
    in
    case SelectionMode.getOutputStyle selectionConfig of
        SelectionMode.CustomHtml ->
            case SelectionMode.getSelectionMode selectionConfig of
                SelectionMode.SingleSelect ->
                    mergeTwoListsOfOptionsPreservingSelectedOptions
                        (SelectionMode.getSelectionMode selectionConfig)
                        (getSelectedItemPlacementMode selectionConfig)
                        oldSelectedOptions
                        newOptions

                SelectionMode.MultiSelect ->
                    mergeTwoListsOfOptionsPreservingSelectedOptions
                        (SelectionMode.getSelectionMode selectionConfig)
                        SelectedItemStaysInPlace
                        oldSelectedOptions
                        newOptions

        SelectionMode.Datalist ->
            let
                optionsForTheDatasetHints =
                    newOptions
                        |> List.filter (Option.isOptionSelected >> not)
                        |> List.map Option.deselectOption
                        |> List.Extra.uniqueBy Option.getOptionValue
                        |> removeEmptyOptions

                --TODO add any new selected options from the new options.
                -- This is only going to be helpful when changing the selected attribute options in the DOM
                newSelectedOptions =
                    oldSelectedOptions
            in
            newSelectedOptions ++ optionsForTheDatasetHints


{-| This function is a little strange but here's what it does. It takes 2 lists of options.
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
mergeTwoListsOfOptionsPreservingSelectedOptions : SelectionMode.SelectionMode -> SelectedItemPlacementMode -> List Option -> List Option -> List Option
mergeTwoListsOfOptionsPreservingSelectedOptions selectionMode selectedItemPlacementMode optionsA optionsB =
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

                SelectedItemIsHidden ->
                    updatedOptionsB ++ updatedOptionsA

        newOptions =
            List.Extra.uniqueBy getOptionValueAsString superList
    in
    setSelectedOptionInNewOptions selectionMode superList newOptions


transformOptionsToOutputStyle : SelectionMode.OutputStyle -> List Option -> List Option
transformOptionsToOutputStyle outputStyle options =
    List.map (Option.transformOptionForOutputStyle outputStyle) options
        |> Maybe.Extra.values


selectedOptionsToTuple : List Option -> List ( String, String )
selectedOptionsToTuple options =
    options |> selectedOptions |> List.map optionToValueLabelTuple


optionsValues : List Option -> List String
optionsValues options =
    List.map getOptionValueAsString options



{- This takes a list of strings and a list of options.
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


selectedOptionValuesAreEqual : List String -> List Option -> Bool
selectedOptionValuesAreEqual valuesAsStrings options =
    (options |> selectedOptions |> optionsValues) == valuesAsStrings


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


setSelectedOptionInNewOptions : SelectionMode.SelectionMode -> List Option -> List Option -> List Option
setSelectedOptionInNewOptions selectionMode oldOptions newOptions =
    let
        oldSelectedOption : List Option
        oldSelectedOption =
            oldOptions |> selectedOptions

        newSelectedOptions : List Option
        newSelectedOptions =
            List.filter (\newOption_ -> optionListContainsOptionWithValue newOption_ oldSelectedOption) newOptions
    in
    case selectionMode of
        SelectionMode.SingleSelect ->
            newOptions
                |> deselectAllOptionsInOptionsList
                |> selectOptionsInListWithIndex (List.take 1 newSelectedOptions)

        SelectionMode.MultiSelect ->
            selectOptionsInListWithIndex newSelectedOptions newOptions


updateOptionsWithNewSearchResults : List OptionSearchFilterWithValue -> List Option -> List Option
updateOptionsWithNewSearchResults optionSearchFilterWithValues options =
    let
        findNewSearchFilterResult : OptionValue -> List OptionSearchFilterWithValue -> Maybe OptionSearchFilterWithValue
        findNewSearchFilterResult optionValue results =
            List.Extra.find (\result -> result.value == optionValue) results
    in
    List.map
        (\option ->
            case findNewSearchFilterResult (Option.getOptionValue option) optionSearchFilterWithValues of
                Just result ->
                    Option.setOptionSearchFilter result.maybeSearchFilter option

                Nothing ->
                    Option.setOptionSearchFilter Nothing option
        )
        options



--equal : List Option -> List Option -> Bool
--equal optionsA optionsB =
--    if List.length optionsA == List.length optionsB then
--        List.map2
--            (\optionA optionB ->
--                Option.equal optionA optionB
--            )
--            optionsA
--            optionsB
--            |> List.all identity
--
--    else
--        False


allOptionsAreValid : List Option -> Bool
allOptionsAreValid options =
    List.all Option.isValid options


hasAnyPendingValidation : List Option -> Bool
hasAnyPendingValidation options =
    List.any Option.isPendingValidation options


hasAnyValidationErrors : List Option -> Bool
hasAnyValidationErrors options =
    List.any Option.isInvalid options


setAge : OptionDisplay.OptionAge -> List Option -> List Option
setAge optionAge options =
    List.map (Option.setOptionDisplayAge optionAge) options


updateAge : SelectionMode.OutputStyle -> SearchString -> OutputStyle.SearchStringMinimumLength -> List Option -> List Option
updateAge outputStyle searchString searchStringMinimumLength options =
    case outputStyle of
        SelectionMode.CustomHtml ->
            case searchStringMinimumLength of
                OutputStyle.FixedSearchStringMinimumLength min ->
                    if SearchString.length searchString > PositiveInt.toInt min then
                        options

                    else
                        setAge OptionDisplay.MatureOption options

                OutputStyle.NoMinimumToSearchStringLength ->
                    options

        SelectionMode.Datalist ->
            setAge OptionDisplay.MatureOption options
