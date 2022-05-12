module TransformAndValidate.Transfroms exposing (suite)

import Expect
import Test exposing (Test, describe, test)
import TransformAndValidate exposing (Transformer(..), ValidationResult(..), ValueValidate(..), transformAndValidate)


suite : Test
suite =
    describe "Transforming"
        [ test "a string to all lower case" <|
            \_ ->
                Expect.equal
                    (transformAndValidate (ValueValidate [ ToLowercase ] []) "HELLO")
                    (ValidationPass "hello")
        , test "a string to all lower case if it's already lower case should leave it the same" <|
            \_ ->
                Expect.equal
                    (transformAndValidate (ValueValidate [ ToLowercase ] []) "bugs")
                    (ValidationPass "bugs")
        ]
