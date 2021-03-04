module FilteringOptions.MaxNumberOfDropdownItems exposing (suite)

import Expect
import Main exposing (figureOutWhichOptionsToShow)
import Option exposing (highlightOptionInList, newOption, setGroup)
import Test exposing (Test, describe, test)


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


suite : Test
suite =
    describe "Calculate which options to show in the dropdown"
        [ describe "when we have fewer options than the max"
            [ test "it should show all the options if nothing in highlighted" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShow 10 tools)
                        tools
            , test "it should show no options if the list is empty" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShow 10 [])
                        []
            , test "it shows all the options even if something is highlighted" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShow 10 (highlightOptionInList wrench tools))
                        (highlightOptionInList wrench tools)
            ]
        , describe "when we have the same number of options as the max"
            [ test "it should show all the options if nothing in highlighted" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShow 8 tools)
                        tools
            , test "it should show no options if the list is empty" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShow 8 [])
                        []
            , test "it shows all the options even if something is highlighted" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShow 8 (highlightOptionInList wrench tools))
                        (highlightOptionInList wrench tools)
            ]
        , describe "when we have more options than the max (which is odd)"
            [ test "it should show all the maximum number of options starting at the start of the list if nothing in highlighted" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShow 5 tools)
                        [ screwDriver
                        , drill
                        , multiMeter
                        , sawZaw
                        , wrench
                        ]
            , test "it shows the options around the highlighted option" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShow 5 (highlightOptionInList wrench tools))
                        (highlightOptionInList wrench
                            [ multiMeter
                            , sawZaw
                            , wrench
                            , hammer
                            , chisel
                            ]
                        )
            ]
        ]
