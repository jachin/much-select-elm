module OptionsUtilities.SelectingOptions exposing (suite)

import Expect
import Option
    exposing
        ( newCustomOption
        , newDatalistOption
        , newOption
        , newSelectedDatalistOptionWithErrors
        , selectOption
        )
import OptionValue
import OptionsUtilities
    exposing
        ( selectSingleOptionInListByStringOrSelectCustomValue
        , updateDatalistOptionsWithValueAndErrors
        )
import SearchString
import Test exposing (Test, describe, test)
import TransformAndValidate exposing (ValidationErrorMessage(..), ValidationFailureMessage(..), ValidationReportLevel(..))


slaveShip =
    newOption "Slave Ship" Nothing


desertIsland =
    newOption "Desert Island" Nothing


bootHill =
    newOption "Boot Hill" Nothing


options =
    [ slaveShip, desertIsland, bootHill ]


wolfHouse =
    newDatalistOption (OptionValue.stringToOptionValue "Wolf House")


dinoBar =
    newDatalistOption (OptionValue.stringToOptionValue "Dino Bar")


danceFloor =
    newDatalistOption (OptionValue.stringToOptionValue "Dance Floor")


suite : Test
suite =
    describe "Selecting"
        [ describe "a single option or adding a custom value"
            [ test "should do nothing on an empty list of options and an empty string" <|
                \_ ->
                    Expect.equalLists
                        (selectSingleOptionInListByStringOrSelectCustomValue (SearchString.new "") [])
                        []
            , test "should select nothing on an empty string" <|
                \_ ->
                    Expect.equalLists
                        (selectSingleOptionInListByStringOrSelectCustomValue (SearchString.new "") [ desertIsland ])
                        [ desertIsland ]
            , test "should create a new custom option when the list of option is empty" <|
                \_ ->
                    Expect.equalLists
                        (selectSingleOptionInListByStringOrSelectCustomValue (SearchString.new "Moon Lit Street") [])
                        [ newCustomOption "Moon Lit Street" Nothing |> selectOption 0 ]
            , test "should selected an existing option if the string matches" <|
                \_ ->
                    Expect.equalLists
                        (selectSingleOptionInListByStringOrSelectCustomValue (SearchString.new "Boot Hill") options)
                        [ slaveShip, desertIsland, bootHill |> selectOption 0 ]
            , test "should not selected an existing option if the string has miss matching case" <|
                \_ ->
                    Expect.equalLists
                        (selectSingleOptionInListByStringOrSelectCustomValue (SearchString.new "boot hill") options)
                        ((newCustomOption "boot hill" Nothing |> selectOption 0) :: options)
            ]
        , describe "selectOptionInListWithIndex"
            [ test "keep the selection index" <|
                \_ ->
                    Expect.equalLists
                        (OptionsUtilities.selectOptionInListWithIndex (danceFloor |> selectOption 5) [ danceFloor ])
                        [ danceFloor |> selectOption 5 ]
            , test "if no selection index is specifided default to 0" <|
                \_ ->
                    Expect.equalLists
                        (OptionsUtilities.selectOptionInListWithIndex danceFloor [ danceFloor ])
                        [ danceFloor |> selectOption 0 ]
            ]
        , describe "when there are validation errors"
            [ test "should update a selected value with errors, when there are errors" <|
                \_ ->
                    let
                        failureMessage =
                            ValidationFailureMessage ShowError (ValidationErrorMessage "An error!")
                    in
                    Expect.equalLists
                        (updateDatalistOptionsWithValueAndErrors
                            [ failureMessage
                            ]
                            (OptionValue.stringToOptionValue "Pew Pew")
                            0
                            [ wolfHouse, dinoBar, danceFloor ]
                        )
                        [ newSelectedDatalistOptionWithErrors
                            [ failureMessage
                            ]
                            (OptionValue.stringToOptionValue "Pew Pew")
                            0
                        , wolfHouse
                        , dinoBar
                        , danceFloor
                        ]
            ]
        ]
