module Option.Selecting exposing (suite)

import Expect
import Option
    exposing
        ( deselectEveryOptionExceptOptionsInList
        , newOption
        , selectOption
        , selectOptionInListByOptionValue
        , selectOptionsInList
        , selectOptionsInOptionsListByString
        , selectSingleOptionInList
        , stringToOptionValue
        )
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
        [ test "just one option" <|
            \_ ->
                Expect.equalLists
                    (gospels
                        |> selectOptionInListByOptionValue (stringToOptionValue "Mark")
                    )
                    [ matthew
                    , selectOption 0 mark
                    , luke
                    , john
                    ]
        , test "just 2 options" <|
            \_ ->
                Expect.equalLists
                    (gospels
                        |> selectOptionInListByOptionValue (stringToOptionValue "Mark")
                        |> selectOptionInListByOptionValue (stringToOptionValue "Luke")
                    )
                    [ matthew
                    , selectOption 0 mark
                    , selectOption 1 luke
                    , john
                    ]
        , test "one and only one option should... just... select one option" <|
            \_ ->
                Expect.equalLists
                    (gospels
                        |> selectSingleOptionInList (stringToOptionValue "Mark")
                        |> selectSingleOptionInList (stringToOptionValue "Luke")
                    )
                    (gospels
                        |> selectSingleOptionInList (stringToOptionValue "Luke")
                    )
        , test "only no deselecting them" <|
            \_ ->
                Expect.equalLists
                    (deselectEveryOptionExceptOptionsInList [ mark ]
                        [ matthew
                        , selectOption 0 mark
                        , selectOption 1 luke
                        , john
                        ]
                    )
                    [ matthew
                    , selectOption 0 mark
                    , luke
                    , john
                    ]
        , test "select no options in a list " <|
            \_ ->
                Expect.equalLists
                    gospels
                    (selectOptionsInList [] gospels)
        , describe "by strings"
            [ test "select a single option" <|
                \_ ->
                    Expect.equalLists
                        (selectOptionsInOptionsListByString [ "Luke" ] gospels)
                        [ matthew
                        , mark
                        , selectOption 0 luke
                        , john
                        ]
            , test "select 2 options" <|
                \_ ->
                    Expect.equalLists
                        (gospels
                            |> selectOptionsInOptionsListByString [ "Matthew", "Luke" ]
                        )
                        [ selectOption 0 matthew
                        , mark
                        , selectOption 1 luke
                        , john
                        ]
            , test "select 2 different options" <|
                \_ ->
                    Expect.equalLists
                        ([ selectOption 0 matthew
                         , mark
                         , selectOption 1 luke
                         , john
                         ]
                            |> selectOptionsInOptionsListByString [ "Mark", "John" ]
                        )
                        [ matthew
                        , selectOption 2 mark
                        , luke
                        , selectOption 3 john
                        ]
            ]
        ]
