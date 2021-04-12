module Option exposing
    ( Option(..)
    , OptionDescription
    , OptionDisplay(..)
    , OptionGroup
    , OptionValue
    , addAdditionalOptionsToOptionList
    , addAndSelectOptionsInOptionsListByString
    , customSelectedOptions
    , decoder
    , deselectAllOptionsInOptionsList
    , deselectAllSelectedHighlightedOptions
    , deselectOptionInListByOptionValue
    , emptyOptionGroup
    , filterOptionsToShowInDropdown
    , findHighlightedOrSelectedOptionIndex
    , findOptionByOptionValue
    , getMaybeOptionSearchFilter
    , getOptionDescription
    , getOptionDisplay
    , getOptionGroup
    , getOptionLabel
    , getOptionValue
    , getOptionValueAsString
    , hasSelectedOption
    , highlightOption
    , highlightOptionInList
    , highlightOptionInListByValue
    , isEmptyOption
    , isOptionInListOfOptionsByValue
    , mergeTwoListsOfOptionsPreservingSelectedOptions
    , moveHighlightedOptionDown
    , moveHighlightedOptionUp
    , newDisabledOption
    , newOption
    , newSelectedOption
    , optionDescriptionToBool
    , optionDescriptionToSearchString
    , optionDescriptionToString
    , optionGroupToString
    , optionToValueLabelTuple
    , optionsDecoder
    , optionsValues
    , removeHighlightOptionInList
    , removeOptionsFromOptionList
    , selectHighlightedOption
    , selectOption
    , selectOptionInList
    , selectOptionInListByOptionValue
    , selectOptionsInOptionsListByString
    , selectSingleOptionInList
    , selectedOptionsToTuple
    , setDescription
    , setGroup
    , setLabel
    , setOptionSearchFilter
    , setSelectedOptionInNewOptions
    , sortOptionsByGroupAndLabel
    , sortOptionsByTotalScore
    , stringToOptionValue
    , toggleSelectedHighlightByOptionValue
    , updateOrAddCustomOption
    )

import Json.Decode
import List.Extra
import OptionLabel exposing (OptionLabel(..), getSortRank, labelDecoder, optionLabelToSearchString, optionLabelToString)
import OptionSearchFilter exposing (OptionSearchFilter)
import SelectionMode exposing (SelectionMode(..))
import SortRank exposing (SortRank(..), getAutoIndexForSorting)


type Option
    = Option OptionDisplay OptionLabel OptionValue OptionDescription OptionGroup (Maybe OptionSearchFilter)
    | CustomOption OptionDisplay OptionLabel OptionValue (Maybe OptionSearchFilter)
    | EmptyOption OptionDisplay OptionLabel


getOptionLabel : Option -> OptionLabel
getOptionLabel option =
    case option of
        Option _ label _ _ _ _ ->
            label

        CustomOption _ label _ _ ->
            label

        EmptyOption _ label ->
            label


type OptionDisplay
    = OptionShown
    | OptionHidden
    | OptionSelected
    | OptionSelectedHighlighted
    | OptionHighlighted
    | OptionDisabled


type OptionValue
    = OptionValue String
    | EmptyOptionValue


optionValueToString : OptionValue -> String
optionValueToString optionValue =
    case optionValue of
        OptionValue valueString ->
            valueString

        EmptyOptionValue ->
            ""


stringToOptionValue : String -> OptionValue
stringToOptionValue string =
    OptionValue string


type OptionDescription
    = OptionDescription String (Maybe String)
    | NoDescription


optionDescriptionToString : OptionDescription -> String
optionDescriptionToString optionDescription =
    case optionDescription of
        OptionDescription string _ ->
            string

        NoDescription ->
            ""


optionDescriptionToSearchString : OptionDescription -> String
optionDescriptionToSearchString optionDescription =
    case optionDescription of
        OptionDescription description maybeCleanDescription ->
            case maybeCleanDescription of
                Just cleanDescription ->
                    cleanDescription

                Nothing ->
                    String.toLower description

        NoDescription ->
            ""


optionDescriptionToBool : OptionDescription -> Bool
optionDescriptionToBool optionDescription =
    case optionDescription of
        OptionDescription _ _ ->
            True

        NoDescription ->
            False


