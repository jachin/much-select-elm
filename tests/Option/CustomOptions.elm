module Option.CustomOptions exposing (suite)

import Expect
import Main
    exposing
        ( figureOutWhichOptionsToShowInTheDropdown
        , updateModelWithChangesThatEffectTheOptionsWithSearchString
        , updateTheFullListOfOptions
        , updateTheOptionsForTheDropdown
        )
import Option exposing (newCustomOption, newOption, selectOption)
import OptionSearcher
import OptionSorting
import OptionValue exposing (stringToOptionValue)
import OptionsUtilities
    exposing
        ( highlightFirstOptionInList
        , prependCustomOption
        , removeUnselectedCustomOptions
        , selectOptionInListByOptionValue
        )
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
    newOption "Birch Wood" Nothing


cutCopper =
    newOption "Cut Copper" Nothing


mossyCobblestone =
    newOption "Mossy Cobblestone" Nothing


torch =
    newCustomOption "Torch" Nothing


turf =
    newCustomOption "Turf" Nothing


vines =
    newCustomOption "Vines" Nothing


blocks =
    [ birchWood, cutCopper, mossyCobblestone, torch, turf, vines ]


searchStringMinLengthTen =
    FixedSearchStringMinimumLength (PositiveInt.new 10)


maxDropdownItemsIsTen =
    FixedMaxDropdownItems (PositiveInt.new 10)


suite : Test
suite =
    describe "Custom options"
        [ test "should be able to remove all the unselected custom options" <|
            \_ ->
                Expect.equalLists
                    (blocks
                        |> selectOptionInListByOptionValue (stringToOptionValue "Cut Copper")
                        |> selectOptionInListByOptionValue (stringToOptionValue "Turf")
                        |> removeUnselectedCustomOptions
                    )
                    [ birchWood
                    , selectOption 0 cutCopper
                    , mossyCobblestone
                    , selectOption 1 turf
                    ]
        , test "should be able to maintain a custom option with an empty hint" <|
            \_ ->
                Expect.equalLists
                    (prependCustomOption (Just "{{}}") (SearchString.new "pizza") [])
                    [ newCustomOption "pizza" Nothing ]
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
                    (OptionSearcher.updateOptionsWithSearchStringAndCustomOption selectionConfig (SearchString.new "monkey bread") []
                        |> figureOutWhichOptionsToShowInTheDropdown selectionConfig
                        |> List.map Option.getOptionValueAsString
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
                    ([ newCustomOption "monkey bread" Nothing |> Option.highlightOption
                     , birchWood |> Option.selectOption 1
                     , cutCopper |> Option.selectOption 2
                     ]
                        |> OptionSearcher.updateOptionsWithSearchStringAndCustomOption
                            selectionConfig
                            (SearchString.new "monkey bread")
                        |> List.map Option.getOptionValueAsString
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
                    ([ mossyCobblestone
                     ]
                        |> OptionSearcher.updateOptionsWithSearchStringAndCustomOption
                            selectionConfig
                            (SearchString.new "cob")
                        |> OptionSorting.sortOptionsBySearchFilterTotalScore
                        |> highlightFirstOptionInList
                        |> figureOutWhichOptionsToShowInTheDropdown selectionConfig
                        |> List.map Option.getOptionValueAsString
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
                    ([ mossyCobblestone
                     ]
                        |> OptionSearcher.updateOptionsWithSearchStringAndCustomOption
                            selectionConfig
                            (SearchString.new "cob")
                        |> OptionSorting.sortOptionsBySearchFilterTotalScore
                        |> highlightFirstOptionInList
                        |> figureOutWhichOptionsToShowInTheDropdown selectionConfig
                        |> List.map Option.getOptionValueAsString
                    )
                    [ "cob", "Mossy Cobblestone" ]
        , test "should show up at the top in the dropdown" <|
            \_ ->
                let
                    selectionConfig =
                        defaultSelectionConfig
                            |> setAllowCustomOptionsWithBool True (Just "{{}}")
                            |> setSingleItemRemoval EnableSingleItemRemoval
                            |> SelectionMode.setMaxDropdownItems maxDropdownItemsIsTen
                in
                Expect.equalLists
                    ([ birchWood
                     ]
                        |> updateTheFullListOfOptions
                            selectionConfig
                            (SearchString.new "mil")
                        |> updateTheOptionsForTheDropdown
                            selectionConfig
                        |> List.map Option.getOptionValueAsString
                    )
                    [ "mil", "Birch Wood" ]
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
                            (SearchString.new "mil")
                            [ birchWood ]
                            { options = [ birchWood ], rightSlot = ShowNothing }
                            |> .options
                            |> List.map Option.getOptionValueAsString
                        )
                        [ "mil", "Birch Wood" ]
            ]
        ]
