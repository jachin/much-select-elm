module OptionList exposing (OptionList(..), activateOptionInListByOptionValue, findClosestHighlightableOptionGoingDown, findClosestHighlightableOptionGoingUp, selectOptionByOptionValueWithIndex, selectOptionIByValueStringWithIndex, selectOptionInList)

import DatalistOption
import FancyOption
import List.Extra
import Option exposing (Option)
import OptionLabel exposing (OptionLabel)
import OptionValue exposing (OptionValue)
import SearchString exposing (SearchString)
import SelectionMode exposing (SelectionConfig, SelectionMode(..))
import SortRank exposing (SortRank)


type OptionList
    = FancyOptionList (List Option)
    | DatalistOptionList (List Option)
    | SlottedOptionList (List Option)


getOptions : OptionList -> List Option
getOptions optionList =
    case optionList of
        FancyOptionList options ->
            options

        DatalistOptionList options ->
            options

        SlottedOptionList options ->
            options


map : (Option -> Option) -> OptionList -> OptionList
map function optionList =
    case optionList of
        FancyOptionList options ->
            FancyOptionList (List.map function options)

        DatalistOptionList options ->
            DatalistOptionList (List.map function options)

        SlottedOptionList options ->
            SlottedOptionList (List.map function options)


indexedMap : (Int -> Option -> Option) -> OptionList -> OptionList
indexedMap function optionList =
    case optionList of
        FancyOptionList options ->
            FancyOptionList (List.indexedMap function options)

        DatalistOptionList options ->
            DatalistOptionList (List.indexedMap function options)

        SlottedOptionList options ->
            SlottedOptionList (List.indexedMap function options)


head : OptionList -> Maybe Option
head optionList =
    case optionList of
        FancyOptionList options ->
            List.head options

        DatalistOptionList options ->
            List.head options

        SlottedOptionList options ->
            List.head options


last : OptionList -> Maybe Option
last optionList =
    case optionList of
        FancyOptionList options ->
            List.Extra.last options

        DatalistOptionList options ->
            List.Extra.last options

        SlottedOptionList options ->
            List.Extra.last options


length : OptionList -> Int
length optionList =
    case optionList of
        FancyOptionList options ->
            List.length options

        DatalistOptionList options ->
            List.length options

        SlottedOptionList options ->
            List.length options


foldl : (Option -> b -> b) -> b -> OptionList -> b
foldl function b optionList =
    case optionList of
        FancyOptionList options ->
            List.foldl function b options

        DatalistOptionList options ->
            List.foldl function b options

        SlottedOptionList options ->
            List.foldl function b options


foldr : (Option -> b -> b) -> b -> OptionList -> b
foldr function b optionList =
    case optionList of
        FancyOptionList options ->
            List.foldr function b options

        DatalistOptionList options ->
            List.foldr function b options

        SlottedOptionList options ->
            List.foldr function b options


filter : (Option -> Bool) -> OptionList -> OptionList
filter function optionList =
    case optionList of
        FancyOptionList options ->
            FancyOptionList (List.filter function options)

        DatalistOptionList options ->
            DatalistOptionList (List.filter function options)

        SlottedOptionList options ->
            SlottedOptionList (List.filter function options)


sortBy : (Option -> comparable) -> OptionList -> OptionList
sortBy function optionList =
    case optionList of
        FancyOptionList options ->
            FancyOptionList (List.sortBy function options)

        DatalistOptionList options ->
            DatalistOptionList (List.sortBy function options)

        SlottedOptionList options ->
            SlottedOptionList (List.sortBy function options)


any : (Option -> Bool) -> OptionList -> Bool
any function optionList =
    case optionList of
        FancyOptionList options ->
            List.any function options

        DatalistOptionList options ->
            List.any function options

        SlottedOptionList options ->
            List.any function options