type OptionGroup
    = OptionGroup String
    | NoOptionGroup


emptyOptionGroup : OptionGroup
emptyOptionGroup =
    NoOptionGroup


getOptionGroup : Option -> OptionGroup
getOptionGroup option =
    case option of
        Option _ _ _ _ optionGroup _ ->
            optionGroup

        CustomOption _ _ _ _ ->
            NoOptionGroup

        EmptyOption _ _ ->
            NoOptionGroup


newOption : String -> Maybe String -> Option
newOption value maybeCleanLabel =
    case value of
        "" ->
            EmptyOption OptionShown (OptionLabel "" maybeCleanLabel NoSortRank)

        _ ->
            Option
                OptionShown
                (OptionLabel value maybeCleanLabel NoSortRank)
                (OptionValue value)
                NoDescription
                NoOptionGroup
                Nothing


setLabel : String -> Maybe String -> Option -> Option
setLabel string maybeCleanString option =
    case option of
        Option optionDisplay _ optionValue description group search ->
            Option
                optionDisplay
                (OptionLabel string maybeCleanString NoSortRank)
                optionValue
                description
                group
                search

        CustomOption optionDisplay _ _ search ->
            CustomOption
                optionDisplay
                (OptionLabel string maybeCleanString NoSortRank)
                (OptionValue string)
                search

        EmptyOption optionDisplay _ ->
            EmptyOption optionDisplay (OptionLabel string maybeCleanString NoSortRank)


setDescription : String -> Option -> Option
setDescription string option =
    case option of
        Option optionDisplay label optionValue _ group search ->
            Option optionDisplay
                label
                optionValue
                (OptionDescription string Nothing)
                group
                search

        CustomOption optionDisplay optionLabel optionValue search ->
            CustomOption
                optionDisplay
                optionLabel
                optionValue
                search

        EmptyOption optionDisplay optionLabel ->
            EmptyOption optionDisplay optionLabel


setGroup : String -> Option -> Option
setGroup string option =
    case option of
        Option optionDisplay label optionValue description _ search ->
            Option optionDisplay
                label
                optionValue
                description
                (OptionGroup string)
                search

        CustomOption optionDisplay optionLabel optionValue search ->
            CustomOption optionDisplay
                optionLabel
                optionValue
                search

        EmptyOption optionDisplay optionLabel ->
            EmptyOption optionDisplay optionLabel


setOptionDisplay : OptionDisplay -> Option -> Option
setOptionDisplay optionDisplay option =
    case option of
        Option _ optionLabel optionValue optionDescription optionGroup search ->
            Option
                optionDisplay
                optionLabel
                optionValue
                optionDescription
                optionGroup
                search

        CustomOption _ optionLabel optionValue search ->
            CustomOption optionDisplay
                optionLabel
                optionValue
                search

        EmptyOption _ optionLabel ->
            EmptyOption optionDisplay optionLabel


setOptionSearchFilter : Maybe OptionSearchFilter -> Option -> Option
setOptionSearchFilter maybeOptionSearchFilter option =
    case option of
        Option optionDisplay optionLabel optionValue optionDescription optionGroup _ ->
            Option
                optionDisplay
                optionLabel
                optionValue
                optionDescription
                optionGroup
                maybeOptionSearchFilter

        CustomOption optionDisplay optionLabel optionValue _ ->
            CustomOption
                optionDisplay
                optionLabel
                optionValue
                maybeOptionSearchFilter

        EmptyOption optionDisplay optionLabel ->
            EmptyOption
                optionDisplay
                optionLabel


newSelectedOption : String -> Maybe String -> Option
newSelectedOption string maybeCleanLabel =
    Option OptionSelected
        (OptionLabel string maybeCleanLabel NoSortRank)
        (OptionValue string)
        NoDescription
        NoOptionGroup
        Nothing


newDisabledOption : String -> Maybe String -> Option
newDisabledOption string maybeCleanLabel =
    Option OptionDisabled
        (OptionLabel string maybeCleanLabel NoSortRank)
        (OptionValue string)
        NoDescription
        NoOptionGroup
        Nothing


