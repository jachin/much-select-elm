module Highlighting exposing (suite)

import Expect
import Html exposing (span, text)
import OptionPresentor exposing (highlightMarkup, indexInsideMatch, simpleMatch)
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
            ]

        --, test "simple match in the middle" <|
        --    \_ ->
        --        let
        --            _ =
        --                Debug.log "straightUpMatchResult" straightUpMatchResult
        --
        --            _ =
        --                Debug.log "colorResult" colorResult
        --        in
        --        Expect.equal (highlightMarkup "orange red purple" colorResult)
        --            (span [] [ text "orange ", span [] [ text "red" ], text " purple" ])
        ]
