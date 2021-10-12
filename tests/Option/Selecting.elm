module Option.Selecting exposing (suite)

import Expect
import Option exposing (newOption, selectSingleOptionInList, stringToOptionValue)
import Test exposing (Test, describe, test)


matthew =
    newOption "Matthew" Nothing


mark =
    newOption "Mark" Nothing


luke =
    newOption "Luke" Nothing


john =
    newOption "John" Nothing


gospels =
    [ matthew
    , mark
    , luke
    , john
    ]


suite : Test
suite =
    describe "Selecting options"
        [ test "one and only one option should... just... select one option" <|
            \_ ->
                Expect.equalLists
                    (gospels
                        |> selectSingleOptionInList (stringToOptionValue "Mark")
                        |> selectSingleOptionInList (stringToOptionValue "Luke")
                    )
                    (gospels
                        |> selectSingleOptionInList (stringToOptionValue "Luke")
                    )
        ]