isOptionSelected : Option -> Bool
isOptionSelected option =
    let
        isOptionDisplaySelected optionDisplay =
            case optionDisplay of
                OptionShown ->
                    False

                OptionHidden ->
                    False

                OptionSelected ->
                    True

                OptionSelectedHighlighted ->
                    True

                OptionHighlighted ->
                    False

                OptionDisabled ->
                    False
    in
    case option of
        Option optionDisplay _ _ _ _ _ ->
            isOptionDisplaySelected optionDisplay

        CustomOption optionDisplay _ _ _ ->
            isOptionDisplaySelected optionDisplay

        EmptyOption optionDisplay _ ->
            isOptionDisplaySelected optionDisplay


getOptionDisplay : Option -> OptionDisplay
getOptionDisplay option =
    case option of
        Option display _ _ _ _ _ ->
            display

        CustomOption display _ _ _ ->
            display

        EmptyOption display _ ->
            display


getOptionValue : Option -> OptionValue
getOptionValue option =
    case option of
        Option _ _ value _ _ _ ->
            value

        CustomOption _ _ value _ ->
            value

        EmptyOption _ _ ->
            EmptyOptionValue


getOptionValueAsString : Option -> String
getOptionValueAsString option =
    case option |> getOptionValue of
        OptionValue string ->
            string

        EmptyOptionValue ->
            ""


optionGroupToString : OptionGroup -> String
optionGroupToString optionGroup =
    case optionGroup of
        OptionGroup string ->
            string

        NoOptionGroup ->
            ""


getOptionDescription : Option -> OptionDescription
getOptionDescription option =
    case option of
        Option _ _ _ optionDescription _ _ ->
            optionDescription

        CustomOption _ _ _ _ ->
            NoDescription

        EmptyOption _ _ ->
            NoDescription


getMaybeOptionSearchFilter : Option -> Maybe OptionSearchFilter
getMaybeOptionSearchFilter option =
    case option of
        Option _ _ _ _ _ maybeOptionSearchFilter ->
            maybeOptionSearchFilter

        CustomOption _ _ _ maybeOptionSearchFilter ->
            maybeOptionSearchFilter

        EmptyOption _ _ ->
            Nothing


selectedOptionsToTuple : List Option -> List ( String, String )
selectedOptionsToTuple options =
    options |> selectedOptions |> List.map optionToValueLabelTuple


optionsValues : List Option -> List String
optionsValues options =
    List.map getOptionValueAsString options


selectOptionsInOptionsListByString : List String -> List Option -> List Option
selectOptionsInOptionsListByString strings options =
    List.map
        (\option ->
            if isOptionValueInListOfStrings strings option then
                selectOption option

            else
                deselectOption option
        )
        options


addAndSelectOptionsInOptionsListByString : List String -> List Option -> List Option
addAndSelectOptionsInOptionsListByString strings options =
    let
        newOptions =
            List.map (\str -> newSelectedOption str Nothing) strings
    in
    mergeTwoListsOfOptionsPreservingSelectedOptions options newOptions


setSelectedOptionInNewOptions : List Option -> List Option -> List Option
setSelectedOptionInNewOptions oldOptions newOptions =
    let
        oldSelectedOption =
            oldOptions |> selectedOptions
    in
    List.map
        (\newOption_ ->
            if optionListContainsOptionWithValue newOption_ oldSelectedOption then
                selectOption newOption_

            else
                newOption_
        )
        newOptions


mergeTwoListsOfOptionsPreservingSelectedOptions : List Option -> List Option -> List Option
mergeTwoListsOfOptionsPreservingSelectedOptions optionsA optionsB =
    let
        superList =
            optionsA ++ optionsB

        newOptions =
            List.Extra.uniqueBy getOptionValueAsString superList
    in
    setSelectedOptionInNewOptions superList newOptions


deselectAllOptionsInOptionsList : List Option -> List Option
deselectAllOptionsInOptionsList options =
    List.map
        deselectOption
        options


isOptionValueInListOfStrings : List String -> Option -> Bool
isOptionValueInListOfStrings possibleValues option =
    List.any (\possibleValue -> getOptionValueAsString option == possibleValue) possibleValues


