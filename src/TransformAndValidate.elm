module TransformAndValidate exposing (..)

import Json.Decode
import Json.Decode.Extra
import List.Extra
import Result.Extra
import SearchString exposing (SearchString)


type ValueTransformAndValidate
    = ValueTransformAndValidate (List Transformer) (List Validator)


empty =
    ValueTransformAndValidate [] []


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


transformAndValidate : ValueTransformAndValidate -> String -> ValidationResult
transformAndValidate (ValueTransformAndValidate transformers validators) string =
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


transformAndValidateSearchString : ValueTransformAndValidate -> SearchString -> ValidationResult
transformAndValidateSearchString (ValueTransformAndValidate transformers validators) searchString =
    let
        transformedString =
            List.Extra.mapAccuml
                (\str t -> ( transform t str, t ))
                (SearchString.toString searchString)
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


decode : String -> Result Json.Decode.Error ValueTransformAndValidate
decode jsonString =
    if String.length jsonString > 1 then
        Json.Decode.decodeString decoder jsonString

    else
        Ok empty


decoder : Json.Decode.Decoder ValueTransformAndValidate
decoder =
    Json.Decode.map2
        ValueTransformAndValidate
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
    Json.Decode.map2
        NoWhiteSpace
        (Json.Decode.field "level" validationReportLevelDecoder)
        (Json.Decode.field "message" validationErrorMessageDecoder)
        |> Json.Decode.Extra.when (Json.Decode.field "name" Json.Decode.string) (is "no-white-space")


minimumLengthDecoder : Json.Decode.Decoder Validator
minimumLengthDecoder =
    Json.Decode.map3
        MinimumLength
        (Json.Decode.field "level" validationReportLevelDecoder)
        (Json.Decode.field "message" validationErrorMessageDecoder)
        (Json.Decode.field "minimum-length" Json.Decode.int)
        |> Json.Decode.Extra.when (Json.Decode.field "name" Json.Decode.string) (is "minimum-length")


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
