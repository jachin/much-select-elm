module FilteringOptions.MaxNumberOfDropdownItems exposing (suite)

import DropdownOptions exposing (figureOutWhichOptionsToShowInTheDropdown)
import Expect exposing (Expectation)
import Option exposing (setGroupWithString, test_newFancyOption)
import OptionList exposing (OptionList(..))
import OptionSearcher
import OutputStyle exposing (MaxDropdownItems(..), SearchStringMinimumLength(..))
import PositiveInt
import SearchString
import SelectionMode exposing (OutputStyle(..), SelectionConfig(..), defaultSelectionConfig)
import Test exposing (Test, describe, test)


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


xActoKnife =
    test_newFancyOption "xActo" Nothing
        |> setGroupWithString "Hand Tool"


tools =
    FancyOptionList
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
    FixedMaxDropdownItems (PositiveInt.new 10)


nine =
    FixedMaxDropdownItems (PositiveInt.new 9)


five =
    FixedMaxDropdownItems (PositiveInt.new 5)


six =
    FixedMaxDropdownItems (PositiveInt.new 6)


three =
    FixedMaxDropdownItems (PositiveInt.new 3)


equalOptionListValues : List Option.Option -> List Option.Option -> Expect.Expectation
equalOptionListValues optionsA optionsB =
    Expect.equalLists
        (List.map Option.getOptionValue optionsA)
        (List.map Option.getOptionValue optionsB)


selectionConfig =
    defaultSelectionConfig


selectionConfigMaxDropdownItemsTen =
    selectionConfig |> SelectionMode.setMaxDropdownItems ten


selectionConfigMaxDropdownItemsNine =
    selectionConfig |> SelectionMode.setMaxDropdownItems nine


selectionConfigMaxDropdownItemsSix =
    selectionConfig |> SelectionMode.setMaxDropdownItems six


selectionConfigMaxDropdownItemsFive =
    selectionConfig |> SelectionMode.setMaxDropdownItems five


selectionConfigMaxDropdownItemsThree =
    selectionConfig |> SelectionMode.setMaxDropdownItems three


searchStringMinLengthTwo =
    FixedSearchStringMinimumLength (PositiveInt.new 2)


multiSelectConfig =
    defaultSelectionConfig
        |> SelectionMode.setSelectionMode SelectionMode.MultiSelect
        |> SelectionMode.setSearchStringMinimumLength searchStringMinLengthTwo


assertEqualLists : OptionList -> OptionList -> Expectation
assertEqualLists optionListA optionListB =
    Expect.equalLists
        (optionListA |> OptionList.getOptions |> List.map Option.getOptionValueAsString)
        (optionListB |> OptionList.getOptions |> List.map Option.getOptionValueAsString)


emptyFancyList =
    FancyOptionList []


