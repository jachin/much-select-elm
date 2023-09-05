module OptionsUtilities.UpdatingDatalistSelectedOptions exposing (suite)

import DatalistOption exposing (newSelectedDatalistOption, newSelectedDatalistOptionWithErrors)
import Expect exposing (Expectation)
import Option exposing (Option(..))
import OptionList exposing (OptionList(..), updateDatalistOptionWithValueBySelectedValueIndex)
import OptionValue
import Test exposing (Test, describe, test)
import TransformAndValidate exposing (ValidationErrorMessage(..), ValidationFailureMessage(..), ValidationReportLevel(..))


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
    describe "Updating selected datalist options"
        [ test "and there are errors we should keep the selected option but it should be in an error state" <|
            \_ ->
                let
                    failureMessage =
                        ValidationFailureMessage ShowError (ValidationErrorMessage "Ho hum")
                in
                assertEqualLists
                    (updateDatalistOptionWithValueBySelectedValueIndex
                        [ failureMessage ]
                        (OptionValue.stringToOptionValue "flying car")
                        0
                        (DatalistOptionList
                            [ DatalistOption
                                (newSelectedDatalistOptionWithErrors
                                    [ ValidationFailureMessage ShowError (ValidationErrorMessage "Heave ho") ]
                                    (OptionValue.stringToOptionValue "flying ca")
                                    0
                                )
                            ]
                        )
                    )
                    (DatalistOptionList
                        [ DatalistOption
                            (newSelectedDatalistOptionWithErrors
                                [ failureMessage ]
                                (OptionValue.stringToOptionValue "flying car")
                                0
                            )
                        ]
                    )
        , test "and were no errors but now there are some so we should move the selected value into an error state" <|
            \_ ->
                -- TODO This test is identical the previous one. We should probably remove one of them.
                let
                    failureMessage =
                        ValidationFailureMessage ShowError (ValidationErrorMessage "Ho hum")
                in
                assertEqualLists
                    (updateDatalistOptionWithValueBySelectedValueIndex
                        [ failureMessage ]
                        (OptionValue.stringToOptionValue "flying car")
                        0
                        (DatalistOptionList
                            [ DatalistOption
                                (newSelectedDatalistOptionWithErrors
                                    [ ValidationFailureMessage ShowError (ValidationErrorMessage "Heave ho") ]
                                    (OptionValue.stringToOptionValue "flying ca")
                                    0
                                )
                            ]
                        )
                    )
                    (DatalistOptionList
                        [ DatalistOption
                            (newSelectedDatalistOptionWithErrors
                                [ failureMessage ]
                                (OptionValue.stringToOptionValue "flying car")
                                0
                            )
                        ]
                    )
        , test "and were errors but those errors have been fixed so we should move the selected value into a selected state" <|
            \_ ->
                let
                    failureMessage =
                        ValidationFailureMessage ShowError (ValidationErrorMessage "Ho hum")
                in
                assertEqualLists
                    (updateDatalistOptionWithValueBySelectedValueIndex
                        []
                        (OptionValue.stringToOptionValue "flying car")
                        0
                        (DatalistOptionList
                            [ DatalistOption
                                (newSelectedDatalistOptionWithErrors
                                    [ failureMessage ]
                                    (OptionValue.stringToOptionValue "flying ca")
                                    0
                                )
                            ]
                        )
                    )
                    (DatalistOptionList
                        [ DatalistOption
                            (newSelectedDatalistOption
                                (OptionValue.stringToOptionValue "flying car")
                                0
                            )
                        ]
                    )
        ]
