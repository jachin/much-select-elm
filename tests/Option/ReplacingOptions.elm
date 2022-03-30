module Option.ReplacingOptions exposing (suite)

import Expect
import Option
import Test exposing (Test, describe, test)


futureCop =
    Option.newOption "Future Cop!" Nothing


theMidnight =
    Option.newOption "The Midnight" Nothing


thirdEyeBlind =
    Option.newOption "Third Eye Blind" Nothing


suite : Test
suite =
    describe "Replacing options"
        [ test "should not include options that were there before" <|
            \_ ->
                Expect.equalLists
                    [ futureCop, theMidnight ]
                    (Option.replaceOptions [ thirdEyeBlind, futureCop ] [ futureCop, theMidnight ])
        , test "should preserver selected options" <|
            \_ ->
                Expect.equalLists
                    [ futureCop, Option.selectOption 0 theMidnight ]
                    (Option.replaceOptions [ thirdEyeBlind, futureCop ] [ futureCop, Option.selectOption 0 theMidnight ])
        , test "should preserver selected options even if the selected value is not in the new list of options" <|
            \_ ->
                Expect.equalLists
                    (Option.replaceOptions
                        [ Option.selectOption 0 thirdEyeBlind, futureCop ]
                        [ futureCop, theMidnight ]
                    )
                    [ Option.selectOption 0 thirdEyeBlind, futureCop, theMidnight ]
        ]