isOptionInListOfOptionsByValue : OptionValue -> List Option -> Bool
isOptionInListOfOptionsByValue optionValue options =
    List.any (\option -> (option |> getOptionValue |> optionValueToString) == (optionValue |> optionValueToString)) options


findOptionByOptionValue : OptionValue -> List Option -> Maybe Option
findOptionByOptionValue optionValue options =
    List.Extra.find (\option -> (option |> getOptionValue) == optionValue) options


optionValuesEqual : Option -> OptionValue -> Bool
optionValuesEqual option optionValue =
    getOptionValue option == optionValue


updateOrAddCustomOption : String -> List Option -> List Option
updateOrAddCustomOption searchString options =
    let
        showAddOption =
            options
                |> List.any
                    (\option_ ->
                        (option_
                            |> getOptionLabel
                            |> optionLabelToSearchString
                        )
                            == String.toLower searchString
                    )
                |> not

        options_ =
            List.Extra.dropWhile
                (\option_ ->
                    case option_ of
                        CustomOption _ _ _ _ ->
                            True

                        Option _ _ _ _ _ _ ->
                            False

                        EmptyOption _ _ ->
                            False
                )
                options
    in
    if showAddOption then
        [ CustomOption
            OptionShown
            (OptionLabel ("Add " ++ searchString ++ "…") Nothing NoSortRank)
            (OptionValue searchString)
            Nothing
        ]
            ++ options_

    else
        options_


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


filterOptionsToShowInDropdown : List Option -> List Option
filterOptionsToShowInDropdown =
    List.filter
        (\option ->
            case getOptionDisplay option of
                OptionShown ->
                    True

                OptionHidden ->
                    False

                OptionSelected ->
                    True

                OptionSelectedHighlighted ->
                    True

                OptionHighlighted ->
                    True

                OptionDisabled ->
                    False
        )


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


findClosestHighlightableOptionGoingUp : Int -> List Option -> Maybe Option
findClosestHighlightableOptionGoingUp index options =
    List.Extra.splitAt index options
        |> Tuple.first
        |> List.reverse
        |> List.Extra.find optionIsHighlightable


moveHighlightedOptionUp : List Option -> List Option
moveHighlightedOptionUp options =
    let
        maybeHigherSibling =
            options
                |> findHighlightedOrSelectedOptionIndex
                |> Maybe.andThen (\index -> findClosestHighlightableOptionGoingUp index options)
    in
    case maybeHigherSibling of
        Just option ->
            highlightOptionInList option options

        Nothing ->
            case List.head options of
                Just firstOption ->
                    highlightOptionInList firstOption options

                Nothing ->
                    options


findClosestHighlightableOptionGoingDown : Int -> List Option -> Maybe Option
findClosestHighlightableOptionGoingDown index options =
    List.Extra.splitAt index options
        |> Tuple.second
        |> List.Extra.find optionIsHighlightable


moveHighlightedOptionDown : List Option -> List Option
moveHighlightedOptionDown options =
    let
        maybeLowerSibling =
            options
                |> findHighlightedOrSelectedOptionIndex
                |> Maybe.andThen (\index -> findClosestHighlightableOptionGoingDown index options)
    in
    case maybeLowerSibling of
        Just option ->
            highlightOptionInList option options

        Nothing ->
            case List.head options of
                Just firstOption ->
                    highlightOptionInList firstOption options

                Nothing ->
                    options


selectOptionInList : Option -> List Option -> List Option
selectOptionInList option options =
    selectOptionInListByOptionValue (getOptionValue option) options


