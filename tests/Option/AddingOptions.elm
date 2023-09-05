module Option.AddingOptions exposing (suite)

import Expect exposing (Expectation)
import Option exposing (Option(..), selectOption, setDescriptionWithString, setLabelWithString, test_newDatalistOption, test_newEmptyDatalistOption, test_newFancyOptionWithMaybeCleanString)
import OptionList exposing (OptionList(..), addAdditionalOptionsToOptionList, addAdditionalOptionsToOptionListWithAutoSortRank, addAndSelectOptionsInOptionsListByString, addNewEmptyOptionAtIndex, mergeTwoListsOfOptionsPreservingSelectedOptions, updatedDatalistSelectedOptions)
import OptionValue
import OutputStyle exposing (SelectedItemPlacementMode(..))
import SelectionMode
import SortRank exposing (newMaybeAutoSortRank)
import Test exposing (Test, describe, test)


heartBones =
    test_newFancyOptionWithMaybeCleanString "Heart Bones" Nothing


timecop1983 =
    test_newFancyOptionWithMaybeCleanString "Timecop1983" Nothing


wolfCubJustValue =
    test_newFancyOptionWithMaybeCleanString "Wolf Club" Nothing


wolfClub =
    test_newFancyOptionWithMaybeCleanString "Wolf Club" Nothing
        |> setLabelWithString "W O L F C L U B" Nothing
        |> setDescriptionWithString "80s Retro Wave"


waveshaper =
    test_newFancyOptionWithMaybeCleanString "Waveshaper" Nothing


theMidnightOptionValue =
    OptionValue.stringToOptionValue "The Midnight"


theMidnightSelected =
    test_newDatalistOption "The Midnight"
        |> Option.selectOption 0


theMidnight =
    test_newDatalistOption "The Midnight"



--noinspection SpellCheckingInspection


futureCopOptionValue =
    OptionValue.stringToOptionValue "Futurecop!"



--noinspection SpellCheckingInspection


futureCop =
    test_newDatalistOption "Futurecop!"



--noinspection SpellCheckingInspection


futureCopSelected =
    test_newDatalistOption "Futurecop!"
        |> Option.selectOption 1


arcadeHighOptionValue =
    OptionValue.stringToOptionValue "Arcade High"


arcadeHigh =
    test_newDatalistOption "Arcade High"


arcadeHighSelected =
    test_newDatalistOption "Arcade High"
        |> Option.selectOption 2


optionToTuple : Option -> ( String, Bool )
optionToTuple option =
    Tuple.pair (Option.getOptionValueAsString option) (Option.isOptionSelected option)


assertEqualLists : OptionList -> OptionList -> Expectation
assertEqualLists optionListA optionListB =
    Expect.equalLists
        (optionListA |> OptionList.getOptions |> List.map optionToTuple)
        (optionListB |> OptionList.getOptions |> List.map optionToTuple)


