module TransformAndValidate exposing (..)

import Json.Decode
import Json.Decode.Extra
import List.Extra
import Result.Extra


type ValueValidate
    = ValueValidate (List Transformer) (List Validator)


empty =
    ValueValidate [] []


type Transformer
    = ToLowercase


type Validator
    = NoWhiteSpace ValidationReportLevel ValidationErrorMessage
    | MinimumLength ValidationReportLevel ValidationErrorMessage Int


type ValidationReportLevel
    = SilentError
    | ShowError


type ValidationErrorMessage
    = ValidationErrorMessage String


type ValidationResult
    = ValidationPass String
    | ValidationFailed (List ValidationErrorMessage)


transform : Transformer -> String -> String
transform transformer string =
    case transformer of
        ToLowercase ->
            String.toLower string


validate : Validator -> String -> Result ValidationErrorMessage String
validate validator string =
    case validator of
        NoWhiteSpace _ validationErrorMessage ->
            let
                stringWithNoWhiteSpace =
                    String.replace " " "" string
            in
            if String.length stringWithNoWhiteSpace == String.length string then
                Ok string

            else
                Err validationErrorMessage

        MinimumLength _ validationErrorMessage int ->
            if String.length string >= int then
                Ok string

            else
                Err validationErrorMessage


transformAndValidate : ValueValidate -> String -> ValidationResult
transformAndValidate (ValueValidate transformers validators) string =
    let
        transformedString =
            List.Extra.mapAccuml
                (\str t -> ( transform t str, t ))
                string
                transformers
                |> Tuple.first
    in
    List.map (\validator -> validate validator transformedString) validators
        |> rollUpErrors transformedString


rollUpErrors : String -> List (Result ValidationErrorMessage String) -> ValidationResult
rollUpErrors transformedString results =
    if List.any Result.Extra.isErr results then
        List.foldl
            (\r l ->
                case r of
                    Ok _ ->
                        l

                    Err errorMessage ->
                        errorMessage :: l
            )
            []
            results
            |> ValidationFailed

    else
        ValidationPass transformedString


is : a -> a -> Bool
is a b =
    a == b


decode : String -> Result Json.Decode.Error ValueValidate
decode jsonString =
    if String.length jsonString > 1 then
        Json.Decode.decodeString decoder jsonString

    else
        Ok empty


decoder : Json.Decode.Decoder ValueValidate
decoder =
    Json.Decode.map2
        ValueValidate
        (Json.Decode.field "transformers" (Json.Decode.list transformerDecoder))
        (Json.Decode.field "validators" (Json.Decode.list validatorDecoder))


transformerDecoder : Json.Decode.Decoder Transformer
transformerDecoder =
    Json.Decode.oneOf
        [ toLowercaseDecoder
        ]


toLowercaseDecoder : Json.Decode.Decoder Transformer
toLowercaseDecoder =
    Json.Decode.succeed ToLowercase
        |> Json.Decode.Extra.when (Json.Decode.field "name" Json.Decode.string) (is "lowercase")


validatorDecoder : Json.Decode.Decoder Validator
validatorDecoder =
    Json.Decode.oneOf
        [ noWhiteSpaceDecoder
        , minimumLengthDecoder
        ]


noWhiteSpaceDecoder : Json.Decode.Decoder Validator
noWhiteSpaceDecoder =
    Json.Decode.map3
        MinimumLength
        (Json.Decode.field "level" validationReportLevelDecoder)
        (Json.Decode.field "message" validationErrorMessageDecoder)
        (Json.Decode.field "minimum-length" Json.Decode.int)
        |> Json.Decode.Extra.when (Json.Decode.field "name" Json.Decode.string) (is "minimum-length")


minimumLengthDecoder : Json.Decode.Decoder Validator
minimumLengthDecoder =
    Json.Decode.map2
        NoWhiteSpace
        (Json.Decode.field "level" validationReportLevelDecoder)
        (Json.Decode.field "message" validationErrorMessageDecoder)
        |> Json.Decode.Extra.when (Json.Decode.field "name" Json.Decode.string) (is "no-white-space")


validationReportLevelDecoder : Json.Decode.Decoder ValidationReportLevel
validationReportLevelDecoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\str ->
                case str of
                    "error" ->
                        Json.Decode.succeed ShowError

                    "silent" ->
                        Json.Decode.succeed SilentError

                    _ ->
                        Json.Decode.fail ("Unknown validation reporting level: " ++ str)
            )


validationErrorMessageDecoder : Json.Decode.Decoder ValidationErrorMessage
validationErrorMessageDecoder =
    Json.Decode.map
        ValidationErrorMessage
        Json.Decode.string
