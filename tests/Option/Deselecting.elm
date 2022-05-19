module Option.Deselecting exposing (suite)

import Expect
import Option exposing (newOption, selectOption)
import OptionValue exposing (stringToOptionValue)
import OptionsUtilities
    exposing
        ( deselectAllButTheFirstSelectedOptionInList
        , deselectAllOptionsInOptionsList
        , deselectOptions
        , selectOptionInListByOptionValue
        )
import Test exposing (Test, describe, test)


buzzCola =
    newOption "Buzz Cola" Nothing


krustyBurger =
    newOption "Krusty Burger" Nothing


lardLad =
    newOption "Lard Lad" Nothing


squishee =
    newOption "Squishee" Nothing


duff =
    Option.newDatalistOption (OptionValue.stringToOptionValue "Duff")


rockBottom =
    Option.newDatalistOption (OptionValue.stringToOptionValue "Rock Bottom")


malibuStacy =
    Option.newDatalistOption (OptionValue.stringToOptionValue "Malibu Stacy")


brandOptions =
    [ buzzCola, krustyBurger, lardLad, squishee ]


datalistOption =
    [ duff, rockBottom, malibuStacy ]


suite : Test
suite =
    describe "Deselecting"
        [ test "all the selected option" <|
            \_ ->
                Expect.equalLists
                    (brandOptions
                        |> selectOptionInListByOptionValue (stringToOptionValue "Krusty Burger")
                        |> selectOptionInListByOptionValue (stringToOptionValue "Lard Lad")
                        |> deselectAllOptionsInOptionsList
                    )
                    [ buzzCola
                    , krustyBurger
                    , lardLad
                    , squishee
                    ]
        , test "all the selected options in a list" <|
            \_ ->
                Expect.equalLists
                    (brandOptions
                        |> selectOptionInListByOptionValue (stringToOptionValue "Buzz Cola")
                        |> selectOptionInListByOptionValue (stringToOptionValue "Krusty Burger")
                        |> selectOptionInListByOptionValue (stringToOptionValue "Lard Lad")
                        |> deselectOptions [ buzzCola, krustyBurger ]
                    )
                    [ buzzCola
                    , krustyBurger
                    , selectOption 2 lardLad
                    , squishee
                    ]
        , test "all but the first selected option" <|
            \_ ->
                Expect.equalLists
                    (brandOptions
                        |> selectOptionInListByOptionValue (stringToOptionValue "Lard Lad")
                        |> selectOptionInListByOptionValue (stringToOptionValue "Buzz Cola")
                        |> selectOptionInListByOptionValue (stringToOptionValue "Krusty Burger")
                        |> deselectAllButTheFirstSelectedOptionInList
                    )
                    [ buzzCola
                    , krustyBurger
                    , selectOption 0 lardLad
                    , squishee
                    ]
        , describe "in a datalist"
            [ test "the first option" <|
                \_ ->
                    let
                        optionsWithThreeSelections =
                            [ Option.newSelectedDatalistOption (OptionValue.stringToOptionValue "Left-Mart") 0
                            , Option.newSelectedDatalistOption (OptionValue.stringToOptionValue "Powersause") 1
                            , Option.newSelectedDatalistOption (OptionValue.stringToOptionValue "Skybucks") 2
                            ]
                                ++ datalistOption
                    in
                    Expect.equalLists
                        (optionsWithThreeSelections
                            |> OptionsUtilities.removeOptionFromOptionListBySelectedIndex 0
                        )
                        ([ Option.newSelectedDatalistOption (OptionValue.stringToOptionValue "Powersause") 0
                         , Option.newSelectedDatalistOption (OptionValue.stringToOptionValue "Skybucks") 1
                         ]
                            ++ datalistOption
                        )
            , test "the middle option" <|
                \_ ->
                    let
                        optionsWithThreeSelections =
                            [ Option.newSelectedDatalistOption (OptionValue.stringToOptionValue "Left-Mart") 0
                            , Option.newSelectedDatalistOption (OptionValue.stringToOptionValue "Powersause") 1
                            , Option.newSelectedDatalistOption (OptionValue.stringToOptionValue "Skybucks") 2
                            ]
                                ++ datalistOption
                    in
                    Expect.equalLists
                        (optionsWithThreeSelections
                            |> OptionsUtilities.removeOptionFromOptionListBySelectedIndex 1
                        )
                        ([ Option.newSelectedDatalistOption (OptionValue.stringToOptionValue "Left-Mart") 0
                         , Option.newSelectedDatalistOption (OptionValue.stringToOptionValue "Skybucks") 1
                         ]
                            ++ datalistOption
                        )
            , test "the last option" <|
                \_ ->
                    let
                        optionsWithThreeSelections =
                            [ Option.newSelectedDatalistOption (OptionValue.stringToOptionValue "Left-Mart") 0
                            , Option.newSelectedDatalistOption (OptionValue.stringToOptionValue "Powersause") 1
                            , Option.newSelectedDatalistOption (OptionValue.stringToOptionValue "Skybucks") 2
                            ]
                                ++ datalistOption
                    in
                    Expect.equalLists
                        (optionsWithThreeSelections
                            |> OptionsUtilities.removeOptionFromOptionListBySelectedIndex 2
                        )
                        ([ Option.newSelectedDatalistOption (OptionValue.stringToOptionValue "Left-Mart") 0
                         , Option.newSelectedDatalistOption (OptionValue.stringToOptionValue "Powersause") 1
                         ]
                            ++ datalistOption
                        )
            ]
        ]
