module Option.OrderingInGroups exposing (suite)

import DropdownOptions
import Expect
import GroupedDropdownOptions
import Option
    exposing
        ( Option(..)
        , OptionGroup
        , newOption
        , newOptionGroup
        , optionGroupToString
        , setGroupWithString
        )
import OptionLabel exposing (optionLabelToString)
import OptionValue exposing (optionValueToString)
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


optionGroupToDebuggingString : OptionGroup -> String
optionGroupToDebuggingString optionGroup =
    optionGroupToString optionGroup


suite : Test
suite =
    describe "When we have a sorted list of options"
        [ test "keep them in order but group them by their option groups" <|
            \_ ->
                Expect.equalLists
                    (GroupedDropdownOptions.groupOptionsInOrder (DropdownOptions.test_fromOptions tools)
                        |> GroupedDropdownOptions.test_DropdownOptionsGroupToStringAndOptions
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
                                , List.map Option.test_optionToDebuggingString options
                                )
                            )
                    )
        ]