suite : Test
suite =
    describe "Adding options"
        [ test "that have different values should get added to the list" <|
            \_ ->
                assertEqualLists
                    (FancyOptionList [ heartBones, waveshaper ])
                    (addAdditionalOptionsToOptionList
                        (FancyOptionList [ waveshaper ])
                        (FancyOptionList [ heartBones ])
                    )
        , test "with the same value of an option already in the list (single)" <|
            \_ ->
                assertEqualLists
                    (FancyOptionList [ heartBones ])
                    (addAdditionalOptionsToOptionList
                        (FancyOptionList [ heartBones ])
                        (FancyOptionList [ heartBones ])
                    )
        , test "with the same value of an option already in the list" <|
            \_ ->
                assertEqualLists
                    (FancyOptionList [ timecop1983, heartBones ])
                    (addAdditionalOptionsToOptionList
                        (FancyOptionList [ timecop1983, heartBones ])
                        (FancyOptionList [ heartBones ])
                    )
        , test "with the same value of an option already in the list but with a description" <|
            \_ ->
                assertEqualLists
                    (FancyOptionList [ wolfClub ])
                    (addAdditionalOptionsToOptionList
                        (FancyOptionList [ wolfCubJustValue ])
                        (FancyOptionList [ wolfClub ])
                    )
        , test "with the same value of an option already in the list but with less meta data" <|
            \_ ->
                assertEqualLists
                    (FancyOptionList [ wolfClub ])
                    (addAdditionalOptionsToOptionList
                        (FancyOptionList [ wolfClub ])
                        (FancyOptionList [ wolfCubJustValue ])
                    )
        , describe "and selecting them"
            [ test "with the same value of an option already in the list, preserver the label" <|
                \_ ->
                    assertEqualLists
                        (FancyOptionList [ selectOption 0 wolfClub ])
                        (addAndSelectOptionsInOptionsListByString [ "Wolf Club" ] (FancyOptionList [ wolfClub ]))
            , test "with the same value of a selected option already in the list preserver the label" <|
                \_ ->
                    assertEqualLists
                        (FancyOptionList
                            [ wolfClub
                            , selectOption 1 waveshaper
                            , arcadeHigh
                            , selectOption 0 timecop1983
                            ]
                        )
                        (addAndSelectOptionsInOptionsListByString [ "Timecop1983", "Waveshaper" ]
                            (FancyOptionList
                                [ wolfClub
                                , waveshaper
                                , arcadeHigh
                                , timecop1983
                                ]
                            )
                        )
            , test "should preserver the order of the selection" <|
                \_ ->
                    assertEqualLists
                        (FancyOptionList [ selectOption 0 wolfClub ])
                        (addAndSelectOptionsInOptionsListByString [ "Wolf Club" ]
                            (FancyOptionList
                                [ selectOption 0 wolfClub ]
                            )
                        )
            , test "should preserver the order of multiple selections" <|
                \_ ->
                    assertEqualLists
                        (FancyOptionList
                            [ selectOption 1 heartBones
                            , timecop1983
                            , selectOption 0 waveshaper
                            ]
                        )
                        (addAndSelectOptionsInOptionsListByString
                            [ "Waveshaper", "Heart Bones" ]
                            (FancyOptionList
                                [ heartBones
                                , timecop1983
                                , waveshaper
                                ]
                            )
                        )
            ]
        , describe "and merging them with a selected value"
            [ test "if a new option matches the selected option update the label and description" <|
                \_ ->
                    assertEqualLists
                        (FancyOptionList [ wolfClub |> selectOption 0 ])
                        (mergeTwoListsOfOptionsPreservingSelectedOptions
                            SelectionMode.SingleSelect
                            SelectedItemStaysInPlace
                            (FancyOptionList [ test_newFancyOptionWithMaybeCleanString "Wolf Club" Nothing |> selectOption 0 ])
                            (FancyOptionList [ wolfClub ])
                        )
            , test "if a new option matches the selected option update the description even when adding a bunch of new options" <|
                \_ ->
                    assertEqualLists
                        (FancyOptionList [ wolfClub |> selectOption 0, timecop1983, heartBones ])
                        (mergeTwoListsOfOptionsPreservingSelectedOptions
                            SelectionMode.SingleSelect
                            SelectedItemStaysInPlace
                            (FancyOptionList [ test_newFancyOptionWithMaybeCleanString "Wolf Club" Nothing |> selectOption 0 ])
                            (FancyOptionList [ wolfClub, timecop1983, heartBones ])
                        )
            , test "a selection option should stay in the same spot in the list" <|
                \_ ->
                    assertEqualLists
                        (FancyOptionList [ timecop1983, heartBones, wolfClub |> selectOption 0 ])
                        (mergeTwoListsOfOptionsPreservingSelectedOptions
                            SelectionMode.SingleSelect
                            SelectedItemStaysInPlace
                            (FancyOptionList [ test_newFancyOptionWithMaybeCleanString "Wolf Club" Nothing |> selectOption 0 ])
                            (FancyOptionList [ timecop1983, heartBones, wolfClub ])
                        )
            , test "a selected option should move to the top of the list of options (when that option is set)" <|
                \_ ->
                    assertEqualLists
                        (FancyOptionList [ wolfClub |> selectOption 0, timecop1983, heartBones ])
                        (mergeTwoListsOfOptionsPreservingSelectedOptions
                            SelectionMode.SingleSelect
                            SelectedItemMovesToTheTop
                            (FancyOptionList [ test_newFancyOptionWithMaybeCleanString "Wolf Club" Nothing |> selectOption 0 ])
                            (FancyOptionList [ timecop1983, heartBones, wolfClub ])
                        )
            , describe "with auto sort order rank"
                [ test "new options should get added to the end of the list of options" <|
                    \_ ->
                        assertEqualLists
                            (FancyOptionList
                                [ heartBones |> Option.setMaybeSortRank (newMaybeAutoSortRank 3)
                                , wolfClub |> Option.setMaybeSortRank (newMaybeAutoSortRank 1)
                                , timecop1983 |> Option.setMaybeSortRank (newMaybeAutoSortRank 2)
                                ]
                            )
                            (addAdditionalOptionsToOptionListWithAutoSortRank
                                (FancyOptionList
                                    [ wolfClub |> Option.setMaybeSortRank (newMaybeAutoSortRank 1)
                                    , timecop1983 |> Option.setMaybeSortRank (newMaybeAutoSortRank 2)
                                    ]
                                )
                                (FancyOptionList [ heartBones ])
                            )
                , test "multiple new options should get added to the end of the list of options" <|
                    \_ ->
                        assertEqualLists
                            (FancyOptionList
                                [ heartBones |> Option.setMaybeSortRank (newMaybeAutoSortRank 6)
                                , timecop1983 |> Option.setMaybeSortRank (newMaybeAutoSortRank 7)
                                , wolfClub |> Option.setMaybeSortRank (newMaybeAutoSortRank 5)
                                ]
                            )
                            (addAdditionalOptionsToOptionListWithAutoSortRank
                                (FancyOptionList
                                    [ wolfClub |> Option.setMaybeSortRank (newMaybeAutoSortRank 5)
                                    ]
                                )
                                (FancyOptionList [ heartBones, timecop1983 ])
                            )
                ]
            ]
        , describe "and merging them with existing options"
            [ test "we should keep label and descriptions" <|
                \_ ->
                    assertEqualLists
                        (FancyOptionList
                            [ wolfClub
                            ]
                        )
                        (mergeTwoListsOfOptionsPreservingSelectedOptions
                            SelectionMode.SingleSelect
                            SelectedItemStaysInPlace
                            (FancyOptionList
                                [ wolfClub
                                ]
                            )
                            (FancyOptionList [ test_newFancyOptionWithMaybeCleanString "Wolf Club" Nothing ])
                        )
            ]
        , describe "mering two options"
            [ test "should preserve label and description when the option with the label and description is first" <|
                \_ ->
                    Expect.equal
                        wolfClub
                        (Option.merge wolfClub (test_newFancyOptionWithMaybeCleanString "Wolf Club" Nothing))
            , test "should preserve label and description when the option with the label and description is second" <|
                \_ ->
                    Expect.equal
                        wolfClub
                        (Option.merge (test_newFancyOptionWithMaybeCleanString "Wolf Club" Nothing) wolfClub)
            ]
        , describe "to a datalist list of options"
            [ test "add to the beginning of the selected options" <|
                \_ ->
                    assertEqualLists
                        (DatalistOptionList [ theMidnightSelected, futureCopSelected, arcadeHighSelected ]
                            |> addNewEmptyOptionAtIndex 0
                        )
                        (DatalistOptionList
                            [ test_newEmptyDatalistOption
                            , Option.selectOption 1 theMidnight
                            , Option.selectOption 2 futureCop
                            , Option.selectOption 3 arcadeHigh
                            ]
                        )
            , test "add to the middle of the selected options" <|
                \_ ->
                    assertEqualLists
                        (DatalistOptionList
                            [ theMidnightSelected
                            , futureCopSelected
                            , arcadeHighSelected
                            ]
                            |> addNewEmptyOptionAtIndex 1
                        )
                        (DatalistOptionList
                            [ theMidnightSelected
                            , test_newEmptyDatalistOption
                            , Option.selectOption 2 futureCop
                            , Option.selectOption 3 arcadeHigh
                            ]
                        )
            , test "add to the end of the selected options" <|
                \_ ->
                    assertEqualLists
                        (DatalistOptionList
                            [ theMidnightSelected
                            , futureCopSelected
                            , arcadeHighSelected
                            , test_newEmptyDatalistOption
                            ]
                        )
                        (DatalistOptionList
                            [ theMidnightSelected
                            , futureCopSelected
                            , arcadeHighSelected
                            ]
                            |> addNewEmptyOptionAtIndex 3
                        )
            , test "preserver the empty selected options" <|
                \_ ->
                    assertEqualLists
                        (updatedDatalistSelectedOptions
                            [ theMidnightOptionValue, futureCopOptionValue, arcadeHighOptionValue ]
                            (DatalistOptionList
                                [ theMidnightSelected
                                , futureCopSelected
                                , arcadeHighSelected
                                , test_newEmptyDatalistOption
                                    |> selectOption 3
                                , theMidnight
                                , futureCop
                                , arcadeHigh
                                ]
                            )
                        )
                        (DatalistOptionList
                            [ theMidnightSelected
                            , futureCopSelected
                            , arcadeHighSelected
                            , test_newEmptyDatalistOption
                                |> selectOption 3
                            , theMidnight
                            , futureCop
                            , arcadeHigh
                            ]
                        )
            ]
        ]
