module Option.AddingOptions exposing (suite)

import Expect
import Option
    exposing
        ( addAdditionalOptionsToOptionList
        , addAndSelectOptionsInOptionsListByString
        , mergeTwoListsOfOptionsPreservingSelectedOptions
        , newOption
        , selectOption
        , setDescriptionWithString
        , setLabelWithString
        )
import SelectionMode exposing (SelectedItemPlacementMode(..))
import Test exposing (Test, describe, only, test)


heartBones =
    newOption "Heart Bones" Nothing


timecop1983 =
    newOption "Timecop1983" Nothing


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
        , describe "and selecting them"
            [ test "with the same value of an option already in the list, preserver the label" <|
                \_ ->
                    Expect.equalLists
                        [ selectOption 0 wolfClub ]
                        (addAndSelectOptionsInOptionsListByString SelectedItemStaysInPlace [ "Wolf Club" ] [ wolfClub ])
            , test "with the same value of a selected option already in the list preserver the label" <|
                \_ ->
                    Expect.equalLists
                        [ selectOption 0 wolfClub ]
                        (addAndSelectOptionsInOptionsListByString SelectedItemStaysInPlace [ "Wolf Club" ] [ selectOption 0 wolfClub ])
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
                            [ wolfClub, timecop1983, heartBones ]
                            [ newOption "Wolf Club" Nothing |> selectOption 0 ]
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
            ]
        ]