uniqueBy : (Option -> comparable) -> OptionList -> OptionList
uniqueBy function optionList =
    case optionList of
        FancyOptionList options ->
            FancyOptionList (List.Extra.uniqueBy function options)

        DatalistOptionList options ->
            DatalistOptionList (List.Extra.uniqueBy function options)

        SlottedOptionList options ->
            SlottedOptionList (List.Extra.uniqueBy function options)


find : (Option -> Bool) -> OptionList -> Maybe Option
find function optionList =
    case optionList of
        FancyOptionList options ->
            List.Extra.find function options

        DatalistOptionList options ->
            List.Extra.find function options

        SlottedOptionList options ->
            List.Extra.find function options


findByValue : OptionValue -> OptionList -> Maybe Option
findByValue optionValue optionList =
    find (Option.optionEqualsOptionValue optionValue) optionList


append : OptionList -> OptionList -> OptionList
append optionListA optionListB =
    case optionListA of
        FancyOptionList options ->
            case optionListB of
                FancyOptionList optionsB ->
                    FancyOptionList (options ++ optionsB)

                _ ->
                    optionListA

        DatalistOptionList options ->
            case optionListB of
                DatalistOptionList optionsB ->
                    DatalistOptionList (options ++ optionsB)

                _ ->
                    optionListA

        SlottedOptionList options ->
            case optionListB of
                SlottedOptionList optionsB ->
                    SlottedOptionList (options ++ optionsB)

                _ ->
                    optionListA


take : Int -> OptionList -> OptionList
take int optionList =
    case optionList of
        FancyOptionList options ->
            List.take int options
                |> FancyOptionList

        DatalistOptionList options ->
            List.take int options
                |> DatalistOptionList

        SlottedOptionList options ->
            List.take int options
                |> SlottedOptionList


findClosestHighlightableOptionGoingUp : SelectionConfig -> Int -> OptionList -> Maybe Option
findClosestHighlightableOptionGoingUp selectionConfig index list =
    List.Extra.splitAt index (getOptions list)
        |> Tuple.first
        |> List.reverse
        |> List.Extra.find (Option.optionIsHighlightable selectionConfig)


findClosestHighlightableOptionGoingDown : SelectionConfig -> Int -> OptionList -> Maybe Option
findClosestHighlightableOptionGoingDown selectionConfig index list =
    List.Extra.splitAt index (getOptions list)
        |> Tuple.second
        |> List.Extra.find (Option.optionIsHighlightable selectionConfig)


selectOptionInList : Option -> OptionList -> OptionList
selectOptionInList option list =
    selectOptionByOptionValue
        (Option.getOptionValue option)
        list


selectedOptions : OptionList -> OptionList
selectedOptions options =
    options
        |> filter Option.isOptionSelected
        |> sortBy Option.getOptionSelectedIndex


unselectedOptions : OptionList -> OptionList
unselectedOptions options =
    options
        |> filter (\option -> Option.isOptionSelected option |> not)


customOptions : OptionList -> OptionList
customOptions optionList =
    optionList |> filter Option.isCustomOption


customSelectedOptions : OptionList -> OptionList
customSelectedOptions =
    customOptions >> selectedOptions


hasSelectedOption : OptionList -> Bool
hasSelectedOption optionList =
    optionList
        |> selectedOptions
        |> length
        |> (\length_ -> length_ > 0)


{-| Look through the list of options, if we find one that matches the given option value select it.

Pick a selection index that is the same as the selection index of the option.

-}
selectOption : Option -> OptionList -> OptionList
selectOption optionToSelect options =
    let
        notLessThanZero index =
            if index < 0 then
                0

            else
                index

        selectionIndex =
            Option.getOptionSelectedIndex optionToSelect
                |> notLessThanZero

        optionValue =
            Option.getOptionValue optionToSelect
    in
    selectOptionByOptionValueWithIndex selectionIndex optionValue options


