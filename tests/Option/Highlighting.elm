module Option.Highlighting exposing (suite)

import Expect
import Option
import OptionsUtilities exposing (moveHighlightedOptionDown, moveHighlightedOptionUp)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Change the highlighted option"
        [ describe "by moving the highlighted option down"
            [ test "but if no option is already highlighted, highlight the first (top) option" <|
                \_ ->
                    Expect.equal
                        ([ Option.newOption "one" Nothing
                         , Option.newOption "two" Nothing
                         , Option.newOption "three" Nothing
                         ]
                            |> moveHighlightedOptionDown
                        )
                        [ Option.newOption "one" Nothing |> Option.highlightOption
                        , Option.newOption "two" Nothing
                        , Option.newOption "three" Nothing
                        ]
            , test "highlight the next highlightable option, skipping over the selected option" <|
                \_ ->
                    Expect.equal
                        ([ Option.newOption "one" Nothing |> Option.highlightOption
                         , Option.newOption "two" Nothing |> Option.selectOption 0
                         , Option.newOption "three" Nothing
                         ]
                            |> moveHighlightedOptionDown
                        )
                        [ Option.newOption "one" Nothing
                        , Option.newOption "two" Nothing |> Option.selectOption 0
                        , Option.newOption "three" Nothing |> Option.highlightOption
                        ]
            , test "highlight the next highlightable option, skipping over disabled options" <|
                \_ ->
                    Expect.equal
                        ([ Option.newOption "one" Nothing |> Option.highlightOption
                         , Option.newDisabledOption "two" Nothing
                         , Option.newDisabledOption "three" Nothing
                         , Option.newOption "four" Nothing
                         ]
                            |> moveHighlightedOptionDown
                        )
                        [ Option.newOption "one" Nothing
                        , Option.newDisabledOption "two" Nothing
                        , Option.newDisabledOption "three" Nothing
                        , Option.newOption "four" Nothing |> Option.highlightOption
                        ]
            ]
        , describe "by moving the highlighted option up"
            [ test "but if no option is already highlighted, highlight the first (top) option" <|
                \_ ->
                    Expect.equal
                        ([ Option.newOption "one" Nothing
                         , Option.newOption "two" Nothing
                         , Option.newOption "three" Nothing
                         ]
                            |> moveHighlightedOptionUp
                        )
                        [ Option.newOption "one" Nothing |> Option.highlightOption
                        , Option.newOption "two" Nothing
                        , Option.newOption "three" Nothing
                        ]
            , test "highlight the previous highlightable option, skipping over the selected option" <|
                \_ ->
                    Expect.equal
                        ([ Option.newOption "one" Nothing
                         , Option.newOption "two" Nothing |> Option.selectOption 0
                         , Option.newOption "three" Nothing |> Option.highlightOption
                         ]
                            |> moveHighlightedOptionUp
                        )
                        [ Option.newOption "one" Nothing |> Option.highlightOption
                        , Option.newOption "two" Nothing |> Option.selectOption 0
                        , Option.newOption "three" Nothing
                        ]
            , test "highlight the previous highlightable option, skipping over disabled options" <|
                \_ ->
                    Expect.equal
                        ([ Option.newOption "one" Nothing
                         , Option.newDisabledOption "two" Nothing
                         , Option.newDisabledOption "three" Nothing
                         , Option.newOption "four" Nothing |> Option.highlightOption
                         ]
                            |> moveHighlightedOptionUp
                        )
                        [ Option.newOption "one" Nothing |> Option.highlightOption
                        , Option.newDisabledOption "two" Nothing
                        , Option.newDisabledOption "three" Nothing
                        , Option.newOption "four" Nothing
                        ]
            , test "highlight the previous highlightable option in the middle of a long list" <|
                \_ ->
                    Expect.equal
                        ([ Option.newOption "one" Nothing
                         , Option.newOption "two" Nothing
                         , Option.newOption "three" Nothing |> Option.highlightOption
                         , Option.newOption "four" Nothing
                         , Option.newOption "five" Nothing
                         ]
                            |> moveHighlightedOptionUp
                        )
                        [ Option.newOption "one" Nothing
                        , Option.newOption "two" Nothing |> Option.highlightOption
                        , Option.newOption "three" Nothing
                        , Option.newOption "four" Nothing
                        , Option.newOption "five" Nothing
                        ]
            ]
        ]
