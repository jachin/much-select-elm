module OptionsUtilities.SelectingOptions exposing (suite)

import DatalistOption
import Expect exposing (Expectation)
import Option exposing (Option, selectOption, test_newDatalistOption, test_newFancyOption)
import OptionList exposing (OptionList(..), selectOptionIByValueStringWithIndex, updateDatalistOptionsWithValueAndErrors)
import OptionValue
import Test exposing (Test, describe, test)
import TransformAndValidate exposing (ValidationErrorMessage(..), ValidationFailureMessage(..), ValidationReportLevel(..))


slaveShip =
    test_newFancyOption "Slave Ship" Nothing


desertIsland =
    test_newFancyOption "Desert Island" Nothing


bootHill =
    test_newFancyOption "Boot Hill" Nothing


options =
    FancyOptionList [ slaveShip, desertIsland, bootHill ]


wolfHouse =
    test_newDatalistOption "Wolf House"


dinoBar =
    test_newDatalistOption "Dino Bar"


danceFloor =
    test_newDatalistOption "Dance Floor"


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
    describe "Selecting"
        [ describe "selectOptionInListWithIndex"
            [ test "keep the selection index" <|
                \_ ->
                    assertEqualLists
                        (selectOptionIByValueStringWithIndex 5 "Dance Floor" (FancyOptionList [ danceFloor ]))
                        (FancyOptionList [ danceFloor |> selectOption 5 ])
            , test "if no selection index is specified default to 0" <|
                \_ ->
                    assertEqualLists
                        (OptionList.selectOption danceFloor (FancyOptionList [ danceFloor ]))
                        (FancyOptionList [ danceFloor |> selectOption 0 ])
            ]
        , describe "when there are validation errors"
            [ test "should update a selected value with errors, when there are errors" <|
                \_ ->
                    let
                        failureMessage =
                            ValidationFailureMessage ShowError (ValidationErrorMessage "An error!")
                    in
                    assertEqualLists
                        (updateDatalistOptionsWithValueAndErrors
                            [ failureMessage
                            ]
                            (OptionValue.stringToOptionValue "Pew Pew")
                            0
                            (DatalistOptionList [ wolfHouse, dinoBar, danceFloor ])
                        )
                        (DatalistOptionList
                            [ Option.DatalistOption
                                (DatalistOption.newSelectedDatalistOptionWithErrors
                                    [ failureMessage
                                    ]
                                    (OptionValue.stringToOptionValue "Pew Pew")
                                    0
                                )
                            , wolfHouse
                            , dinoBar
                            , danceFloor
                            ]
                        )
            ]
        ]
