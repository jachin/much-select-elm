module Option.Selecting exposing (suite)

import Expect exposing (Expectation)
import Option exposing (Option(..), selectOption, test_newDatalistOption, test_newEmptyDatalistOption, test_newFancyOption)
import OptionList exposing (OptionList(..), cleanupEmptySelectedOptions, deselectEveryOptionExceptOptionsInList, selectOptionByOptionValue, selectOptions, selectOptionsInOptionsListByString, selectSingleOptionByValue)
import OptionValue exposing (stringToOptionValue)
import Test exposing (Test, describe, test)


matthew =
    test_newFancyOption "Matthew" Nothing


mark =
    test_newFancyOption "Mark" Nothing


luke =
    test_newFancyOption "Luke" Nothing


john =
    test_newFancyOption "John" Nothing


gospels =
    FancyOptionList
        [ matthew
        , mark
        , luke
        , john
        ]


numbers =
    test_newDatalistOption "Numbers"
        |> Option.selectOption 0


optionToTuple : Option -> ( String, Bool )
optionToTuple option =
    Tuple.pair (Option.getOptionValueAsString option) (Option.isOptionSelected option)


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
                        , selectOption 0 mark
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
                        , selectOption 0 mark
                        , selectOption 1 luke
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
                            , selectOption 0 mark
                            , selectOption 1 luke
                            , john
                            ]
                        )
                    )
                    (FancyOptionList
                        [ matthew
                        , selectOption 0 mark
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
                            , selectOption 0 luke
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
                            [ selectOption 0 matthew
                            , mark
                            , selectOption 1 luke
                            , john
                            ]
                        )
            , test "select 2 different options" <|
                \_ ->
                    assertEqualLists
                        (FancyOptionList
                            [ selectOption 0 matthew
                            , mark
                            , selectOption 1 luke
                            , john
                            ]
                            |> selectOptionsInOptionsListByString [ "Mark", "John" ]
                        )
                        (FancyOptionList
                            [ matthew
                            , selectOption 2 mark
                            , luke
                            , selectOption 3 john
                            ]
                        )
            ]
        , describe "for datalists"
            [ test "allow one empty option" <|
                \_ ->
                    assertEqualLists
                        (DatalistOptionList
                            [ test_newEmptyDatalistOption |> selectOption 0
                            ]
                            |> cleanupEmptySelectedOptions
                        )
                        (DatalistOptionList
                            [ test_newEmptyDatalistOption |> selectOption 0
                            ]
                        )
            , test "allow only one empty option" <|
                \_ ->
                    assertEqualLists
                        (DatalistOptionList
                            [ test_newEmptyDatalistOption |> selectOption 0
                            , test_newEmptyDatalistOption |> selectOption 1
                            , test_newEmptyDatalistOption |> selectOption 2
                            ]
                            |> cleanupEmptySelectedOptions
                        )
                        (DatalistOptionList
                            [ test_newEmptyDatalistOption |> selectOption 0
                            ]
                        )
            , test "allow no empty options is there is at least one non empty option" <|
                \_ ->
                    assertEqualLists
                        (DatalistOptionList
                            [ numbers
                            , test_newEmptyDatalistOption |> selectOption 1
                            , test_newEmptyDatalistOption |> selectOption 2
                            , test_newEmptyDatalistOption |> selectOption 3
                            ]
                            |> cleanupEmptySelectedOptions
                        )
                        (DatalistOptionList
                            [ numbers
                            ]
                        )
            ]
        ]