selectOptionInListByOptionValue : OptionValue -> List Option -> List Option
selectOptionInListByOptionValue value options =
    List.map
        (\option_ ->
            if optionValuesEqual option_ value then
                case option_ of
                    Option _ _ _ _ _ _ ->
                        selectOption option_

                    CustomOption _ _ _ _ ->
                        case value of
                            OptionValue valueStr ->
                                selectOption option_ |> setLabel valueStr Nothing

                            EmptyOptionValue ->
                                selectOption option_

                    EmptyOption _ _ ->
                        selectOption option_

            else
                option_
        )
        options


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
                                    MultiSelect _ ->
                                        selectOptionInListByOptionValue value options

                                    SingleSelect _ ->
                                        selectSingleOptionInList value options

                            CustomOption _ _ value _ ->
                                case selectionMode of
                                    MultiSelect _ ->
                                        selectOptionInListByOptionValue value options

                                    SingleSelect _ ->
                                        selectSingleOptionInList value options

                            EmptyOption _ _ ->
                                case selectionMode of
                                    MultiSelect _ ->
                                        selectEmptyOption options

                                    SingleSelect _ ->
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
                            selectOption option_

                        CustomOption _ _ optionValue _ ->
                            case optionValue of
                                OptionValue valueStr ->
                                    selectOption option_ |> setLabel valueStr Nothing

                                EmptyOptionValue ->
                                    selectOption option_

                        EmptyOption _ _ ->
                            selectOption option_

                else
                    deselectOption option_
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
                        selectOption option_
            )


addAdditionalOptionsToOptionList : List Option -> List Option -> List Option
addAdditionalOptionsToOptionList currentOptions newOptions =
    List.filter (\new -> not (optionListContainsOptionWithValue new currentOptions)) newOptions
        ++ currentOptions


removeOptionsFromOptionList : List Option -> List Option -> List Option
removeOptionsFromOptionList options optionsToRemove =
    List.filter (\option -> not (optionListContainsOptionWithValue option optionsToRemove)) options


sortOptionsByTotalScore : List Option -> List Option
sortOptionsByTotalScore options =
    List.sortBy
        (\option ->
            option
                |> getMaybeOptionSearchFilter
                |> Maybe.map .totalScore
                |> Maybe.withDefault 100000
        )
        options


sortOptionsByGroupAndLabel : List Option -> List Option
sortOptionsByGroupAndLabel options =
    options
        |> List.Extra.gatherWith
            (\optionA optionB ->
                getOptionGroup optionA == getOptionGroup optionB
            )
        |> List.map (\( option_, options_ ) -> List.append [ option_ ] options_)
        |> List.map (\options_ -> sortOptionsByLabel options_)
        |> List.concat



-- TODO This isn't done yet. It needs to be more complex.
--  It should sort primarily by the weight (bigger numbers should show up first)
--  Then it should sort by index
--  Last it should sort by alphabetically by label.


sortOptionsByLabel : List Option -> List Option
sortOptionsByLabel options =
    List.sortBy
        (\option ->
            option
                |> getOptionLabel
                |> optionLabelToString
        )
        options
        |> List.sortBy
            (\option ->
                option
                    |> getOptionLabel
                    |> getSortRank
                    |> getAutoIndexForSorting
            )


highlightOption : Option -> Option
highlightOption option =
    case option of
        Option display label value description group search ->
            case display of
                OptionShown ->
                    Option OptionHighlighted label value description group search

                OptionHidden ->
                    Option OptionHidden label value description group search

                OptionSelected ->
                    Option OptionSelected label value description group search

                OptionSelectedHighlighted ->
                    Option OptionSelectedHighlighted label value description group search

                OptionHighlighted ->
                    Option OptionHighlighted label value description group search

                OptionDisabled ->
                    Option OptionDisabled label value description group search

        CustomOption display label value search ->
            case display of
                OptionShown ->
                    CustomOption OptionHighlighted label value search

                OptionHidden ->
                    CustomOption OptionHidden label value search

                OptionSelected ->
                    CustomOption OptionSelected label value search

                OptionSelectedHighlighted ->
                    CustomOption OptionSelectedHighlighted label value search

                OptionHighlighted ->
                    CustomOption OptionHighlighted label value search

                OptionDisabled ->
                    CustomOption OptionDisabled label value search

        EmptyOption display label ->
            case display of
                OptionShown ->
                    EmptyOption OptionHighlighted label

                OptionHidden ->
                    EmptyOption OptionHidden label

                OptionSelected ->
                    EmptyOption OptionSelected label

                OptionSelectedHighlighted ->
                    EmptyOption OptionSelectedHighlighted label

                OptionHighlighted ->
                    EmptyOption OptionHighlighted label

                OptionDisabled ->
                    EmptyOption OptionDisabled label


