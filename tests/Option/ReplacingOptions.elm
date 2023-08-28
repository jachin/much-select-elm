module Option.ReplacingOptions exposing (suite)

import Expect
import Option
import OptionsUtilities exposing (mergeTwoListsOfOptionsPreservingSelectedOptions, replaceOptions)
import OutputStyle
import SelectionMode
import Test exposing (Test, describe, test)


futureCop =
    test_newFancyOption "Future Cop!" Nothing


theMidnight =
    test_newFancyOption "The Midnight" Nothing


thirdEyeBlind =
    test_newFancyOption "Third Eye Blind" Nothing


selectionConfig =
    SelectionMode.defaultSelectionConfig
        |> SelectionMode.setAllowCustomOptionsWithBool False Nothing
        |> SelectionMode.setSelectedItemStaysInPlaceWithBool True


multiSelectSelectionConfig =
    SelectionMode.defaultSelectionConfig
        |> SelectionMode.setSelectionMode SelectionMode.MultiSelect
        |> SelectionMode.setAllowCustomOptionsWithBool False Nothing
        |> SelectionMode.setSelectedItemStaysInPlaceWithBool True


suite : Test
suite =
    describe "Replacing options"
        [ describe "in multi select mode "
            [ test "should not include options that were there before" <|
                \_ ->
                    Expect.equalLists
                        [ futureCop, theMidnight ]
                        (replaceOptions
                            multiSelectSelectionConfig
                            [ thirdEyeBlind, futureCop ]
                            [ futureCop, theMidnight ]
                        )
            , test "should preserver selected options" <|
                \_ ->
                    Expect.equalLists
                        [ futureCop, Option.selectOption 0 theMidnight ]
                        (replaceOptions
                            multiSelectSelectionConfig
                            [ thirdEyeBlind, futureCop ]
                            [ futureCop, Option.selectOption 0 theMidnight ]
                        )
            , test "should preserver selected options even if the selected value is not in the new list of options" <|
                \_ ->
                    Expect.equalLists
                        (replaceOptions
                            multiSelectSelectionConfig
                            [ Option.selectOption 0 thirdEyeBlind, futureCop ]
                            [ futureCop, theMidnight ]
                        )
                        [ futureCop, theMidnight, Option.selectOption 0 thirdEyeBlind ]
            , test "should preserver selected order of the options" <|
                \_ ->
                    Expect.equalLists
                        (replaceOptions
                            multiSelectSelectionConfig
                            [ Option.selectOption 1 thirdEyeBlind, futureCop, Option.selectOption 0 theMidnight ]
                            [ Option.selectOption 1 thirdEyeBlind, futureCop, Option.selectOption 0 theMidnight ]
                        )
                        [ Option.selectOption 1 thirdEyeBlind, futureCop, Option.selectOption 0 theMidnight ]
            , test "merging the 2 lists of options should preserver selected order of the options" <|
                \_ ->
                    Expect.equalLists
                        (mergeTwoListsOfOptionsPreservingSelectedOptions
                            SelectionMode.MultiSelect
                            OutputStyle.SelectedItemStaysInPlace
                            [ Option.selectOption 1 thirdEyeBlind, futureCop, Option.selectOption 0 theMidnight ]
                            [ Option.selectOption 1 thirdEyeBlind, futureCop, Option.selectOption 0 theMidnight ]
                        )
                        [ Option.selectOption 1 thirdEyeBlind, futureCop, Option.selectOption 0 theMidnight ]
            ]
        , describe "in single select mode"
            [ test "should preserver a single selected item in the new list of options" <|
                \_ ->
                    Expect.equalLists
                        (replaceOptions
                            selectionConfig
                            [ futureCop, theMidnight ]
                            [ Option.selectOption 0 thirdEyeBlind, futureCop ]
                        )
                        [ Option.selectOption 0 thirdEyeBlind, futureCop ]
            , test "should preserver a single selected item in the old list of options" <|
                \_ ->
                    Expect.equalLists
                        (replaceOptions
                            selectionConfig
                            [ Option.selectOption 0 thirdEyeBlind, theMidnight ]
                            [ thirdEyeBlind, futureCop ]
                        )
                        [ Option.selectOption 0 thirdEyeBlind, futureCop ]
            , test "should preserver a single selected item when the selected item is in both the old and new list" <|
                \_ ->
                    Expect.equalLists
                        (replaceOptions
                            selectionConfig
                            [ Option.selectOption 0 thirdEyeBlind, theMidnight ]
                            [ Option.selectOption 0 thirdEyeBlind, futureCop ]
                        )
                        [ Option.selectOption 0 thirdEyeBlind, futureCop ]
            , test "should preserver a single selected item when the selected item is NOT in the new list" <|
                \_ ->
                    Expect.equalLists
                        (replaceOptions
                            selectionConfig
                            [ Option.selectOption 0 thirdEyeBlind, theMidnight ]
                            [ futureCop ]
                        )
                        [ futureCop, Option.selectOption 0 thirdEyeBlind ]
            , test "should preserver a single selected item when different items are selected in the old and new list, favoring the new selected option" <|
                \_ ->
                    Expect.equalLists
                        (replaceOptions
                            selectionConfig
                            [ Option.selectOption 0 thirdEyeBlind, theMidnight ]
                            [ Option.selectOption 0 futureCop ]
                        )
                        [ Option.selectOption 0 futureCop ]
            ]
        ]