{-| Look through the list of options, if we find one that matches the given option value
then select it and return a new list of options with the found option selected.

And deselect all other options in the list.

-}
selectSingleOptionByValue : OptionValue -> OptionList -> OptionList
selectSingleOptionByValue optionValue options =
    options
        |> map
            (\option_ ->
                if Option.optionEqualsOptionValue optionValue option_ then
                    --CustomOption _ _ _ _ ->
                    --    case value of
                    --        OptionValue valueStr ->
                    --            Option.selectOption nextSelectedIndex option_
                    --                |> setLabelWithString valueStr Nothing
                    --
                    --        EmptyOptionValue ->
                    --            Option.selectOption nextSelectedIndex option_
                    Option.selectOption 0 option_

                else if Option.isOptionSelected option_ then
                    option_

                else
                    Option.deselectOption option_
            )


selectSingleOption : Option -> OptionList -> OptionList
selectSingleOption option optionList =
    selectSingleOptionByValue (Option.getOptionValue option) optionList


selectSingleOptionByValueResult : OptionValue -> OptionList -> Result String OptionList
selectSingleOptionByValueResult optionValue optionList =
    if any (Option.optionEqualsOptionValue optionValue) optionList then
        Ok (selectSingleOptionByValue optionValue optionList)

    else
        Err "That option is not in this list"


{-| Look through the list of options, if we find one that matches the given option value
then select it and return a new list of options with the found option selected.

If we do not find the option value return the same list of options.

-}
selectOptionByOptionValue : OptionValue -> OptionList -> OptionList
selectOptionByOptionValue value list =
    let
        nextSelectedIndex =
            foldl
                (\selectedOption highestIndex ->
                    if Option.getOptionSelectedIndex selectedOption > highestIndex then
                        Option.getOptionSelectedIndex selectedOption

                    else
                        highestIndex
                )
                -1
                list
                + 1
    in
    selectOptionByOptionValueWithIndex nextSelectedIndex value list


selectOptionByOptionValueWithIndex : Int -> OptionValue -> OptionList -> OptionList
selectOptionByOptionValueWithIndex index optionValue optionList =
    map
        (\option_ ->
            if Option.optionEqualsOptionValue optionValue option_ then
                --CustomOption _ _ _ _ ->
                --    case value of
                --        OptionValue valueStr ->
                --            Option.selectOption nextSelectedIndex option_
                --                |> setLabelWithString valueStr Nothing
                --
                --        EmptyOptionValue ->
                --            Option.selectOption nextSelectedIndex option_
                Option.selectOption index option_

            else if Option.isOptionSelected option_ then
                option_

            else
                --Option.removeHighlightFromOption option_
                option_
        )
        optionList


selectOptionIByValueStringWithIndex : Int -> String -> OptionList -> OptionList
selectOptionIByValueStringWithIndex int string optionList =
    selectOptionByOptionValueWithIndex int (OptionValue string) optionList


selectOptions : List Option -> OptionList -> OptionList
selectOptions optionsToSelect optionList =
    let
        helper : OptionList -> Option -> ( OptionList, List Option )
        helper newOptions optionToSelect =
            ( selectOption optionToSelect newOptions, [] )
    in
    List.Extra.mapAccuml helper optionList optionsToSelect
        |> Tuple.first


selectHighlightedOption : SelectionMode -> OptionList -> OptionList
selectHighlightedOption selectionMode optionList =
    case selectionMode of
        SingleSelect ->
            optionList
                |> filter
                    (\option ->
                        Option.isOptionHighlighted option
                    )
                |> head
                |> Maybe.map (\option -> selectSingleOption option optionList)
                |> Maybe.withDefault optionList
                |> clearAnyUnselectedCustomOptions

        MultiSelect ->
            optionList
                |> filter
                    (\option ->
                        Option.isOptionHighlighted option
                    )
                |> head
                |> Maybe.map (\option -> selectOption option optionList)
                |> Maybe.withDefault optionList