removeHighlightOption : Option -> Option
removeHighlightOption option =
    case option of
        Option display label value description group search ->
            case display of
                OptionShown ->
                    Option OptionShown
                        label
                        value
                        description
                        group
                        search

                OptionHidden ->
                    Option OptionHidden
                        label
                        value
                        description
                        group
                        search

                OptionSelected ->
                    Option OptionSelected
                        label
                        value
                        description
                        group
                        search

                OptionSelectedHighlighted ->
                    Option OptionSelectedHighlighted
                        label
                        value
                        description
                        group
                        search

                OptionHighlighted ->
                    Option OptionShown label value description group search

                OptionDisabled ->
                    Option OptionDisabled label value description group search

        CustomOption display label value search ->
            case display of
                OptionShown ->
                    CustomOption OptionShown label value search

                OptionHidden ->
                    CustomOption OptionHidden label value search

                OptionSelected ->
                    CustomOption OptionSelected label value search

                OptionSelectedHighlighted ->
                    CustomOption
                        OptionSelectedHighlighted
                        label
                        value
                        search

                OptionHighlighted ->
                    CustomOption OptionShown label value search

                OptionDisabled ->
                    CustomOption OptionDisabled label value search

        EmptyOption display label ->
            case display of
                OptionShown ->
                    EmptyOption OptionShown label

                OptionHidden ->
                    EmptyOption OptionHidden label

                OptionSelected ->
                    EmptyOption OptionSelected label

                OptionHighlighted ->
                    EmptyOption OptionShown label

                OptionDisabled ->
                    EmptyOption OptionDisabled label

                OptionSelectedHighlighted ->
                    EmptyOption OptionSelectedHighlighted label


isOptionHighlighted : Option -> Bool
isOptionHighlighted option =
    case option of
        Option display _ _ _ _ _ ->
            case display of
                OptionShown ->
                    False

                OptionHidden ->
                    False

                OptionSelected ->
                    False

                OptionSelectedHighlighted ->
                    False

                OptionHighlighted ->
                    True

                OptionDisabled ->
                    False

        CustomOption display _ _ _ ->
            case display of
                OptionShown ->
                    False

                OptionHidden ->
                    False

                OptionSelected ->
                    False

                OptionSelectedHighlighted ->
                    False

                OptionHighlighted ->
                    True

                OptionDisabled ->
                    False

        EmptyOption display _ ->
            case display of
                OptionShown ->
                    False

                OptionHidden ->
                    False

                OptionSelected ->
                    False

                OptionSelectedHighlighted ->
                    False

                OptionHighlighted ->
                    True

                OptionDisabled ->
                    False


optionIsHighlightable : Option -> Bool
optionIsHighlightable option =
    case option of
        Option display _ _ _ _ _ ->
            case display of
                OptionShown ->
                    True

                OptionHidden ->
                    False

                OptionSelected ->
                    False

                OptionSelectedHighlighted ->
                    False

                OptionHighlighted ->
                    False

                OptionDisabled ->
                    False

        CustomOption display _ _ _ ->
            case display of
                OptionShown ->
                    True

                OptionHidden ->
                    False

                OptionSelected ->
                    False

                OptionSelectedHighlighted ->
                    False

                OptionHighlighted ->
                    False

                OptionDisabled ->
                    False

        EmptyOption display _ ->
            case display of
                OptionShown ->
                    True

                OptionHidden ->
                    False

                OptionSelected ->
                    False

                OptionSelectedHighlighted ->
                    False

                OptionHighlighted ->
                    False

                OptionDisabled ->
                    False


