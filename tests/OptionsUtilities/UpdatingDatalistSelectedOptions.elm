module OptionsUtilities.UpdatingDatalistSelectedOptions exposing (suite)

import Expect
import Option
import OptionValue
import OptionsUtilities exposing (updateDatalistOptionWithValueBySelectedValueIndex)
import Test exposing (Test, describe, test)
import TransformAndValidate exposing (ValidationErrorMessage(..))


suite : Test
suite =
    describe "Updating selected datalist options"
        [ test "and there are errors we should keep the selected option but it should be in an error state" <|
            \_ ->
                Expect.equalLists
                    (updateDatalistOptionWithValueBySelectedValueIndex
                        [ ValidationErrorMessage "Ho hum" ]
                        (OptionValue.stringToOptionValue "flying car")
                        0
                        [ Option.newSelectedDatalistOptionWithErrors
                            [ ValidationErrorMessage "Heave ho" ]
                            (OptionValue.stringToOptionValue "flying ca")
                            0
                        ]
                    )
                    [ Option.newSelectedDatalistOptionWithErrors
                        [ ValidationErrorMessage "Ho hum" ]
                        (OptionValue.stringToOptionValue "flying car")
                        0
                    ]
        , test "and were no errors but now there are some so we should move the selected value into an error state" <|
            \_ ->
                Expect.equalLists
                    (updateDatalistOptionWithValueBySelectedValueIndex
                        [ ValidationErrorMessage "Ho hum" ]
                        (OptionValue.stringToOptionValue "flying car")
                        0
                        [ Option.newSelectedDatalistOption
                            (OptionValue.stringToOptionValue "flying ca")
                            0
                        ]
                    )
                    [ Option.newSelectedDatalistOptionWithErrors
                        [ ValidationErrorMessage "Ho hum" ]
                        (OptionValue.stringToOptionValue "flying car")
                        0
                    ]
        , test "and were errors but those errors have been fixed so we should move the selected value into a selected state" <|
            \_ ->
                Expect.equalLists
                    (updateDatalistOptionWithValueBySelectedValueIndex
                        []
                        (OptionValue.stringToOptionValue "flying car")
                        0
                        [ Option.newSelectedDatalistOptionWithErrors
                            [ ValidationErrorMessage "Ho hum" ]
                            (OptionValue.stringToOptionValue "flying ca")
                            0
                        ]
                    )
                    [ Option.newSelectedDatalistOption
                        (OptionValue.stringToOptionValue "flying car")
                        0
                    ]
        ]
