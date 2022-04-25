module Option.AddingOptions exposing (suite)

import Expect
import Option
    exposing
        ( merge2Options
        , newOption
        , selectOption
        , setDescriptionWithString
        , setLabelWithString
        )
import OptionsUtilities
    exposing
        ( addAdditionalOptionsToOptionList
        , addAdditionalOptionsToOptionListWithAutoSortRank
        , addAndSelectOptionsInOptionsListByString
        , mergeTwoListsOfOptionsPreservingSelectedOptions
        )
import SelectionMode exposing (SelectedItemPlacementMode(..))
import SortRank exposing (newMaybeAutoSortRank)
import Test exposing (Test, describe, test)


heartBones =
    newOption "Heart Bones" Nothing


timecop1983 =
    newOption "Timecop1983" Nothing


wolfCubJustValue =
    newOption "Wolf Club" Nothing


wolfClub =
    newOption "Wolf Club" Nothing
        |> setLabelWithString "W O L F C L U B" Nothing
        |> setDescriptionWithString "80s Retro Wave"


waveshaper =
    newOption "Waveshaper" Nothing


suite : Test
suite =
    describe "Adding options"
        [ test "that have different values should get added to the list" <|
            \_ ->
                Expect.equalLists
                    [ heartBones, waveshaper ]
                    (addAdditionalOptionsToOptionList [ waveshaper ] [ heartBones ])
        , test "with the same value of an option already in the list (single)" <|
            \_ ->
                Expect.equalLists
                    [ heartBones ]
                    (addAdditionalOptionsToOptionList [ heartBones ] [ heartBones ])
        , test "with the same value of an option already in the list" <|
            \_ ->
                Expect.equalLists
                    [ timecop1983, heartBones ]
                    (addAdditionalOptionsToOptionList [ timecop1983, heartBones ] [ heartBones ])
        , test "with the same value of an option already in the list but with a description" <|
            \_ ->
                Expect.equalLists
                    [ wolfClub ]
                    (addAdditionalOptionsToOptionList [ wolfCubJustValue ] [ wolfClub ])
        , test "with the same value of an option already in the list but with less meta data" <|
            \_ ->
                Expect.equalLists
                    [ wolfClub ]
                    (addAdditionalOptionsToOptionList [ wolfClub ] [ wolfCubJustValue ])
        , describe "and selecting them"
            [ test "with the same value of an option already in the list, preserver the label" <|
                \_ ->
                    Expect.equalLists
                        [ selectOption 0 wolfClub ]
                        (addAndSelectOptionsInOptionsListByString [ "Wolf Club" ] [ wolfClub ])
            , test "with the same value of a selected option already in the list preserver the label" <|
                \_ ->
                    Expect.equalLists
                        [ selectOption 0 wolfClub ]
                        (addAndSelectOptionsInOptionsListByString [ "Wolf Club" ] [ selectOption 0 wolfClub ])
            ]
        , describe "and merging them with a selected value"
            [ test "if a new option matches the selected option update the label and description" <|
                \_ ->
                    Expect.equalLists
                        [ wolfClub |> selectOption 0 ]
                        (mergeTwoListsOfOptionsPreservingSelectedOptions
                            SelectedItemStaysInPlace
                            [ newOption "Wolf Club" Nothing |> selectOption 0 ]
                            [ wolfClub ]
                        )
            , test "if a new option matches the selected option update the description even when adding a bunch of new options" <|
                \_ ->
                    Expect.equalLists
                        [ wolfClub |> selectOption 0, timecop1983, heartBones ]
                        (mergeTwoListsOfOptionsPreservingSelectedOptions
                            SelectedItemStaysInPlace
                            [ newOption "Wolf Club" Nothing |> selectOption 0 ]
                            [ wolfClub, timecop1983, heartBones ]
                        )
            , test "a selection option should stay in the same spot in the list" <|
                \_ ->
                    Expect.equalLists
                        [ timecop1983, heartBones, wolfClub |> selectOption 0 ]
                        (mergeTwoListsOfOptionsPreservingSelectedOptions
                            SelectedItemStaysInPlace
                            [ newOption "Wolf Club" Nothing |> selectOption 0 ]
                            [ timecop1983, heartBones, wolfClub ]
                        )
            , test "a selected option should move to the top of the list of options (when that option is set)" <|
                \_ ->
                    Expect.equalLists
                        [ wolfClub |> selectOption 0, timecop1983, heartBones ]
                        (mergeTwoListsOfOptionsPreservingSelectedOptions
                            SelectedItemMovesToTheTop
                            [ newOption "Wolf Club" Nothing |> selectOption 0 ]
                            [ timecop1983, heartBones, wolfClub ]
                        )
            , describe "with auto sort order rank"
                [ test "new options should get added to the end of the list of options" <|
                    \_ ->
                        Expect.equalLists
                            [ heartBones |> Option.setMaybeSortRank (newMaybeAutoSortRank 3)
                            , wolfClub |> Option.setMaybeSortRank (newMaybeAutoSortRank 1)
                            , timecop1983 |> Option.setMaybeSortRank (newMaybeAutoSortRank 2)
                            ]
                            (addAdditionalOptionsToOptionListWithAutoSortRank
                                [ wolfClub |> Option.setMaybeSortRank (newMaybeAutoSortRank 1)
                                , timecop1983 |> Option.setMaybeSortRank (newMaybeAutoSortRank 2)
                                ]
                                [ heartBones ]
                            )
                , test "multiple new options should get added to the end of the list of options" <|
                    \_ ->
                        Expect.equalLists
                            [ heartBones |> Option.setMaybeSortRank (newMaybeAutoSortRank 6)
                            , timecop1983 |> Option.setMaybeSortRank (newMaybeAutoSortRank 7)
                            , wolfClub |> Option.setMaybeSortRank (newMaybeAutoSortRank 5)
                            ]
                            (addAdditionalOptionsToOptionListWithAutoSortRank
                                [ wolfClub |> Option.setMaybeSortRank (newMaybeAutoSortRank 5)
                                ]
                                [ heartBones, timecop1983 ]
                            )
                ]
            ]
        , describe "and merging them with existing options"
            [ test "we should keep label and descriptions" <|
                \_ ->
                    Expect.equalLists
                        [ wolfClub
                        ]
                        (mergeTwoListsOfOptionsPreservingSelectedOptions
                            SelectedItemStaysInPlace
                            [ wolfClub
                            ]
                            [ newOption "Wolf Club" Nothing ]
                        )
            ]
        , describe "mering two options"
            [ test "should preserve label and description when the option with the label and description is first" <|
                \_ ->
                    Expect.equal
                        wolfClub
                        (merge2Options wolfClub (newOption "Wolf Club" Nothing))
            , test "should preserve label and description when the option with the label and description is second" <|
                \_ ->
                    Expect.equal
                        wolfClub
                        (merge2Options (newOption "Wolf Club" Nothing) wolfClub)
            ]
        ]
