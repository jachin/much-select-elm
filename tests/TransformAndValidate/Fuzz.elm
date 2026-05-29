module TransformAndValidate.Fuzz exposing (suite)

import Expect
import Fuzz
import SearchString
import Test exposing (Test, describe, fuzz, fuzz2)
import TransformAndValidate
    exposing
        ( Transformer(..)
        , ValidationErrorMessage(..)
        , ValidationFailureMessage(..)
        , ValidationReportLevel(..)
        , ValidationResult(..)
        , Validator(..)
        , ValueTransformAndValidate(..)
        , transformAndValidateFirstPass
        , transformAndValidateSearchString
        )


suite : Test
suite =
    describe "TransformAndValidate fuzz tests"
        [ fuzz2 Fuzz.string (Fuzz.intRange -20 20) "ToLowercase lowercases and preserves selected index when a validator is present" <|
            \input selectedIndex ->
                Expect.equal
                    (transformAndValidateFirstPass
                        (ValueTransformAndValidate
                            [ ToLowercase ]
                            [ MinimumLength ShowError (ValidationErrorMessage "unused") 0 ]
                        )
                        input
                        selectedIndex
                    )
                    (ValidationPass (String.toLower input) selectedIndex)
        , fuzz2
            (Fuzz.map (\s -> String.replace " " "" s) Fuzz.string)
            (Fuzz.intRange -20 20)
            "NoWhiteSpace validator passes for values without spaces"
          <|
            \input selectedIndex ->
                Expect.equal
                    (transformAndValidateFirstPass
                        (ValueTransformAndValidate []
                            [ NoWhiteSpace ShowError (ValidationErrorMessage "No white space allowed")
                            ]
                        )
                        input
                        selectedIndex
                    )
                    (ValidationPass input selectedIndex)
        , fuzz2 Fuzz.string Fuzz.string "NoWhiteSpace validator fails when value contains a space" <|
            \left right ->
                let
                    input =
                        left ++ " " ++ right
                in
                Expect.equal
                    (transformAndValidateFirstPass
                        (ValueTransformAndValidate []
                            [ NoWhiteSpace ShowError (ValidationErrorMessage "No white space allowed")
                            ]
                        )
                        input
                        0
                    )
                    (ValidationFailed
                        input
                        0
                        [ ValidationFailureMessage ShowError
                            (ValidationErrorMessage "No white space allowed")
                        ]
                    )
        , fuzz2 Fuzz.string (Fuzz.intRange 0 40) "MinimumLength matches String.length behavior" <|
            \input minimumLength ->
                let
                    result =
                        transformAndValidateFirstPass
                            (ValueTransformAndValidate []
                                [ MinimumLength ShowError (ValidationErrorMessage "The value is too short") minimumLength
                                ]
                            )
                            input
                            0
                in
                if String.length input >= minimumLength then
                    Expect.equal result (ValidationPass input 0)

                else
                    Expect.equal
                        result
                        (ValidationFailed
                            input
                            0
                            [ ValidationFailureMessage ShowError
                                (ValidationErrorMessage "The value is too short")
                            ]
                        )
        , fuzz Fuzz.string "Search-string transformation uses lowercase transformer" <|
            \input ->
                Expect.equal
                    (transformAndValidateSearchString
                        (ValueTransformAndValidate [ ToLowercase ] [])
                        (SearchString.new input False)
                    )
                    (ValidationPass (String.toLower input) 0)
        ]