selectSingleOptionInListByStringOrSelectCustomValue : SearchString -> OptionList -> OptionList
selectSingleOptionInListByStringOrSelectCustomValue searchString optionList =
    if SearchString.isEmpty searchString then
        optionList

    else
        case selectSingleOptionByValueResult (OptionValue.stringToOptionValue (SearchString.toString searchString)) optionList of
            Ok newOptions ->
                newOptions

            Err _ ->
                case optionList of
                    FancyOptionList options ->
                        let
                            value =
                                SearchString.toString searchString

                            newOption =
                                FancyOption.newCustomOption value (Just value)
                                    |> FancyOption.select 0
                                    |> Option.FancyOption

                            newOptions =
                                newOption :: options
                        in
                        FancyOptionList newOptions
                            |> clearAnyUnselectedCustomOptions
                            |> deselectAll

                    DatalistOptionList _ ->
                        optionList

                    SlottedOptionList _ ->
                        optionList


selectEmptyOnlyTheEmptyOption : OptionList -> OptionList
selectEmptyOnlyTheEmptyOption optionList =
    optionList
        |> map
            (\option_ ->
                case option_ of
                    Option.FancyOption fancyOption ->
                        if FancyOption.isEmptyOption fancyOption then
                            Option.FancyOption (FancyOption.select 0 fancyOption)

                        else
                            Option.deselectOption option_

                    Option.DatalistOption _ ->
                        Option.deselectOption option_

                    Option.SlottedOption _ ->
                        Option.deselectOption option_
            )


deselectOptionByOptionValue : OptionValue -> OptionList -> OptionList
deselectOptionByOptionValue optionValue optionList =
    map (Option.deselectOptionIfEqual optionValue) optionList


{-| This is kind of a strange one it takes a list of options to leave selected and deselects all the rest.
-}
deselectEveryOptionExceptOptionsInList : List Option -> OptionList -> OptionList
deselectEveryOptionExceptOptionsInList optionsNotToDeselect optionList =
    map
        (\option ->
            let
                test : Option -> Bool
                test optionNotToDeselect =
                    Option.optionsHaveEqualValues optionNotToDeselect option
            in
            if List.any test optionsNotToDeselect then
                option

            else
                Option.deselectOption option
        )
        optionList


deselectAllButTheFirstSelectedOptionInList : OptionList -> OptionList
deselectAllButTheFirstSelectedOptionInList optionList =
    case head (selectedOptions optionList) of
        Just oneOptionToLeaveSelected ->
            selectSingleOptionByValue (Option.getOptionValue oneOptionToLeaveSelected) optionList

        Nothing ->
            optionList


deselectAll : OptionList -> OptionList
deselectAll options =
    map
        Option.deselectOption
        options


{-| Look through the list of options, if we find one that matches the given option value
then select it and return a new list of options with the found option selected.

If we do not find the option value return the same list of options.

-}
activateOptionInListByOptionValue : OptionValue -> OptionList -> OptionList
activateOptionInListByOptionValue value options =
    map
        (Option.activateOptionIfEqualRemoveHighlightElse value)
        options


clearAnyUnselectedCustomOptions : OptionList -> OptionList
clearAnyUnselectedCustomOptions optionsList =
    filter (\option -> not (Option.isCustomOption option && not (Option.isOptionSelected option))) optionsList


isOptionValueInListOfOptionsByValue : OptionValue -> OptionList -> Bool
isOptionValueInListOfOptionsByValue optionValue optionsList =
    any (Option.optionEqualsOptionValue optionValue) optionsList


isOptionInListOfOptionsByValue : Option -> OptionList -> Bool
isOptionInListOfOptionsByValue option optionsList =
    isOptionValueInListOfOptionsByValue (Option.getOptionValue option) optionsList


equal : OptionList -> OptionList -> Bool
equal optionListA optionListB =
    getOptions optionListA == getOptions optionListB


