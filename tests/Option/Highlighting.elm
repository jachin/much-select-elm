module Option.Highlighting exposing (suite)

import DropdownOptions exposing (moveHighlightedOptionDown, moveHighlightedOptionUp)
import Expect
import Option exposing (test_newFancyOption)
import OptionList exposing (OptionList(..))
import SelectionMode
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Change the highlighted option"
        [ describe "by moving the highlighted option down"
            [ test "but if no option is already highlighted, highlight the first (top) option" <|
                \_ ->
                    let
                        options =
                            FancyOptionList
                                [ test_newFancyOption "one" Nothing
                                , test_newFancyOption "two" Nothing
                                , test_newFancyOption "three" Nothing
                                ]
                    in
                    Expect.equal
                        (moveHighlightedOptionDown SelectionMode.defaultSelectionConfig options)
                        (FancyOptionList
                            [ test_newFancyOption "one" Nothing |> Option.highlightOption
                            , test_newFancyOption "two" Nothing
                            , test_newFancyOption "three" Nothing
                            ]
                        )
            , test "highlight the next highlightable option, not skipping over the selected option" <|
                \_ ->
                    let
                        options =
                            FancyOptionList
                                [ test_newFancyOption "one" Nothing |> Option.highlightOption
                                , test_newFancyOption "two" Nothing |> Option.selectOption 0
                                , test_newFancyOption "three" Nothing
                                ]
                    in
                    Expect.equal
                        (moveHighlightedOptionDown SelectionMode.defaultSelectionConfig options)
                        (FancyOptionList
                            [ test_newFancyOption "one" Nothing
                            , test_newFancyOption "two" Nothing |> Option.selectOption 0 |> Option.highlightOption
                            , test_newFancyOption "three" Nothing
                            ]
                        )
            , test "highlight the next highlightable option, skipping over disabled options" <|
                \_ ->
                    let
                        options =
                            FancyOptionList
                                [ test_newFancyOption "one" Nothing |> Option.highlightOption
                                , Option.newDisabledOption "two" Nothing
                                , Option.newDisabledOption "three" Nothing
                                , test_newFancyOption "four" Nothing
                                ]
                    in
                    Expect.equal
                        (moveHighlightedOptionDown SelectionMode.defaultSelectionConfig options)
                        (FancyOptionList
                            [ test_newFancyOption "one" Nothing
                            , Option.newDisabledOption "two" Nothing
                            , Option.newDisabledOption "three" Nothing
                            , test_newFancyOption "four" Nothing |> Option.highlightOption
                            ]
                        )
            ]
        , describe "by moving the highlighted option up"
            [ test "but if no option is already highlighted, highlight the first (top) option" <|
                \_ ->
                    let
                        options =
                            FancyOptionList
                                [ test_newFancyOption "one" Nothing
                                , test_newFancyOption "two" Nothing
                                , test_newFancyOption "three" Nothing
                                ]
                    in
                    Expect.equal
                        (moveHighlightedOptionUp SelectionMode.defaultSelectionConfig options)
                        (FancyOptionList
                            [ test_newFancyOption "one" Nothing |> Option.highlightOption
                            , test_newFancyOption "two" Nothing
                            , test_newFancyOption "three" Nothing
                            ]
                        )
            , test "highlight the previous highlightable option, not skipping over the selected option" <|
                \_ ->
                    let
                        options =
                            FancyOptionList
                                [ test_newFancyOption "one" Nothing
                                , test_newFancyOption "two" Nothing |> Option.selectOption 0
                                , test_newFancyOption "three" Nothing |> Option.highlightOption
                                ]
                    in
                    Expect.equal
                        (moveHighlightedOptionUp SelectionMode.defaultSelectionConfig options)
                        (FancyOptionList
                            [ test_newFancyOption "one" Nothing
                            , test_newFancyOption "two" Nothing |> Option.selectOption 0 |> Option.highlightOption
                            , test_newFancyOption "three" Nothing
                            ]
                        )
            , test "highlight the previous highlightable option, skipping over disabled options" <|
                \_ ->
                    let
                        options =
                            FancyOptionList
                                [ test_newFancyOption "one" Nothing
                                , Option.newDisabledOption "two" Nothing
                                , Option.newDisabledOption "three" Nothing
                                , test_newFancyOption "four" Nothing |> Option.highlightOption
                                ]
                    in
                    Expect.equal
                        (moveHighlightedOptionUp SelectionMode.defaultSelectionConfig options)
                        (FancyOptionList
                            [ test_newFancyOption "one" Nothing |> Option.highlightOption
                            , Option.newDisabledOption "two" Nothing
                            , Option.newDisabledOption "three" Nothing
                            , test_newFancyOption "four" Nothing
                            ]
                        )
            , test "highlight the previous highlightable option in the middle of a long list" <|
                \_ ->
                    let
                        options =
                            FancyOptionList
                                [ test_newFancyOption "one" Nothing
                                , test_newFancyOption "two" Nothing
                                , test_newFancyOption "three" Nothing |> Option.highlightOption
                                , test_newFancyOption "four" Nothing
                                , test_newFancyOption "five" Nothing
                                ]
                    in
                    Expect.equal
                        (moveHighlightedOptionUp SelectionMode.defaultSelectionConfig options)
                        (FancyOptionList
                            [ test_newFancyOption "one" Nothing
                            , test_newFancyOption "two" Nothing |> Option.highlightOption
                            , test_newFancyOption "three" Nothing
                            , test_newFancyOption "four" Nothing
                            , test_newFancyOption "five" Nothing
                            ]
                        )
            ]
        ]
