module Highlighting exposing (suite)

import Expect
import Html exposing (span, text)
import Html.Attributes exposing (class)
import OptionPresentor exposing (highlightMarkup, indexInsideMatch, simpleMatch, tokenize)
import Test exposing (Test, describe, test)


straightUpMatchResult =
    simpleMatch "red" "red"


noMatchResult =
    simpleMatch "q" "red"


colorResult =
    simpleMatch "red" "22 orange red purple 11"


suite : Test
suite =
    describe "Highlighting search results"
        [ describe "we need to know which characters are inside of a match and which are not"
            [ describe "a simple example where the whole needs matches the whole hay"
                [ test "Expected the first character to be part of a match" <|
                    \_ ->
                        Expect.true "" (indexInsideMatch straightUpMatchResult 0)
                , test "Expected the second character to be part of a match" <|
                    \_ ->
                        Expect.true "" (indexInsideMatch straightUpMatchResult 1)
                , test "Expected the third character to be part of a match" <|
                    \_ ->
                        Expect.true "" (indexInsideMatch straightUpMatchResult 2)
                , test "Expected the forth character to not be part of a match" <|
                    \_ ->
                        Expect.false "" (indexInsideMatch straightUpMatchResult 3)
                ]
            , describe "a simple example nothing in the needle matches in the hay"
                [ test "Expected the first character not to be part of a match" <|
                    \_ ->
                        Expect.false "" (indexInsideMatch noMatchResult 0)
                , test "Expected the second character not to be part of a match" <|
                    \_ ->
                        Expect.false "" (indexInsideMatch noMatchResult 1)
                , test "Expected the third character to not be part of a match" <|
                    \_ ->
                        Expect.false "" (indexInsideMatch noMatchResult 2)
                ]
            , describe "an example where the needle is in the middle of the hay"
                [ test "Expected the 1st character not to be part of a match" <|
                    \_ ->
                        Expect.false "" (indexInsideMatch colorResult 0)
                , test "Expected the 10th character not to be part of a match" <|
                    \_ ->
                        Expect.false "" (indexInsideMatch colorResult 9)
                , test "Expected the 11th character to be part of a match" <|
                    \_ ->
                        Expect.true "" (indexInsideMatch colorResult 10)
                , test "Expected the 12th character to be part of a match" <|
                    \_ ->
                        Expect.true "" (indexInsideMatch colorResult 11)
                , test "Expected the 13th character to be part of a match" <|
                    \_ ->
                        Expect.true "" (indexInsideMatch colorResult 12)
                , test "Expected the 14th character not to be part of a match" <|
                    \_ ->
                        Expect.false "" (indexInsideMatch colorResult 13)
                ]
            ]
        , test "a simple example where the needle and the hay are identical" <|
            \_ ->
                Expect.equal (tokenize "red" straightUpMatchResult)
                    [ ( True, "red" ) ]
        , test "an example where the needle is in the middle of some hay" <|
            \_ ->
                Expect.equal (tokenize "22 orange red purple 11" colorResult)
                    [ ( False, "22 orange " ), ( True, "red" ), ( False, " purple 11" ) ]
        ]
