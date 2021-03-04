module FilteringOptions.MaxNumberOfDropdownItems exposing (suite)

import Expect
import Main exposing (figureOutWhichOptionsToShow)
import Option exposing (highlightOptionInList, newOption, selectOptionInList, setGroup)
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


xActoKnife =
    newOption "xActo" Nothing
        |> setGroup "Hand Tool"


tools =
    [ screwDriver
    , drill
    , multiMeter
    , sawZaw
    , wrench
    , hammer
    , chisel
    , signalTester
    , xActoKnife
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
                        (figureOutWhichOptionsToShow 9 tools)
                        tools
            , test "it should show no options if the list is empty" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShow 9 [])
                        []
            , test "it shows all the options even if something is highlighted" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShow 9 (highlightOptionInList wrench tools))
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
            , test "it shows the maximum number of options before the highlighted option if the highlighted option is the last one" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShow 5 (highlightOptionInList xActoKnife tools))
                        (highlightOptionInList xActoKnife
                            [ wrench
                            , hammer
                            , chisel
                            , signalTester
                            , xActoKnife
                            ]
                        )
            , test "it shows the maximum number of options but offset if the highlighted option is just after the first one" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShow 5 (highlightOptionInList drill tools))
                        (highlightOptionInList drill
                            [ screwDriver
                            , drill
                            , multiMeter
                            , sawZaw
                            , wrench
                            ]
                        )
            , test "it shows the maximum number of options but offset if the highlighted option is just before the last one" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShow 5 (highlightOptionInList signalTester tools))
                        (highlightOptionInList signalTester
                            [ wrench
                            , hammer
                            , chisel
                            , signalTester
                            , xActoKnife
                            ]
                        )
            ]
        , describe "when we have more options than the max (which is even)"
            [ test "it should show all the maximum number of options starting at the start of the list if nothing in highlighted" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShow 6 tools)
                        [ screwDriver
                        , drill
                        , multiMeter
                        , sawZaw
                        , wrench
                        , hammer
                        ]
            , test "it shows the options around the highlighted option, but with an extra option after the highlighted option" <|
                \_ ->
                    Expect.equalLists
                        (highlightOptionInList wrench
                            [ multiMeter
                            , sawZaw
                            , wrench
                            , hammer
                            , chisel
                            , signalTester
                            ]
                        )
                        (figureOutWhichOptionsToShow 6 (highlightOptionInList wrench tools))
            , test "it shows the maximum number of options before the highlighted option if the highlighted option is the last one" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShow 6 (highlightOptionInList xActoKnife tools))
                        (highlightOptionInList xActoKnife
                            [ sawZaw
                            , wrench
                            , hammer
                            , chisel
                            , signalTester
                            , xActoKnife
                            ]
                        )
            , test "it shows the maximum number of options but offset if the highlighted option is just after the first one" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShow 6 (highlightOptionInList drill tools))
                        (highlightOptionInList drill
                            [ screwDriver
                            , drill
                            , multiMeter
                            , sawZaw
                            , wrench
                            , hammer
                            ]
                        )
            , test "it shows the maximum number of options but offset if the highlighted option is just before the last one" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShow 6 (highlightOptionInList signalTester tools))
                        (highlightOptionInList signalTester
                            [ sawZaw
                            , wrench
                            , hammer
                            , chisel
                            , signalTester
                            , xActoKnife
                            ]
                        )
            ]
        , describe "when we only have a selected option (nothing in highlighted)"
            [ test "it should show the options around the selected option" <|
                \_ ->
                    Expect.equalLists
                        (selectOptionInList wrench
                            [ sawZaw
                            , wrench
                            , hammer
                            ]
                        )
                        (figureOutWhichOptionsToShow 3 (selectOptionInList wrench tools))
            ]
        , describe "when we options that are selected and highlighted"
            [ test "it should show the options around the highlighted option" <|
                \_ ->
                    Expect.equalLists
                        (highlightOptionInList wrench
                            [ sawZaw
                            , wrench
                            , hammer
                            ]
                        )
                        (figureOutWhichOptionsToShow 3
                            (tools
                                |> highlightOptionInList wrench
                                |> selectOptionInList xActoKnife
                            )
                        )
            ]
        ]
