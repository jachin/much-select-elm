module Option.Highlighting exposing (suite)

import Expect
import Option
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Change the highlighted option"
        [ describe "by moving the highlighted option down"
            [ test "but if no option is already highlighted, highlight the first (top) option" <|
                \_ ->
                    Expect.equal
                        ([ Option.newOption "one"
                         , Option.newOption "two"
                         , Option.newOption "three"
                         ]
                            |> Option.moveHighlightedOptionDown
                        )
                        [ Option.newOption "one" |> Option.highlightOption
                        , Option.newOption "two"
                        , Option.newOption "three"
                        ]
            , test "highlight the next highlightable option, skipping over the selected option" <|
                \_ ->
                    Expect.equal
                        ([ Option.newOption "one" |> Option.highlightOption
                         , Option.newOption "two" |> Option.selectOption
                         , Option.newOption "three"
                         ]
                            |> Option.moveHighlightedOptionDown
                        )
                        [ Option.newOption "one"
                        , Option.newOption "two" |> Option.selectOption
                        , Option.newOption "three" |> Option.highlightOption
                        ]
            , test "highlight the next highlightable option, skipping over disabled options" <|
                \_ ->
                    Expect.equal
                        ([ Option.newOption "one" |> Option.highlightOption
                         , Option.newDisabledOption "two"
                         , Option.newDisabledOption "three"
                         , Option.newOption "four"
                         ]
                            |> Option.moveHighlightedOptionDown
                        )
                        [ Option.newOption "one"
                        , Option.newDisabledOption "two"
                        , Option.newDisabledOption "three"
                        , Option.newOption "four" |> Option.highlightOption
                        ]
            ]
        , describe "by moving the highlighted option up"
            [ test "but if no option is already highlighted, highlight the first (top) option" <|
                \_ ->
                    Expect.equal
                        ([ Option.newOption "one"
                         , Option.newOption "two"
                         , Option.newOption "three"
                         ]
                            |> Option.moveHighlightedOptionUp
                        )
                        [ Option.newOption "one" |> Option.highlightOption
                        , Option.newOption "two"
                        , Option.newOption "three"
                        ]
            , test "highlight the previous highlightable option, skipping over the selected option" <|
                \_ ->
                    Expect.equal
                        ([ Option.newOption "one"
                         , Option.newOption "two" |> Option.selectOption
                         , Option.newOption "three" |> Option.highlightOption
                         ]
                            |> Option.moveHighlightedOptionUp
                        )
                        [ Option.newOption "one" |> Option.highlightOption
                        , Option.newOption "two" |> Option.selectOption
                        , Option.newOption "three"
                        ]
            , test "highlight the previous highlightable option, skipping over disabled options" <|
                \_ ->
                    Expect.equal
                        ([ Option.newOption "one"
                         , Option.newDisabledOption "two"
                         , Option.newDisabledOption "three"
                         , Option.newOption "four" |> Option.highlightOption
                         ]
                            |> Option.moveHighlightedOptionUp
                        )
                        [ Option.newOption "one" |> Option.highlightOption
                        , Option.newDisabledOption "two"
                        , Option.newDisabledOption "three"
                        , Option.newOption "four"
                        ]
            , test "highlight the previous highlightable option in the middle of a long list" <|
                \_ ->
                    Expect.equal
                        ([ Option.newOption "one"
                         , Option.newOption "two"
                         , Option.newOption "three" |> Option.highlightOption
                         , Option.newOption "four"
                         , Option.newOption "five"
                         ]
                            |> Option.moveHighlightedOptionUp
                        )
                        [ Option.newOption "one"
                        , Option.newOption "two" |> Option.highlightOption
                        , Option.newOption "three"
                        , Option.newOption "four"
                        , Option.newOption "five"
                        ]
            ]
        ]