addAdditionalOptionsToOptionList : OptionList -> OptionList -> OptionList
addAdditionalOptionsToOptionList currentOptions newOptions =
    let
        currentOptionsWithUpdates =
            map
                (\currentOption ->
                    case findByValue (Option.getOptionValue currentOption) newOptions of
                        Just newOption_ ->
                            Option.merge currentOption newOption_

                        Nothing ->
                            currentOption
                )
                currentOptions

        reallyNewOptions : OptionList
        reallyNewOptions =
            filter (\newOption_ -> not (isOptionInListOfOptionsByValue newOption_ currentOptions)) newOptions
    in
    append reallyNewOptions currentOptionsWithUpdates


addAdditionalOptionsToOptionListWithAutoSortRank : OptionList -> OptionList -> OptionList
addAdditionalOptionsToOptionListWithAutoSortRank currentOptions newOptions =
    let
        nextHighestAutoSortRank : Int
        nextHighestAutoSortRank =
            findHighestAutoSortRank currentOptions + 1
    in
    indexedMap
        (\index option ->
            let
                maybeNewSortRank : Maybe SortRank
                maybeNewSortRank =
                    SortRank.newMaybeAutoSortRank (nextHighestAutoSortRank + index)

                optionLabel : OptionLabel
                optionLabel =
                    Option.getOptionLabel option

                updatedOptionLabel : OptionLabel
                updatedOptionLabel =
                    case maybeNewSortRank of
                        Just newSortRank ->
                            OptionLabel.setSortRank newSortRank optionLabel

                        Nothing ->
                            optionLabel
            in
            Option.setLabel updatedOptionLabel option
        )
        newOptions
        |> addAdditionalOptionsToOptionList currentOptions


findHighestAutoSortRank : OptionList -> Int
findHighestAutoSortRank optionList =
    foldr
        (\option currentMax ->
            max
                (option
                    |> Option.getOptionLabel
                    |> OptionLabel.getSortRank
                    |> SortRank.getAutoIndexForSorting
                )
                currentMax
        )
        0
        optionList


removeOptionsFromOptionList : OptionList -> OptionList -> OptionList
removeOptionsFromOptionList optionList optionsToRemove =
    filter (\option -> not (isOptionInListOfOptionsByValue option optionsToRemove)) optionList


removeOptionFromOptionListBySelectedIndex : Int -> OptionList -> OptionList
removeOptionFromOptionListBySelectedIndex selectedIndex options =
    filter (\option -> Option.getOptionSelectedIndex option /= selectedIndex) options
        |> reIndexSelectedOptions


{-| Clean up custom options, remove all the custom options that are not selected.
-}
removeUnselectedCustomOptions : OptionList -> OptionList
removeUnselectedCustomOptions optionList =
    let
        unselectedCustomOptions =
            optionList
                |> filter Option.isCustomOption
                |> filter (Option.isOptionSelected >> not)
    in
    removeOptionsFromOptionList optionList unselectedCustomOptions


removeEmptyOptions : OptionList -> OptionList
removeEmptyOptions optionList =
    filter (Option.isEmptyOption >> not) optionList


reIndexSelectedOptions : OptionList -> OptionList
reIndexSelectedOptions optionList =
    let
        selectedOptions_ =
            optionList
                |> selectedOptions

        nonSelectedOptions =
            optionList
                |> unselectedOptions
    in
    indexedMap (\index option -> Option.selectOption index option) selectedOptions_
        |> append nonSelectedOptions


unhighlightSelectedOptions : OptionList -> OptionList
unhighlightSelectedOptions optionList =
    map Option.removeHighlightFromOption optionList


deselectOptions : OptionList -> OptionList -> OptionList
deselectOptions optionsToDeselect allOptions =
    let
        shouldDeselectOption option =
            -- figure out if options match my looking at their value's
            any
                (\optionToDeselect -> Option.getOptionValue optionToDeselect == Option.getOptionValue option)
                optionsToDeselect
    in
    map
        (\option ->
            if shouldDeselectOption option then
                Option.deselectOption option

            else
                option
        )
        allOptions


