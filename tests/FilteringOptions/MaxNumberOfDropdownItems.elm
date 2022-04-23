module FilteringOptions.MaxNumberOfDropdownItems exposing (suite)

import Expect
import Main exposing (figureOutWhichOptionsToShowInTheDropdown)
import Option exposing (highlightOptionInList, newOption, selectOptionInList, setGroupWithString)
import OptionSearcher
import PositiveInt
import SelectionMode exposing (CustomOptions(..), SelectedItemPlacementMode(..), SelectionMode(..), SingleItemRemoval(..))
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


xActoKnife =
    newOption "xActo" Nothing
        |> setGroupWithString "Hand Tool"


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


ten =
    PositiveInt.new 10


nine =
    PositiveInt.new 9


five =
    PositiveInt.new 5


six =
    PositiveInt.new 6


three =
    PositiveInt.new 3


equalOptionListValues : List Option.Option -> List Option.Option -> Expect.Expectation
equalOptionListValues optionsA optionsB =
    Expect.equalLists
        (List.map Option.getOptionValue optionsA)
        (List.map Option.getOptionValue optionsB)


suite : Test
suite =
    describe "Calculate which options to show in the dropdown"
        [ describe "when we have fewer options than the max"
            [ test "it should show all the options if nothing in highlighted" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShowInTheDropdown ten tools)
                        tools
            , test "it should show no options if the list is empty" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShowInTheDropdown ten [])
                        []
            , test "it shows all the options even if something is highlighted" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShowInTheDropdown ten (highlightOptionInList wrench tools))
                        (highlightOptionInList wrench tools)
            ]
        , describe "when we have the same number of options as the max"
            [ test "it should show all the options if nothing in highlighted" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShowInTheDropdown nine tools)
                        tools
            , test "it should show no options if the list is empty" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShowInTheDropdown nine [])
                        []
            , test "it shows all the options even if something is highlighted" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShowInTheDropdown nine (highlightOptionInList wrench tools))
                        (highlightOptionInList wrench tools)
            ]
        , describe "when we have more options than the max (which is odd)"
            [ test "it should show all the maximum number of options starting at the start of the list if nothing in highlighted" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShowInTheDropdown five tools)
                        [ screwDriver
                        , drill
                        , multiMeter
                        , sawZaw
                        , wrench
                        ]
            , test "it shows the options around the highlighted option" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShowInTheDropdown five (highlightOptionInList wrench tools))
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
                        (figureOutWhichOptionsToShowInTheDropdown five (highlightOptionInList xActoKnife tools))
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
                        (figureOutWhichOptionsToShowInTheDropdown five (highlightOptionInList drill tools))
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
                        (figureOutWhichOptionsToShowInTheDropdown five (highlightOptionInList signalTester tools))
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
                        (figureOutWhichOptionsToShowInTheDropdown six tools)
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
                        (figureOutWhichOptionsToShowInTheDropdown six (highlightOptionInList wrench tools))
            , test "it shows the maximum number of options before the highlighted option if the highlighted option is the last one" <|
                \_ ->
                    Expect.equalLists
                        (figureOutWhichOptionsToShowInTheDropdown six (highlightOptionInList xActoKnife tools))
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
                        (figureOutWhichOptionsToShowInTheDropdown six (highlightOptionInList drill tools))
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
                        (figureOutWhichOptionsToShowInTheDropdown six (highlightOptionInList signalTester tools))
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
                        (figureOutWhichOptionsToShowInTheDropdown three (selectOptionInList wrench tools))
            ]
        , describe "when we have options that are selected and highlighted"
            [ test "it should show the options around the highlighted option" <|
                \_ ->
                    Expect.equalLists
                        (highlightOptionInList wrench
                            [ sawZaw
                            , wrench
                            , hammer
                            ]
                        )
                        (figureOutWhichOptionsToShowInTheDropdown three
                            (tools
                                |> selectOptionInList xActoKnife
                                |> highlightOptionInList wrench
                            )
                        )
            ]
        , describe "if there are strong matches"
            [ test "we should hide everything else" <|
                \_ ->
                    equalOptionListValues
                        (highlightOptionInList wrench
                            [ wrench
                            ]
                        )
                        (figureOutWhichOptionsToShowInTheDropdown three
                            (tools
                                |> OptionSearcher.updateOptionsWithSearchStringAndCustomOption
                                    (MultiSelect NoCustomOptions DisableSingleItemRemoval)
                                    Nothing
                                    "wrench"
                                    (PositiveInt.new 2)
                                |> highlightOptionInList wrench
                            )
                        )
            ]
        ]
