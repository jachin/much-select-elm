module Option.CustomOptions exposing (suite)

import Expect
import Main exposing (figureOutWhichOptionsToShow)
import Option exposing (newCustomOption, newOption, removeUnselectedCustomOptions, selectOption, selectOptionInListByOptionValue, stringToOptionValue, updateOrAddCustomOption)
import OptionSearcher
import OptionSorting
import PositiveInt
import SelectionMode exposing (CustomOptions(..), SelectedItemPlacementMode(..), SelectionMode(..), SingleItemRemoval(..))
import Test exposing (Test, describe, test)


birchWood =
    newOption "Birch Wood" Nothing


cutCopper =
    newOption "Cut Copper" Nothing


mossyCobblestone =
    newOption "Mossy Cobblestone" Nothing


torch =
    newCustomOption "Torch" Nothing


tuff =
    newCustomOption "Tuff" Nothing


vines =
    newCustomOption "Vines" Nothing


blocks =
    [ birchWood, cutCopper, mossyCobblestone, torch, tuff, vines ]


suite : Test
suite =
    describe "Custom options"
        [ test "should be able to remove all the unselected custom options" <|
            \_ ->
                Expect.equalLists
                    (blocks
                        |> selectOptionInListByOptionValue (stringToOptionValue "Cut Copper")
                        |> selectOptionInListByOptionValue (stringToOptionValue "Tuff")
                        |> removeUnselectedCustomOptions
                    )
                    [ birchWood
                    , selectOption 0 cutCopper
                    , mossyCobblestone
                    , selectOption 1 tuff
                    ]
        , test "should be able to maintain a custom option with an empty hint" <|
            \_ ->
                Expect.equalLists
                    (updateOrAddCustomOption (Just "{{}}") "pizza" [])
                    [ newCustomOption "pizza" Nothing ]
        , test "should drop any extra custom option" <|
            \_ ->
                Expect.equalLists
                    (updateOrAddCustomOption (Just "{{}}") "pizza" blocks)
                    [ newCustomOption "pizza" Nothing, birchWood, cutCopper, mossyCobblestone ]
        , test "should stay in the dropdown if there's only a custom option with an empty hint" <|
            \_ ->
                Expect.equalLists
                    (OptionSearcher.updateOptionsWithSearchStringAndCustomOption (MultiSelect AllowCustomOptions EnableSingleItemRemoval) (Just "{{}}") "monkey bread" (PositiveInt.new 2) []
                        |> figureOutWhichOptionsToShow (PositiveInt.new 10)
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
                            (MultiSelect AllowCustomOptions EnableSingleItemRemoval)
                            (Just "{{}}")
                            "monkey bread"
                            (PositiveInt.new 2)
                        |> List.map Option.getOptionValueAsString
                    )
                    [ "monkey bread", "Birch Wood", "Cut Copper" ]
        , test "and regular options show be visible in the dropdown if the search string matches OK" <|
            \_ ->
                Expect.equalLists
                    ([ mossyCobblestone
                     ]
                        |> OptionSearcher.updateOptionsWithSearchStringAndCustomOption
                            (MultiSelect AllowCustomOptions EnableSingleItemRemoval)
                            (Just "{{}}")
                            "cob"
                            (PositiveInt.new 10)
                        |> OptionSorting.sortOptionsBySearchFilterTotalScore
                        |> Option.highlightFirstOptionInList
                        |> figureOutWhichOptionsToShow (PositiveInt.new 2)
                        |> List.map Option.getOptionValueAsString
                    )
                    [ "cob", "Mossy Cobblestone" ]
        , test "a custom option should show up even if it is shorter than the minimum search length" <|
            \_ ->
                Expect.equalLists
                    ([ mossyCobblestone
                     ]
                        |> OptionSearcher.updateOptionsWithSearchStringAndCustomOption
                            (MultiSelect AllowCustomOptions EnableSingleItemRemoval)
                            (Just "{{}}")
                            "cob"
                            (PositiveInt.new 10)
                        |> OptionSorting.sortOptionsBySearchFilterTotalScore
                        |> Option.highlightFirstOptionInList
                        |> figureOutWhichOptionsToShow (PositiveInt.new 2)
                        |> List.map Option.getOptionValueAsString
                    )
                    [ "cob", "Mossy Cobblestone" ]
        ]
