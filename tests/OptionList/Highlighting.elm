module OptionList.Highlighting exposing (..)

import Expect
import Option
import OptionList
import OptionValue
import Test exposing (Test, describe, test)


bernieValue =
    OptionValue.test_newOptionValue "Bernie"


bernie =
    Option.test_newFancyOption "Bernie"


murry =
    Option.test_newFancyOption "Murry"


frank =
    Option.test_newFancyOption "Frank"


people =
    OptionList.test_newFancyOptionList [ bernie, murry, frank ]


suite : Test
suite =
    describe "Change highlighting is option lists "
        [ test "by value" <|
            \_ ->
                Expect.equal
                    (OptionList.highlightOption bernie people
                        |> OptionList.unhighlightOptionByValue bernieValue
                    )
                    (OptionList.test_newFancyOptionList [ bernie, murry, frank ])
        , test "by toggling" <|
            \_ ->
                Expect.equal
                    (OptionList.changeHighlightedOptionByValue bernieValue people)
                    (OptionList.test_newFancyOptionList [ bernie |> Option.highlightOption, murry, frank ])
        , test "by toggling on then off again" <|
            \_ ->
                Expect.equal
                    (people
                        |> OptionList.changeHighlightedOptionByValue bernieValue
                        |> OptionList.changeHighlightedOptionByValue bernieValue
                    )
                    (OptionList.test_newFancyOptionList [ bernie |> Option.highlightOption, murry, frank ])
        , test "by un-highlighting all the selected value" <|
            \_ ->
                Expect.equal
                    (OptionList.test_newFancyOptionList
                        [ bernie |> Option.selectOption 0
                        , murry |> Option.selectOption 1
                        , frank
                        ]
                    )
                    (OptionList.test_newFancyOptionList
                        [ bernie |> Option.highlightOption |> Option.selectOption 0
                        , murry |> Option.selectOption 1 |> Option.highlightOption
                        , frank
                        ]
                        |> OptionList.unhighlightSelectedOptions
                    )
        , test "by toggle the highlight of a selected value" <|
            \_ ->
                Expect.equal
                    (OptionList.test_newFancyOptionList
                        [ bernie |> Option.selectOption 0
                        , murry |> Option.selectOption 1
                        , frank
                        ]
                        |> OptionList.toggleSelectedHighlightByOptionValue bernieValue
                    )
                    (OptionList.test_newFancyOptionList
                        [ bernie |> Option.selectOption 0 |> Option.highlightOption
                        , murry |> Option.selectOption 1
                        , frank
                        ]
                    )
        , test "by toggle the highlight of a selected value (to remove the highlight)" <|
            \_ ->
                Expect.equal
                    (OptionList.test_newFancyOptionList
                        [ bernie |> Option.selectOption 0 |> Option.highlightOption
                        , murry |> Option.selectOption 1
                        , frank
                        ]
                        |> OptionList.toggleSelectedHighlightByOptionValue bernieValue
                    )
                    (OptionList.test_newFancyOptionList
                        [ bernie |> Option.selectOption 0
                        , murry |> Option.selectOption 1
                        , frank
                        ]
                    )
        ]