suite : Test
suite =
    describe "Calculate which options to show in the dropdown"
        [ describe "when we have fewer options than the max"
            [ test "it should show all the options if nothing in highlighted" <|
                \_ ->
                    assertEqualLists
                        (figureOutWhichOptionsToShowInTheDropdown selectionConfigMaxDropdownItemsTen tools |> DropdownOptions.test_getOptions)
                        tools
            , test "it should show no options if the list is empty" <|
                \_ ->
                    assertEqualLists
                        (figureOutWhichOptionsToShowInTheDropdown selectionConfigMaxDropdownItemsTen emptyFancyList |> DropdownOptions.test_getOptions)
                        emptyFancyList
            , test "it shows all the options even if something is highlighted" <|
                \_ ->
                    assertEqualLists
                        (figureOutWhichOptionsToShowInTheDropdown selectionConfigMaxDropdownItemsTen
                            (OptionList.highlightOption wrench tools)
                            |> DropdownOptions.test_getOptions
                        )
                        (OptionList.highlightOption wrench tools)
            ]
        , describe "when we have the same number of options as the max"
            [ test "it should show all the options if nothing in highlighted" <|
                \_ ->
                    assertEqualLists
                        (figureOutWhichOptionsToShowInTheDropdown
                            selectionConfigMaxDropdownItemsNine
                            tools
                            |> DropdownOptions.test_getOptions
                        )
                        tools
            , test "it should show no options if the list is empty" <|
                \_ ->
                    assertEqualLists
                        (figureOutWhichOptionsToShowInTheDropdown selectionConfigMaxDropdownItemsNine emptyFancyList
                            |> DropdownOptions.test_getOptions
                        )
                        emptyFancyList
            , test "it shows all the options even if something is highlighted" <|
                \_ ->
                    assertEqualLists
                        (figureOutWhichOptionsToShowInTheDropdown selectionConfigMaxDropdownItemsNine (OptionList.highlightOption wrench tools)
                            |> DropdownOptions.test_getOptions
                        )
                        (OptionList.highlightOption wrench tools)
            ]
        , describe "when we have more options than the max (which is odd)"
            [ test "it should show all the maximum number of options starting at the start of the list if nothing in highlighted" <|
                \_ ->
                    assertEqualLists
                        (figureOutWhichOptionsToShowInTheDropdown selectionConfigMaxDropdownItemsFive tools |> DropdownOptions.test_getOptions)
                        (FancyOptionList
                            [ screwDriver
                            , drill
                            , multiMeter
                            , sawZaw
                            , wrench
                            ]
                        )
            , test "it shows the options around the highlighted option" <|
                \_ ->
                    assertEqualLists
                        (figureOutWhichOptionsToShowInTheDropdown selectionConfigMaxDropdownItemsFive (OptionList.highlightOption wrench tools) |> DropdownOptions.test_getOptions)
                        (OptionList.highlightOption wrench
                            (FancyOptionList
                                [ multiMeter
                                , sawZaw
                                , wrench
                                , hammer
                                , chisel
                                ]
                            )
                        )
            , test "it shows the maximum number of options before the highlighted option if the highlighted option is the last one" <|
                \_ ->
                    assertEqualLists
                        (figureOutWhichOptionsToShowInTheDropdown selectionConfigMaxDropdownItemsFive (OptionList.highlightOption xActoKnife tools) |> DropdownOptions.test_getOptions)
                        (OptionList.highlightOption xActoKnife
                            (FancyOptionList
                                [ wrench
                                , hammer
                                , chisel
                                , signalTester
                                , xActoKnife
                                ]
                            )
                        )
            , test "it shows the maximum number of options but offset if the highlighted option is just after the first one" <|
                \_ ->
                    assertEqualLists
                        (figureOutWhichOptionsToShowInTheDropdown selectionConfigMaxDropdownItemsFive (OptionList.highlightOption drill tools) |> DropdownOptions.test_getOptions)
                        (OptionList.highlightOption drill
                            (FancyOptionList
                                [ screwDriver
                                , drill
                                , multiMeter
                                , sawZaw
                                , wrench
                                ]
                            )
                        )
            , test "it shows the maximum number of options but offset if the highlighted option is just before the last one" <|
                \_ ->
                    assertEqualLists
                        (figureOutWhichOptionsToShowInTheDropdown selectionConfigMaxDropdownItemsFive (OptionList.highlightOption signalTester tools) |> DropdownOptions.test_getOptions)
                        (OptionList.highlightOption signalTester
                            (FancyOptionList
                                [ wrench
                                , hammer
                                , chisel
                                , signalTester
                                , xActoKnife
                                ]
                            )
                        )
            ]
        , describe "when we have more options than the max (which is even)"
            [ test "it should show all the maximum number of options starting at the start of the list if nothing in highlighted" <|
                \_ ->
                    assertEqualLists
                        (figureOutWhichOptionsToShowInTheDropdown selectionConfigMaxDropdownItemsSix tools |> DropdownOptions.test_getOptions)
                        (FancyOptionList
                            [ screwDriver
                            , drill
                            , multiMeter
                            , sawZaw
                            , wrench
                            , hammer
                            ]
                        )
            , test "it shows the options around the highlighted option, but with an extra option after the highlighted option" <|
                \_ ->
                    assertEqualLists
                        (OptionList.highlightOption wrench
                            (FancyOptionList
                                [ multiMeter
                                , sawZaw
                                , wrench
                                , hammer
                                , chisel
                                , signalTester
                                ]
                            )
                        )
                        (figureOutWhichOptionsToShowInTheDropdown selectionConfigMaxDropdownItemsSix (OptionList.highlightOption wrench tools) |> DropdownOptions.test_getOptions)
            , test "it shows the maximum number of options before the highlighted option if the highlighted option is the last one" <|
                \_ ->
                    assertEqualLists
                        (figureOutWhichOptionsToShowInTheDropdown selectionConfigMaxDropdownItemsSix (OptionList.highlightOption xActoKnife tools) |> DropdownOptions.test_getOptions)
                        (OptionList.highlightOption xActoKnife
                            (FancyOptionList
                                [ sawZaw
                                , wrench
                                , hammer
                                , chisel
                                , signalTester
                                , xActoKnife
                                ]
                            )
                        )
            , test "it shows the maximum number of options but offset if the highlighted option is just after the first one" <|
                \_ ->
                    assertEqualLists
                        (figureOutWhichOptionsToShowInTheDropdown selectionConfigMaxDropdownItemsSix (OptionList.highlightOption drill tools) |> DropdownOptions.test_getOptions)
                        (OptionList.highlightOption drill
                            (FancyOptionList
                                [ screwDriver
                                , drill
                                , multiMeter
                                , sawZaw
                                , wrench
                                , hammer
                                ]
                            )
                        )
            , test "it shows the maximum number of options but offset if the highlighted option is just before the last one" <|
                \_ ->
                    assertEqualLists
                        (figureOutWhichOptionsToShowInTheDropdown selectionConfigMaxDropdownItemsSix (OptionList.highlightOption signalTester tools) |> DropdownOptions.test_getOptions)
                        (OptionList.highlightOption signalTester
                            (FancyOptionList
                                [ sawZaw
                                , wrench
                                , hammer
                                , chisel
                                , signalTester
                                , xActoKnife
                                ]
                            )
                        )
            ]
        , describe "when we only have a selected option (nothing in highlighted)"
            [ test "it should show the options around the selected option" <|
                \_ ->
                    assertEqualLists
                        (OptionList.selectOption wrench
                            (FancyOptionList
                                [ sawZaw
                                , wrench
                                , hammer
                                ]
                            )
                        )
                        (figureOutWhichOptionsToShowInTheDropdown selectionConfigMaxDropdownItemsThree (OptionList.selectOption wrench tools)
                            |> DropdownOptions.test_getOptions
                        )
            ]
        , describe "when we have options that are selected and highlighted"
            [ test "it should show the options around the highlighted option" <|
                \_ ->
                    assertEqualLists
                        (OptionList.highlightOption wrench
                            (FancyOptionList
                                [ sawZaw
                                , wrench
                                , hammer
                                ]
                            )
                        )
                        (figureOutWhichOptionsToShowInTheDropdown selectionConfigMaxDropdownItemsThree
                            (tools
                                |> OptionList.selectOption xActoKnife
                                |> OptionList.highlightOption wrench
                            )
                            |> DropdownOptions.test_getOptions
                        )
            ]
        , describe "if there are strong matches"
            [ test "we should hide everything else" <|
                \_ ->
                    assertEqualLists
                        (OptionList.highlightOption wrench
                            (FancyOptionList
                                [ wrench
                                ]
                            )
                        )
                        (figureOutWhichOptionsToShowInTheDropdown multiSelectConfig
                            (tools
                                |> OptionSearcher.updateOptionsWithSearchStringAndCustomOption
                                    multiSelectConfig
                                    (SearchString.update "wrench")
                                |> OptionList.highlightOption wrench
                            )
                            |> DropdownOptions.test_getOptions
                        )
            ]
        ]
