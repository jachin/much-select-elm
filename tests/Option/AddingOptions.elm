module Option.AddingOptions exposing (suite)

import Expect
import Option exposing (addAdditionalOptionsToOptionList, addAndSelectOptionsInOptionsListByString, mergeTwoListsOfOptionsPreservingSelectedOptions, newOption, selectOption, setDescriptionWithString, setLabelWithString)
import Test exposing (Test, describe, test)


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
                    (addAdditionalOptionsToOptionList [ waveshaper ] [ heartBones ])
                    [ heartBones, waveshaper ]
        , test "with the same value of an option already in the list (single)" <|
            \_ ->
                Expect.equalLists
                    (addAdditionalOptionsToOptionList [ heartBones ] [ heartBones ])
                    [ heartBones ]
        , test "with the same value of an option already in the list" <|
            \_ ->
                Expect.equalLists
                    (addAdditionalOptionsToOptionList [ timecop1983, heartBones ] [ heartBones ])
                    [ timecop1983, heartBones ]
        , describe "and selecting them"
            [ test "with the same value of an option already in the list, preserver the label" <|
                \_ ->
                    Expect.equalLists
                        (addAndSelectOptionsInOptionsListByString [ "Wolf Club" ] [ wolfClub ])
                        [ selectOption wolfClub ]
            , test "with the same value of a selected option already in the list preserver the label" <|
                \_ ->
                    Expect.equalLists
                        (addAndSelectOptionsInOptionsListByString [ "Wolf Club" ] [ selectOption wolfClub ])
                        [ selectOption wolfClub ]
            ]
        , describe "and merging them with a selected value"
            [ test "if a new option matches the selected option update the label and description" <|
                \_ ->
                    Expect.equalLists
                        (mergeTwoListsOfOptionsPreservingSelectedOptions
                            [ newOption "Wolf Club" Nothing |> selectOption ]
                            [ wolfClub ]
                        )
                        [ wolfClub |> selectOption ]
            , test "if a new option matches the selected option update the description even when adding a bunch of new options" <|
                \_ ->
                    Expect.equalLists
                        (mergeTwoListsOfOptionsPreservingSelectedOptions
                            [ newOption "Wolf Club" Nothing |> selectOption ]
                            [ wolfClub, timecop1983, heartBones ]
                        )
                        [ wolfClub |> selectOption, timecop1983, heartBones ]
            ]
        ]
