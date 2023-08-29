module Option.CustomOptions exposing (suite)

import DropdownOptions exposing (figureOutWhichOptionsToShowInTheDropdown)
import Expect exposing (Expectation)
import FancyOption exposing (newCustomOption)
import MuchSelect
    exposing
        ( updateModelWithChangesThatEffectTheOptionsWithSearchString
        )
import Option exposing (Option(..), selectOption, test_newFancyOption)
import OptionList exposing (OptionList(..), getOptions, prependCustomOption, removeUnselectedCustomOptions, selectOptionByOptionValue)
import OptionSearcher
import OptionValue exposing (stringToOptionValue)
import OutputStyle
    exposing
        ( MaxDropdownItems(..)
        , SearchStringMinimumLength(..)
        , SingleItemRemoval(..)
        )
import PositiveInt
import RightSlot exposing (RightSlot(..))
import SearchString
import SelectionMode
    exposing
        ( OutputStyle(..)
        , SelectionConfig(..)
        , SelectionMode(..)
        , defaultSelectionConfig
        , setAllowCustomOptionsWithBool
        , setSelectionMode
        , setSingleItemRemoval
        )
import Test exposing (Test, describe, test)


birchWood =
    test_newFancyOption "Birch Wood" Nothing


cutCopper =
    test_newFancyOption "Cut Copper" Nothing


mossyCobblestone =
    test_newFancyOption "Mossy Cobblestone" Nothing


torch =
    test_newFancyOption "Torch" Nothing


turf =
    test_newFancyOption "Turf" Nothing


vines =
    test_newFancyOption "Vines" Nothing


blocks =
    FancyOptionList [ birchWood, cutCopper, mossyCobblestone, torch, turf, vines ]


searchStringMinLengthTen =
    FixedSearchStringMinimumLength (PositiveInt.new 10)


maxDropdownItemsIsTen =
    FixedMaxDropdownItems (PositiveInt.new 10)


emptyFancyList =
    FancyOptionList []


assertEqualLists : OptionList -> OptionList -> Expectation
assertEqualLists optionListA optionListB =
    Expect.equalLists
        (optionListA |> getOptions |> List.map Option.getOptionValueAsString)
        (optionListB |> getOptions |> List.map Option.getOptionValueAsString)


newFancyCustomOption : String -> Maybe String -> Option
newFancyCustomOption value maybeCleanLabel =
    FancyOption (newCustomOption value maybeCleanLabel)