deselectOption : Option -> OptionList -> OptionList
deselectOption option optionList =
    map
        (\option_ ->
            if Option.optionEqualsOptionValue (Option.getOptionValue option) option_ then
                Option.deselectOption option_

            else
                option_
        )
        optionList


deselectAllSelectedHighlightedOptions : OptionList -> OptionList
deselectAllSelectedHighlightedOptions optionList =
    let
        highlightedOptions =
            optionList
                |> filter Option.isOptionHighlighted
                |> filter Option.isOptionSelected
    in
    deselectOptions highlightedOptions optionList


deselectLastSelectedOption : OptionList -> OptionList
deselectLastSelectedOption optionList =
    let
        maybeLastSelectionOption =
            optionList
                |> selectedOptions
                |> last
    in
    case maybeLastSelectionOption of
        Just lastSelectionOption ->
            deselectOption lastSelectionOption optionList

        Nothing ->
            optionList


findSelectedOption : OptionList -> Maybe Option
findSelectedOption optionList =
    find Option.isOptionSelected optionList


toggleSelectedHighlightByOptionValue : OptionList -> OptionValue -> List Option
toggleSelectedHighlightByOptionValue optionList optionValue =
    optionList
        |> map
            (\option ->
                if Option.optionEqualsOptionValue optionValue option then
                    Option.toggleHighlight option

                else
                    option
            )
        |> getOptions


hasSelectedHighlightedOptions : OptionList -> Bool
hasSelectedHighlightedOptions optionList =
    any Option.isOptionSelectedHighlighted optionList


{-|

    Clean up options. This function is designed for the datalist mode.
    The idea is that there should only be at most 1 empty option.

-}
cleanupEmptySelectedOptions : OptionList -> OptionList
cleanupEmptySelectedOptions options =
    let
        selectedOptions_ =
            options
                |> selectedOptions

        selectedOptionsSansEmptyOptions =
            options
                |> selectedOptions
                |> filter (Option.isEmptyOptionOrHasEmptyValue >> not)
    in
    if length selectedOptions_ > 1 && length selectedOptionsSansEmptyOptions > 1 then
        selectedOptionsSansEmptyOptions

    else if length selectedOptions_ > 1 then
        take 1 selectedOptions_

    else
        options


organizeNewDatalistOptions : OptionList -> OptionList
organizeNewDatalistOptions optionList =
    let
        selectedOptions_ =
            optionList |> selectedOptions

        optionsForTheDatasetHints =
            optionList
                |> filter (Option.isOptionSelected >> not)
                |> map Option.deselectOption
                |> uniqueBy Option.getOptionValueAsString
                |> removeEmptyOptions
    in
    append selectedOptions_ optionsForTheDatasetHints |> reIndexSelectedOptions


updatedDatalistSelectedOptions : List OptionValue -> OptionList -> OptionList
updatedDatalistSelectedOptions selectedValues optionList =
    let
        newSelectedOptions : OptionList
        newSelectedOptions =
            selectedValues
                |> List.indexedMap (\i selectedValue -> DatalistOption.newSelectedDatalistOption selectedValue i)
                |> List.map Option.DatalistOption
                |> DatalistOptionList

        oldSelectedOptions : OptionList
        oldSelectedOptions =
            optionList
                |> selectedOptions

        oldSelectedOptionsCleanedUp : OptionList
        oldSelectedOptionsCleanedUp =
            oldSelectedOptions
                |> cleanupEmptySelectedOptions

        selectedOptions_ =
            if equal newSelectedOptions oldSelectedOptionsCleanedUp then
                oldSelectedOptions

            else
                newSelectedOptions

        optionsForTheDatasetHints =
            optionList
                |> filter (Option.isOptionSelected >> not)
                |> map Option.deselectOption
                |> uniqueBy Option.getOptionValueAsString
                |> removeEmptyOptions
    in
    append selectedOptions_ optionsForTheDatasetHints
