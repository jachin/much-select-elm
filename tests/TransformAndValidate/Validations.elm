module TransformAndValidate.Validations exposing (suite)

import Expect
import Test exposing (Test, describe, test)
import TransformAndValidate exposing (ValidationErrorMessage(..), ValidationReportLevel(..), ValidationResult(..), Validator(..), ValueTransformAndValidate(..), transformAndValidate)


suite : Test
suite =
    describe "Validate"
        [ describe "that a string has no white space in it"
            [ test "the string has no white space so it should pass" <|
                \_ ->
                    Expect.equal
                        (transformAndValidate
                            (ValueTransformAndValidate []
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
                            (ValueTransformAndValidate []
                                [ NoWhiteSpace ShowError (ValidationErrorMessage "No white space allowed")
                                ]
                            )
                            "I'm starting to worry about you Ed."
                        )
                        (ValidationFailed [ ValidationErrorMessage "No white space allowed" ])
            ]
        , describe "the string is longer than a minium length"
            [ test "and it's long enough" <|
                \_ ->
                    Expect.equal
                        (transformAndValidate
                            (ValueTransformAndValidate []
                                [ MinimumLength ShowError (ValidationErrorMessage "The value is too short") 3
                                ]
                            )
                            "Sheep"
                        )
                        (ValidationPass "Sheep")
            , test "and it's not long enough" <|
                \_ ->
                    Expect.equal
                        (transformAndValidate
                            (ValueTransformAndValidate []
                                [ MinimumLength ShowError (ValidationErrorMessage "The value is too short") 20
                                ]
                            )
                            "Sheep"
                        )
                        (ValidationFailed [ ValidationErrorMessage "The value is too short" ])
            ]
        ]
