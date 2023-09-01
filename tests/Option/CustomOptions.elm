module Option.CustomOptions exposing (suite)

import Expect exposing (Expectation)
import FancyOption exposing (newCustomOption)
import MuchSelect
    exposing
        ( updateModelWithChangesThatEffectTheOptionsWithSearchString
        )
import Option exposing (Option(..), selectOption, test_newFancyOptionWithMaybeCleanString)
import OptionList exposing (OptionList(..), getOptions, prependCustomOption, removeUnselectedCustomOptions, selectOptionByOptionValue)
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
        , setSingleItemRemoval
        )
import Test exposing (Test, describe, test)


birchWood =
    test_newFancyOptionWithMaybeCleanString "Birch Wood" Nothing


cutCopper =
    test_newFancyOptionWithMaybeCleanString "Cut Copper" Nothing


mossyCobblestone =
    test_newFancyOptionWithMaybeCleanString "Mossy Cobblestone" Nothing


torch =
    test_newFancyOptionWithMaybeCleanString "Torch" Nothing


turf =
    test_newFancyOptionWithMaybeCleanString "Turf" Nothing


vines =
    test_newFancyOptionWithMaybeCleanString "Vines" Nothing


blocks =
    FancyOptionList [ birchWood, cutCopper, mossyCobblestone, torch, turf, vines ]


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