selectOption : Option -> Option
selectOption option =
    case option of
        Option display label value description group search ->
            case display of
                OptionShown ->
                    Option OptionSelected label value description group search

                OptionHidden ->
                    Option OptionSelected label value description group search

                OptionSelected ->
                    Option OptionSelected label value description group search

                OptionSelectedHighlighted ->
                    Option OptionSelected label value description group search

                OptionHighlighted ->
                    Option OptionSelected label value description group search

                OptionDisabled ->
                    Option OptionDisabled label value description group search

        CustomOption display label value search ->
            case display of
                OptionShown ->
                    CustomOption OptionSelected label value search

                OptionHidden ->
                    CustomOption OptionHidden label value search

                OptionSelected ->
                    CustomOption OptionSelected label value search

                OptionSelectedHighlighted ->
                    CustomOption OptionSelectedHighlighted label value search

                OptionHighlighted ->
                    CustomOption OptionSelected label value search

                OptionDisabled ->
                    CustomOption OptionDisabled label value search

        EmptyOption display label ->
            case display of
                OptionShown ->
                    EmptyOption OptionSelected label

                OptionHidden ->
                    EmptyOption OptionSelected label

                OptionSelected ->
                    EmptyOption OptionSelected label

                OptionSelectedHighlighted ->
                    EmptyOption OptionSelected label

                OptionHighlighted ->
                    EmptyOption OptionSelected label

                OptionDisabled ->
                    EmptyOption OptionDisabled label


deselectOption : Option -> Option
deselectOption option =
    case option of
        Option display label value description group search ->
            case display of
                OptionShown ->
                    Option OptionShown label value description group search

                OptionHidden ->
                    Option OptionHidden label value description group search

                OptionSelected ->
                    Option OptionShown label value description group search

                OptionSelectedHighlighted ->
                    Option OptionShown label value description group search

                OptionHighlighted ->
                    Option OptionHighlighted
                        label
                        value
                        description
                        group
                        search

                OptionDisabled ->
                    Option OptionDisabled label value description group search

        CustomOption display label value search ->
            case display of
                OptionShown ->
                    CustomOption OptionShown label value search

                OptionHidden ->
                    CustomOption OptionHidden label value search

                OptionSelected ->
                    CustomOption OptionShown label value search

                OptionSelectedHighlighted ->
                    CustomOption OptionSelectedHighlighted label value search

                OptionHighlighted ->
                    CustomOption OptionHighlighted label value search

                OptionDisabled ->
                    CustomOption OptionDisabled label value search

        EmptyOption display label ->
            case display of
                OptionShown ->
                    EmptyOption OptionShown label

                OptionHidden ->
                    EmptyOption OptionHidden label

                OptionSelected ->
                    EmptyOption OptionShown label

                OptionSelectedHighlighted ->
                    EmptyOption OptionShown label

                OptionHighlighted ->
                    EmptyOption OptionHighlighted label

                OptionDisabled ->
                    EmptyOption OptionDisabled label


selectedOptions : List Option -> List Option
selectedOptions options =
    options
        |> List.filter
            (\option_ ->
                case option_ of
                    Option display _ _ _ _ _ ->
                        case display of
                            OptionShown ->
                                False

                            OptionHidden ->
                                False

                            OptionSelected ->
                                True

                            OptionSelectedHighlighted ->
                                True

                            OptionHighlighted ->
                                False

                            OptionDisabled ->
                                False

                    CustomOption display _ _ _ ->
                        case display of
                            OptionShown ->
                                False

                            OptionHidden ->
                                False

                            OptionSelected ->
                                True

                            OptionSelectedHighlighted ->
                                True

                            OptionHighlighted ->
                                False

                            OptionDisabled ->
                                False

                    EmptyOption display _ ->
                        case display of
                            OptionShown ->
                                False

                            OptionHidden ->
                                False

                            OptionSelected ->
                                True

                            OptionSelectedHighlighted ->
                                True

                            OptionHighlighted ->
                                False

                            OptionDisabled ->
                                False
            )


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

                                OptionSelected ->
                                    option_ |> setOptionDisplay OptionSelectedHighlighted

                                OptionSelectedHighlighted ->
                                    option_ |> setOptionDisplay OptionSelected

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

                                OptionSelected ->
                                    option_ |> setOptionDisplay OptionSelectedHighlighted

                                OptionSelectedHighlighted ->
                                    option_ |> setOptionDisplay OptionSelected

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

                            OptionSelected ->
                                option_

                            OptionSelectedHighlighted ->
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

                            OptionSelected ->
                                option_

                            OptionSelectedHighlighted ->
                                option_ |> setOptionDisplay OptionShown

                            OptionHighlighted ->
                                option_

                            OptionDisabled ->
                                option_

                    EmptyOption _ _ ->
                        option_
            )


