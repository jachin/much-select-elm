module Attributes.OptionList.FindingOptions exposing (suite)

import Expect
import Option exposing (test_newFancyOption)
import OptionList exposing (OptionList(..), findClosestHighlightableOptionGoingUp)
import SelectionMode exposing (SelectionMode(..))
import Test exposing (Test, describe, test)


fancyList =
    FancyOptionList
        [ test_newFancyOption "Rusty" Nothing
        ]


suite : Test
suite =
    describe "Looking for something to highlight"
        [ test "going up"
            (\_ ->
                findClosestHighlightableOptionGoingUp SingleSelect 0 fancyList
                    |> Expect.equal (Just (test_newFancyOption "Rusty" Nothing))
            )
        ]
