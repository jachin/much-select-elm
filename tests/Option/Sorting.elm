module Option.Sorting exposing (suite)

import Expect
import Option exposing (Option(..), newOption, optionGroupToString, optionLabelToString, setGroup, sortOptionsByGroupAndLabel)
import Test exposing (Test, describe, test)


heartBones =
    newOption "Heart Bones" Nothing


timecop1983 =
    newOption "Timecop1983" Nothing


wolfClub =
    newOption "W O L F C L U B" Nothing


waveshaper =
    newOption "Waveshaper" Nothing


musicList =
    [ waveshaper
    , timecop1983
    , wolfClub
    , heartBones
    ]


screwDriver =
    newOption "Screw Driver" Nothing
        |> setGroup "Hand Tool"


wrench =
    newOption "Wrench" Nothing
        |> setGroup "Hand Tool"


hammer =
    newOption "Hammer" Nothing
        |> setGroup "Hand Tool"


chisel =
    newOption "Chisel" Nothing
        |> setGroup "Hand Tool"


multiMeter =
    newOption "Multi Meter" Nothing
        |> setGroup "Electronic Instrument"


signalTester =
    newOption "Signal Tester" Nothing
        |> setGroup "Electronic Instrument"


drill =
    newOption "Drill" Nothing
        |> setGroup "Power Tool"


sawZaw =
    newOption "Saw Zaw" Nothing
        |> setGroup "Power Tool"


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


optionToDebuggingString : Option -> String
optionToDebuggingString option =
    case option of
        Option _ optionLabel _ _ optionGroup _ ->
            case optionGroupToString optionGroup of
                "" ->
                    optionLabelToString optionLabel

                optionGroupString ->
                    optionGroupString ++ " - " ++ optionLabelToString optionLabel

        CustomOption _ optionLabel _ _ ->
            optionLabelToString optionLabel

        EmptyOption _ optionLabel ->
            optionLabelToString optionLabel


suite : Test
suite =
    describe "Sorting lists of options"
        [ describe "sort list of options by group and label"
            [ test "Expect options with no group to just be sorted by their label" <|
                \_ ->
                    Expect.equalLists
                        (musicList
                            |> sortOptionsByGroupAndLabel
                            |> List.map optionToDebuggingString
                        )
                        ([ heartBones
                         , timecop1983
                         , wolfClub
                         , waveshaper
                         ]
                            |> List.map optionToDebuggingString
                        )
            , test "options with groups should be sorted by their groups and then by their label" <|
                \_ ->
                    Expect.equalLists
                        (tools |> sortOptionsByGroupAndLabel |> List.map optionToDebuggingString)
                        ([ chisel
                         , hammer
                         , screwDriver
                         , wrench
                         , drill
                         , sawZaw
                         , multiMeter
                         , signalTester
                         ]
                            |> List.map optionToDebuggingString
                        )
            ]
        ]
