module Highlighting exposing (suite)

import Expect
import Html exposing (span, text)
import OptionPresentor exposing (highlightMarkup, simpleMatch)
import Test exposing (Test, describe, test)


straightUpMatchResult =
    simpleMatch "red" "red"


colorResult =
    simpleMatch "red" "22 orange red purple 11"


suite : Test
suite =
    describe "Highlighting search results"
        [ test "simple match in the middle" <|
            \_ ->
                let
                    _ =
                        Debug.log "straightUpMatchResult" straightUpMatchResult

                    _ =
                        Debug.log "colorResult" colorResult
                in
                Expect.equal (highlightMarkup "orange red purple" colorResult)
                    (span [] [ text "orange ", span [] [ text "red" ], text " purple" ])
        ]
