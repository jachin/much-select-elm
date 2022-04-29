module Option.OrderingInGroups exposing (suite)

import Expect
import Option exposing (Option(..), OptionGroup, newOption, newOptionGroup, optionGroupToString, optionValueToString, setGroupWithString)
import OptionLabel exposing (optionLabelToString)
import OptionsUtilities exposing (groupOptionsInOrder)
import Test exposing (Test, describe, test)


screwDriver =
    newOption "Screw Driver" Nothing
        |> setGroupWithString "Hand Tool"


wrench =
    newOption "Wrench" Nothing
        |> setGroupWithString "Hand Tool"


hammer =
    newOption "Hammer" Nothing
        |> setGroupWithString "Hand Tool"


chisel =
    newOption "Chisel" Nothing
        |> setGroupWithString "Hand Tool"


multiMeter =
    newOption "Multi Meter" Nothing
        |> setGroupWithString "Electronic Instrument"


signalTester =
    newOption "Signal Tester" Nothing
        |> setGroupWithString "Electronic Instrument"


drill =
    newOption "Drill" Nothing
        |> setGroupWithString "Power Tool"


sawZaw =
    newOption "Saw Zaw" Nothing
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

        DatalistOption _ optionValue ->
            optionValueToString optionValue


optionGroupToDebuggingString : OptionGroup -> String
optionGroupToDebuggingString optionGroup =
    optionGroupToString optionGroup


suite : Test
suite =
    describe "When we have a sorted list of options"
        [ test "keep them in order but group them by their option groups" <|
            \_ ->
                Expect.equalLists
                    (groupOptionsInOrder tools
                        |> List.map
                            (\( optionGroup, options ) ->
                                ( optionGroupToDebuggingString optionGroup
                                , List.map optionToDebuggingString options
                                )
                            )
                    )
                    ([ ( newOptionGroup "Hand Tool", [ screwDriver ] )
                     , ( newOptionGroup "Power Tool", [ drill ] )
                     , ( newOptionGroup "Electronic Instrument", [ multiMeter ] )
                     , ( newOptionGroup "Power Tool", [ sawZaw ] )
                     , ( newOptionGroup "Hand Tool", [ wrench, hammer, chisel ] )
                     , ( newOptionGroup "Electronic Instrument", [ signalTester ] )
                     ]
                        |> List.map
                            (\( optionGroup, options ) ->
                                ( optionGroupToDebuggingString optionGroup
                                , List.map optionToDebuggingString options
                                )
                            )
                    )
        ]
