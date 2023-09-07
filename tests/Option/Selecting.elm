module Option.Selecting exposing (suite)

import Expect exposing (Expectation)
import Option exposing (Option(..), select, test_newDatalistOption, test_newEmptyDatalistOption, test_newFancyOptionWithMaybeCleanString)
import OptionList exposing (OptionList(..), cleanupEmptySelectedOptions, deselectEveryOptionExceptOptionsInList, selectOptionByOptionValue, selectOptions, selectOptionsInOptionsListByString, selectSingleOptionByValue)
import OptionValue exposing (stringToOptionValue)
import Test exposing (Test, describe, test)


matthew =
    test_newFancyOptionWithMaybeCleanString "Matthew" Nothing


mark =
    test_newFancyOptionWithMaybeCleanString "Mark" Nothing


luke =
    test_newFancyOptionWithMaybeCleanString "Luke" Nothing


john =
    test_newFancyOptionWithMaybeCleanString "John" Nothing


gospels =
    FancyOptionList
        [ matthew
        , mark
        , luke
        , john
        ]


numbers =
    test_newDatalistOption "Numbers"
        |> Option.select 0


optionToTuple : Option -> ( String, Bool )
optionToTuple option =
    Tuple.pair (Option.getOptionValueAsString option) (Option.isSelected option)


assertEqualLists : OptionList -> OptionList -> Expectation
assertEqualLists optionListA optionListB =
    Expect.equalLists
        (optionListA |> OptionList.getOptions |> List.map optionToTuple)
        (optionListB |> OptionList.getOptions |> List.map optionToTuple)


suite : Test
suite =
    describe "Selecting options"
        [ test "just one option" <|
            \_ ->
                assertEqualLists
                    (gospels
                        |> selectOptionByOptionValue (stringToOptionValue "Mark")
                    )
                    (FancyOptionList
                        [ matthew
                        , select 0 mark
                        , luke
                        , john
                        ]
                    )
        , test "just 2 options" <|
            \_ ->
                assertEqualLists
                    (gospels
                        |> selectOptionByOptionValue (stringToOptionValue "Mark")
                        |> selectOptionByOptionValue (stringToOptionValue "Luke")
                    )
                    (FancyOptionList
                        [ matthew
                        , select 0 mark
                        , select 1 luke
                        , john
                        ]
                    )
        , test "one and only one option should... just... select one option" <|
            \_ ->
                assertEqualLists
                    (gospels
                        |> selectSingleOptionByValue (stringToOptionValue "Mark")
                        |> selectSingleOptionByValue (stringToOptionValue "Luke")
                    )
                    (gospels
                        |> selectSingleOptionByValue (stringToOptionValue "Luke")
                    )
        , test "only no deselecting them" <|
            \_ ->
                assertEqualLists
                    (deselectEveryOptionExceptOptionsInList [ mark ]
                        (FancyOptionList
                            [ matthew
                            , select 0 mark
                            , select 1 luke
                            , john
                            ]
                        )
                    )
                    (FancyOptionList
                        [ matthew
                        , select 0 mark
                        , luke
                        , john
                        ]
                    )
        , test "select no options in a list " <|
            \_ ->
                assertEqualLists
                    gospels
                    (selectOptions [] gospels)
        , describe "by strings"
            [ test "select a single option" <|
                \_ ->
                    assertEqualLists
                        (selectOptionsInOptionsListByString [ "Luke" ] gospels)
                        (FancyOptionList
                            [ matthew
                            , mark
                            , select 0 luke
                            , john
                            ]
                        )
            , test "select 2 options" <|
                \_ ->
                    assertEqualLists
                        (gospels
                            |> selectOptionsInOptionsListByString [ "Matthew", "Luke" ]
                        )
                        (FancyOptionList
                            [ select 0 matthew
                            , mark
                            , select 1 luke
                            , john
                            ]
                        )
            , test "select 2 different options" <|
                \_ ->
                    assertEqualLists
                        (FancyOptionList
                            [ select 0 matthew
                            , mark
                            , select 1 luke
                            , john
                            ]
                            |> selectOptionsInOptionsListByString [ "Mark", "John" ]
                        )
                        (FancyOptionList
                            [ matthew
                            , select 2 mark
                            , luke
                            , select 3 john
                            ]
                        )
            ]
        , describe "for datalists"
            [ test "allow one empty option" <|
                \_ ->
                    assertEqualLists
                        (DatalistOptionList
                            [ test_newEmptyDatalistOption |> select 0
                            ]
                            |> cleanupEmptySelectedOptions
                        )
                        (DatalistOptionList
                            [ test_newEmptyDatalistOption |> select 0
                            ]
                        )
            , test "allow only one empty option" <|
                \_ ->
                    assertEqualLists
                        (DatalistOptionList
                            [ test_newEmptyDatalistOption |> select 0
                            , test_newEmptyDatalistOption |> select 1
                            , test_newEmptyDatalistOption |> select 2
                            ]
                            |> cleanupEmptySelectedOptions
                        )
                        (DatalistOptionList
                            [ test_newEmptyDatalistOption |> select 0
                            ]
                        )
            , test "allow no empty options is there is at least one non empty option" <|
                \_ ->
                    assertEqualLists
                        (DatalistOptionList
                            [ numbers
                            , test_newEmptyDatalistOption |> select 1
                            , test_newEmptyDatalistOption |> select 2
                            , test_newEmptyDatalistOption |> select 3
                            ]
                            |> cleanupEmptySelectedOptions
                        )
                        (DatalistOptionList
                            [ numbers
                            ]
                        )
            ]
        ]
