module TransformAndValidate.Validations exposing (suite)

import Expect
import Test exposing (Test, describe, test)
import TransformAndValidate exposing (ValidationErrorMessage(..), ValidationReportLevel(..), ValidationResult(..), Validator(..), ValueValidate(..), transformAndValidate)


suite : Test
suite =
    describe "Validate"
        [ describe "that a string has no white space in it"
            [ test "the string has no white space so it should pass" <|
                \_ ->
                    Expect.equal
                        (transformAndValidate
                            (ValueValidate []
                                [ NoWhiteSpace ShowError (ValidationErrorMessage "No white space allowed")
                                ]
                            )
                            "Wolf"
                        )
                        (ValidationPass "Wolf")
            , test "the string has white space so it should not pass" <|
                \_ ->
                    Expect.equal
                        (transformAndValidate
                            (ValueValidate []
                                [ NoWhiteSpace ShowError (ValidationErrorMessage "No white space allowed")
                                ]
                            )
                            "I'm starting to worry about you Ed."
                        )
                        (ValidationFailed [ ValidationErrorMessage "No white space allowed" ])
            ]
        ]
