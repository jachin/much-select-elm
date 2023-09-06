module OptionList.SelectedOptionValues exposing (..)

import Expect
import Option exposing (selectOption, test_newDatalistOption, test_newEmptySelectedDatalistOption, test_newFancyOption)
import OptionList exposing (selectedOptionValuesAreEqual, test_newDatalistOptionList, test_newFancyOptionList)
import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "When are testing to see if a change in the selected-value attribute should trigger a full on change in the selected value"
        [ test "if the strings of the selected value match" <|
            \_ ->
                Expect.equal
                    True
                    (selectedOptionValuesAreEqual
                        [ "another", "mouth", "to", "feed" ]
                        (test_newFancyOptionList
                            [ test_newFancyOption "another" |> selectOption 0
                            , test_newFancyOption "mouth" |> selectOption 1
                            , test_newFancyOption "to" |> selectOption 2
                            , test_newFancyOption "feed" |> selectOption 3
                            ]
                        )
                    )
        , test "the strings of the selected value do not match if it includes empty values" <|
            \_ ->
                Expect.equal
                    False
                    (selectedOptionValuesAreEqual
                        [ "another", "mouth", "to", "feed" ]
                        (test_newFancyOptionList
                            [ test_newFancyOption "" |> selectOption 0
                            , test_newFancyOption "another" |> selectOption 1
                            , test_newFancyOption "mouth" |> selectOption 2
                            , test_newFancyOption "to" |> selectOption 3
                            , test_newFancyOption "feed" |> selectOption 4
                            ]
                        )
                    )
        , test "the strings of the selected value do match if it includes an empty value if it's a datalist" <|
            \_ ->
                Expect.equal
                    True
                    (selectedOptionValuesAreEqual
                        [ "Warren", "and", "the", "cat" ]
                        (test_newDatalistOptionList
                            [ test_newEmptySelectedDatalistOption 0
                            , test_newDatalistOption "Warren" |> selectOption 1
                            , test_newDatalistOption "and" |> selectOption 2
                            , test_newDatalistOption "the" |> selectOption 3
                            , test_newDatalistOption "cat" |> selectOption 4
                            ]
                        )
                    )
        , test "the strings of the selected value do match if it includes a trailing empty value if it's a datalist" <|
            \_ ->
                Expect.equal
                    True
                    (selectedOptionValuesAreEqual
                        [ "Warren", "and", "the", "cat" ]
                        (test_newDatalistOptionList
                            [ test_newDatalistOption "Warren" |> selectOption 1
                            , test_newDatalistOption "and" |> selectOption 2
                            , test_newDatalistOption "the" |> selectOption 3
                            , test_newDatalistOption "cat" |> selectOption 4
                            , test_newEmptySelectedDatalistOption 5
                            ]
                        )
                    )
        , test "if the strings of the selected value do not match if the options are out of order" <|
            \_ ->
                Expect.equal
                    False
                    (selectedOptionValuesAreEqual
                        [ "another", "mouth", "to", "feed" ]
                        (test_newFancyOptionList
                            [ test_newFancyOption "another" |> selectOption 4
                            , test_newFancyOption "mouth" |> selectOption 1
                            , test_newFancyOption "to" |> selectOption 0
                            , test_newFancyOption "feed" |> selectOption 3
                            ]
                        )
                    )
        , test "if the strings of the selected value do match even if the options are out of order" <|
            \_ ->
                Expect.equal
                    True
                    (selectedOptionValuesAreEqual
                        [ "to", "mouth", "feed", "another" ]
                        (test_newFancyOptionList
                            [ test_newFancyOption "another" |> selectOption 4
                            , test_newFancyOption "mouth" |> selectOption 1
                            , test_newFancyOption "to" |> selectOption 0
                            , test_newFancyOption "feed" |> selectOption 3
                            ]
                        )
                    )
        ]
