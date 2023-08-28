module Option.Sorting exposing (suite)

import Expect
import Option exposing (Option(..), setGroupWithString, test_newFancyOption, test_optionToDebuggingString)
import OptionList exposing (findHighestAutoSortRank)
import OptionSorting exposing (OptionSort(..), sortOptions)
import SortRank exposing (newMaybeAutoSortRank)
import Test exposing (Test, describe, test)


heartBones =
    test_newFancyOption "Heart Bones" Nothing


timecop1983 =
    test_newFancyOption "Timecop1983" Nothing


wolfClub =
    test_newFancyOption "W O L F C L U B" Nothing


waveshaper =
    test_newFancyOption "Waveshaper" Nothing


musicList =
    [ waveshaper
    , timecop1983
    , wolfClub
    , heartBones
    ]


screwDriver =
    test_newFancyOption "Screw Driver" Nothing
        |> setGroupWithString "Hand Tool"


wrench =
    test_newFancyOption "Wrench" Nothing
        |> setGroupWithString "Hand Tool"


hammer =
    test_newFancyOption "Hammer" Nothing
        |> setGroupWithString "Hand Tool"


chisel =
    test_newFancyOption "Chisel" Nothing
        |> setGroupWithString "Hand Tool"


multiMeter =
    test_newFancyOption "Multi Meter" Nothing
        |> setGroupWithString "Electronic Instrument"


signalTester =
    test_newFancyOption "Signal Tester" Nothing
        |> setGroupWithString "Electronic Instrument"


drill =
    test_newFancyOption "Drill" Nothing
        |> setGroupWithString "Power Tool"


sawZaw =
    test_newFancyOption "Saw Zaw" Nothing
        |> setGroupWithString "Power Tool"


tools =
    [ screwDriver
    , drill
    , multiMeter
    , sawZaw
    , wrench
    , hammer
    , chisel
    , signalTester
    ]


suite : Test
suite =
    describe "Sorting lists of options"
        [ describe "sort list of options by group and label"
            [ test "Expect options with no group to just be sorted by their label" <|
                \_ ->
                    Expect.equalLists
                        (musicList
                            |> sortOptions NoSorting
                            |> List.map test_optionToDebuggingString
                        )
                        ([ heartBones
                         , timecop1983
                         , wolfClub
                         , waveshaper
                         ]
                            |> List.map test_optionToDebuggingString
                        )
            , test "options with groups should be sorted by their groups and then by their label" <|
                \_ ->
                    Expect.equalLists
                        (tools |> sortOptions NoSorting |> List.map test_optionToDebuggingString)
                        ([ chisel
                         , hammer
                         , screwDriver
                         , wrench
                         , drill
                         , sawZaw
                         , multiMeter
                         , signalTester
                         ]
                            |> List.map test_optionToDebuggingString
                        )
            ]
        , describe "getting the highest sorted "
            [ test "when there is just 1" <|
                \_ ->
                    Expect.equal
                        (OptionList.FancyOptionList [ screwDriver |> Option.setMaybeSortRank (newMaybeAutoSortRank 1) ] |> findHighestAutoSortRank)
                        1
            , test "when there is more than 1" <|
                \_ ->
                    Expect.equal
                        (OptionList.FancyOptionList
                            [ hammer |> Option.setMaybeSortRank (newMaybeAutoSortRank 1)
                            , drill |> Option.setMaybeSortRank (newMaybeAutoSortRank 2)
                            , screwDriver |> Option.setMaybeSortRank (newMaybeAutoSortRank 3)
                            ]
                            |> findHighestAutoSortRank
                        )
                        3
            ]
        ]