hasSelectedOption : List Option -> Bool
hasSelectedOption options =
    options |> selectedOptions |> List.isEmpty |> not


isEmptyOption : Option -> Bool
isEmptyOption option =
    case option of
        Option _ _ _ _ _ _ ->
            False

        CustomOption _ _ _ _ ->
            False

        EmptyOption _ _ ->
            True


optionListContainsOptionWithValue : Option -> List Option -> Bool
optionListContainsOptionWithValue option options =
    let
        optionValue =
            getOptionValue option
    in
    List.filter (\option_ -> getOptionValue option_ == optionValue) options
        |> List.isEmpty
        |> not


optionToValueLabelTuple : Option -> ( String, String )
optionToValueLabelTuple option =
    ( getOptionValueAsString option, getOptionLabel option |> optionLabelToString )


customSelectedOptions : List Option -> List Option
customSelectedOptions =
    customOptions >> selectedOptions


customOptions : List Option -> List Option
customOptions options =
    List.filter isCustomOption options


isCustomOption : Option -> Bool
isCustomOption option =
    case option of
        Option _ _ _ _ _ _ ->
            False

        CustomOption _ _ _ _ ->
            True

        EmptyOption _ _ ->
            False


optionsDecoder : Json.Decode.Decoder (List Option)
optionsDecoder =
    Json.Decode.list decoder


decoder : Json.Decode.Decoder Option
decoder =
    Json.Decode.oneOf
        [ decodeOptionWithoutAValue
        , decodeOptionWithAValue
        ]


decodeOptionWithoutAValue : Json.Decode.Decoder Option
decodeOptionWithoutAValue =
    Json.Decode.field
        "value"
        valueDecoder
        |> Json.Decode.andThen
            (\value ->
                case value of
                    OptionValue _ ->
                        Json.Decode.fail "It can not be an option without a value because it has a value."

                    EmptyOptionValue ->
                        Json.Decode.map2
                            EmptyOption
                            displayDecoder
                            labelDecoder
            )


decodeOptionWithAValue : Json.Decode.Decoder Option
decodeOptionWithAValue =
    Json.Decode.map6 Option
        displayDecoder
        labelDecoder
        (Json.Decode.field
            "value"
            valueDecoder
        )
        descriptionDecoder
        optionGroupDecoder
        (Json.Decode.succeed Nothing)


displayDecoder : Json.Decode.Decoder OptionDisplay
displayDecoder =
    Json.Decode.oneOf
        [ Json.Decode.field
            "selected"
            Json.Decode.string
            |> Json.Decode.andThen
                (\str ->
                    case str of
                        "true" ->
                            Json.Decode.succeed OptionSelected

                        _ ->
                            Json.Decode.fail "Option is not selected"
                )
        , Json.Decode.field
            "selected"
            Json.Decode.bool
            |> Json.Decode.andThen
                (\isSelected ->
                    if isSelected then
                        Json.Decode.succeed OptionSelected

                    else
                        Json.Decode.succeed OptionShown
                )
        , Json.Decode.field
            "disabled"
            Json.Decode.bool
            |> Json.Decode.andThen
                (\isDisabled ->
                    if isDisabled then
                        Json.Decode.succeed OptionDisabled

                    else
                        Json.Decode.fail "Option is not disabled"
                )
        , Json.Decode.succeed OptionShown
        ]


valueDecoder : Json.Decode.Decoder OptionValue
valueDecoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\valueStr ->
                case String.trim valueStr of
                    "" ->
                        Json.Decode.succeed EmptyOptionValue

                    str ->
                        Json.Decode.succeed (OptionValue str)
            )


descriptionDecoder : Json.Decode.Decoder OptionDescription
descriptionDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map2 OptionDescription
            (Json.Decode.field "description" Json.Decode.string)
            (Json.Decode.field "descriptionClean" (Json.Decode.nullable Json.Decode.string))
        , Json.Decode.succeed NoDescription
        ]


optionGroupDecoder : Json.Decode.Decoder OptionGroup
optionGroupDecoder =
    Json.Decode.oneOf
        [ Json.Decode.field "group" Json.Decode.string
            |> Json.Decode.map OptionGroup
        , Json.Decode.succeed NoOptionGroup
        ]