suite : Test
suite =
    describe "Custom options"
        [ test "should be able to remove all the unselected custom options" <|
            \_ ->
                assertEqualLists
                    (blocks
                        |> selectOptionByOptionValue (stringToOptionValue "Cut Copper")
                        |> selectOptionByOptionValue (stringToOptionValue "Turf")
                        |> removeUnselectedCustomOptions
                    )
                    (FancyOptionList
                        [ birchWood
                        , selectOption 0 cutCopper
                        , mossyCobblestone
                        , selectOption 1 turf
                        ]
                    )
        , test "should be able to maintain a custom option with an empty hint" <|
            \_ ->
                assertEqualLists
                    (prependCustomOption (Just "{{}}") (SearchString.update "pizza") emptyFancyList)
                    (FancyOptionList [ newFancyCustomOption "pizza" Nothing ])
        , test "should stay in the dropdown if there's only a custom option with an empty hint" <|
            \_ ->
                let
                    selectionConfig =
                        defaultSelectionConfig
                            |> setSelectionMode MultiSelect
                            |> setAllowCustomOptionsWithBool True Nothing
                            |> setSingleItemRemoval EnableSingleItemRemoval
                            |> SelectionMode.setMaxDropdownItems maxDropdownItemsIsTen
                in
                Expect.equalLists
                    (OptionSearcher.updateOptionsWithSearchStringAndCustomOption selectionConfig
                        (SearchString.update "monkey bread")
                        emptyFancyList
                        |> figureOutWhichOptionsToShowInTheDropdown selectionConfig
                        |> DropdownOptions.valuesAsStrings
                    )
                    [ "monkey bread" ]

        {- https://github.com/DripEmail/much-select-elm/issues/135 -}
        , test "should stay in the dropdown if there's a custom option and some existing selected options" <|
            \_ ->
                let
                    selectionConfig =
                        defaultSelectionConfig
                            |> setSelectionMode MultiSelect
                            |> setAllowCustomOptionsWithBool True Nothing
                            |> setSingleItemRemoval EnableSingleItemRemoval
                            |> SelectionMode.setMaxDropdownItems NoLimitToDropdownItems
                in
                Expect.equalLists
                    (FancyOptionList
                        [ newFancyCustomOption "monkey bread" Nothing |> Option.highlightOption
                        , birchWood |> Option.selectOption 1
                        , cutCopper |> Option.selectOption 2
                        ]
                        |> OptionSearcher.updateOptionsWithSearchStringAndCustomOption
                            selectionConfig
                            (SearchString.update "monkey bread")
                        |> OptionList.andMap Option.getOptionValueAsString
                    )
                    [ "monkey bread", "Birch Wood", "Cut Copper" ]
        , test "and regular options show be visible in the dropdown if the search string matches OK" <|
            \_ ->
                let
                    selectionConfig =
                        defaultSelectionConfig
                            |> setSelectionMode MultiSelect
                            |> setAllowCustomOptionsWithBool True Nothing
                            |> setSingleItemRemoval EnableSingleItemRemoval
                            |> SelectionMode.setMaxDropdownItems NoLimitToDropdownItems
                            |> SelectionMode.setSearchStringMinimumLength searchStringMinLengthTen
                in
                Expect.equalLists
                    (FancyOptionList
                        [ mossyCobblestone
                        ]
                        |> OptionSearcher.updateOptionsWithSearchStringAndCustomOption
                            selectionConfig
                            (SearchString.update "cob")
                        |> OptionList.sortOptionsByTotalScore
                        |> OptionList.highlightFirstOptionInList
                        |> figureOutWhichOptionsToShowInTheDropdown selectionConfig
                        |> DropdownOptions.valuesAsStrings
                    )
                    [ "cob", "Mossy Cobblestone" ]
        , test "a custom option should show up even if it is shorter than the minimum search length" <|
            \_ ->
                let
                    selectionConfig =
                        defaultSelectionConfig
                            |> setSelectionMode MultiSelect
                            |> setAllowCustomOptionsWithBool True Nothing
                            |> setSingleItemRemoval EnableSingleItemRemoval
                            |> SelectionMode.setMaxDropdownItems NoLimitToDropdownItems
                            |> SelectionMode.setSearchStringMinimumLength searchStringMinLengthTen
                in
                Expect.equalLists
                    (FancyOptionList
                        [ mossyCobblestone
                        ]
                        |> OptionSearcher.updateOptionsWithSearchStringAndCustomOption
                            selectionConfig
                            (SearchString.update "cob")
                        |> OptionList.sortOptionsByTotalScore
                        |> OptionList.highlightFirstOptionInList
                        |> figureOutWhichOptionsToShowInTheDropdown selectionConfig
                        |> DropdownOptions.valuesAsStrings
                    )
                    [ "cob", "Mossy Cobblestone" ]
        , describe "updateModelWithChangesThatEffectTheOptionsWithSearchString"
            [ test "should show up at the top in the dropdown" <|
                \_ ->
                    let
                        selectionConfig =
                            defaultSelectionConfig
                                |> setAllowCustomOptionsWithBool True (Just "{{}}")
                                |> setSingleItemRemoval EnableSingleItemRemoval
                                |> SelectionMode.setMaxDropdownItems maxDropdownItemsIsTen
                    in
                    Expect.equalLists
                        (updateModelWithChangesThatEffectTheOptionsWithSearchString
                            ShowNothing
                            selectionConfig
                            (SearchString.update "mil")
                            (FancyOptionList [ birchWood ])
                            { options = FancyOptionList [ birchWood ], rightSlot = ShowNothing }
                            |> .options
                            |> OptionList.optionsValuesAsStrings
                        )
                        [ "mil", "Birch Wood" ]
            ]
        ]
