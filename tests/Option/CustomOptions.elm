module Option.CustomOptions exposing (suite)

import Expect
import Main exposing (figureOutWhichOptionsToShowInTheDropdown, updateTheFullListOfOptions, updateTheOptionsForTheDropdown)
import Option exposing (newCustomOption, newOption, selectOption, stringToOptionValue)
import OptionSearcher
import OptionSorting
import OptionsUtilities exposing (highlightFirstOptionInList, prependCustomOption, removeUnselectedCustomOptions, selectOptionInListByOptionValue)
import PositiveInt
import SelectionMode exposing OutputStyle(..), SelectionConfig(..))
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
                    (prependCustomOption (Just "{{}}") "pizza" [])
                    [ newCustomOption "pizza" Nothing ]
        , test "should stay in the dropdown if there's only a custom option with an empty hint" <|
            \_ ->
                let
                    selectionMode =

                        MultiSelectConfig AllowCustomOptions EnableSingleItemRemoval CustomHtml
                in
                Expect.equalLists
                    (OptionSearcher.updateOptionsWithSearchStringAndCustomOption selectionMode (Just "{{}}") "monkey bread" (PositiveInt.new 2) []
                        |> figureOutWhichOptionsToShowInTheDropdown selectionMode (PositiveInt.new 10)
                        |> List.map Option.getOptionValueAsString
                    )
                    [ "monkey bread" ]

        {- https://github.com/DripEmail/much-select-elm/issues/135 -}
        , test "should stay in the dropdown if there's a custom option and some existing selected options" <|
            \_ ->
                Expect.equalLists
                    ([ newCustomOption "monkey bread" Nothing |> Option.highlightOption
                     , birchWood |> Option.selectOption 1
                     , cutCopper |> Option.selectOption 2
                     ]
                        |> OptionSearcher.updateOptionsWithSearchStringAndCustomOption
                            (MultiSelectConfig AllowCustomOptions EnableSingleItemRemoval CustomHtml)
                            (Just "{{}}")
                            "monkey bread"
                            (PositiveInt.new 2)
                        |> List.map Option.getOptionValueAsString
                    )
                    [ "monkey bread", "Birch Wood", "Cut Copper" ]
        , test "and regular options show be visible in the dropdown if the search string matches OK" <|
            \_ ->
                let
                    selectionMode =
                        MultiSelectConfig AllowCustomOptions EnableSingleItemRemoval CustomHtml
                in
                Expect.equalLists
                    ([ mossyCobblestone
                     ]
                        |> OptionSearcher.updateOptionsWithSearchStringAndCustomOption
                            selectionMode
                            (Just "{{}}")
                            "cob"
                            (PositiveInt.new 10)
                        |> OptionSorting.sortOptionsBySearchFilterTotalScore
                        |> highlightFirstOptionInList
                        |> figureOutWhichOptionsToShowInTheDropdown selectionMode (PositiveInt.new 2)
                        |> List.map Option.getOptionValueAsString
                    )
                    [ "cob", "Mossy Cobblestone" ]
        , test "a custom option should show up even if it is shorter than the minimum search length" <|
            \_ ->
                let
                    selectionMode =
                        MultiSelectConfig AllowCustomOptions EnableSingleItemRemoval CustomHtml
                in
                Expect.equalLists
                    ([ mossyCobblestone
                     ]
                        |> OptionSearcher.updateOptionsWithSearchStringAndCustomOption
                            (MultiSelectConfig AllowCustomOptions EnableSingleItemRemoval CustomHtml)
                            (Just "{{}}")
                            "cob"
                            (PositiveInt.new 10)
                        |> OptionSorting.sortOptionsBySearchFilterTotalScore
                        |> highlightFirstOptionInList
                        |> figureOutWhichOptionsToShowInTheDropdown selectionMode (PositiveInt.new 2)
                        |> List.map Option.getOptionValueAsString
                    )
                    [ "cob", "Mossy Cobblestone" ]
        , test "should show up at the top in the dropdown" <|
            \_ ->
                let
                    selectionMode =
                        SingleSelectConfig AllowCustomOptions SelectedItemStaysInPlace SelectionMode.CustomHtml
                in
                Expect.equalLists
                    ([ birchWood
                     ]
                        |> updateTheFullListOfOptions
                            (SingleSelectConfig AllowCustomOptions SelectedItemStaysInPlace SelectionMode.CustomHtml)
                            (Just "{{}}")
                            "mil"
                            (PositiveInt.new 5)
                        |> updateTheOptionsForTheDropdown
                            selectionMode
                            (PositiveInt.new 10)
                        |> List.map Option.getOptionValueAsString
                    )
                    [ "mil", "Birch Wood" ]
        ]
