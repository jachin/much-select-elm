module SelectedValueEncoding exposing (..)

import Json.Decode
import Json.Encode
import Option exposing (Option)
import OptionsUtilities exposing (findSelectedOption, selectedOptions)
import Ports exposing (valueDecoder, valuesDecoder)
import SelectionMode exposing (SelectionMode)
import Url exposing (percentDecode, percentEncode)


type SelectedValueEncoding
    = CommaSeperated
    | JsonEncoded


defaultSelectedValueEncoding =
    CommaSeperated


fromMaybeString : Maybe String -> Result String SelectedValueEncoding
fromMaybeString maybeString =
    case maybeString of
        Just string ->
            case string of
                "json" ->
                    Ok JsonEncoded

                "comma" ->
                    Ok CommaSeperated

                _ ->
                    Err ("Invalid selected value encoding: " ++ string)

        Nothing ->
            Ok defaultSelectedValueEncoding


fromString : String -> Result String SelectedValueEncoding
fromString string =
    case string of
        "json" ->
            Ok JsonEncoded

        "comma" ->
            Ok CommaSeperated

        _ ->
            Err ("Invalid selected value encoding: " ++ string)


toString : SelectedValueEncoding -> String
toString selectedValueEncoding =
    case selectedValueEncoding of
        CommaSeperated ->
            "comma"

        JsonEncoded ->
            "json"


valuesFromFlags : SelectedValueEncoding -> String -> Result String (List String)
valuesFromFlags selectedValueEncoding valuesString =
    if valuesString == "" then
        Ok []

    else
        case selectedValueEncoding of
            CommaSeperated ->
                Ok (String.split "," valuesString)

            JsonEncoded ->
                percentDecode valuesString
                    |> Result.fromMaybe "Unable to do a percent decode on the selected value"
                    |> Result.andThen
                        (\decodedValueString ->
                            Json.Decode.decodeString (Json.Decode.oneOf [ valuesDecoder, valueDecoder ]) decodedValueString
                                |> Result.mapError
                                    (\error -> Json.Decode.errorToString error)
                        )


selectedValue : SelectionMode -> List Option -> Json.Encode.Value
selectedValue selectionMode options =
    case selectionMode of
        SelectionMode.SingleSelect ->
            case findSelectedOption options of
                Just selectedOption ->
                    let
                        valueAsString =
                            selectedOption
                                |> Option.getOptionValueAsString
                    in
                    Json.Encode.string valueAsString

                Nothing ->
                    Json.Encode.string ""

        SelectionMode.MultiSelect ->
            let
                selectedValues =
                    selectedOptions options
                        |> List.map Option.getOptionValueAsString
            in
            Json.Encode.list Json.Encode.string
                selectedValues


rawSelectedValue : SelectionMode -> SelectedValueEncoding -> List Option -> Json.Encode.Value
rawSelectedValue selectionMode selectedValueEncoding options =
    case selectionMode of
        SelectionMode.SingleSelect ->
            case findSelectedOption options of
                Just selectedOption ->
                    let
                        valueAsString =
                            selectedOption
                                |> Option.getOptionValueAsString
                    in
                    case selectedValueEncoding of
                        JsonEncoded ->
                            Json.Encode.string
                                (Json.Encode.encode 0 (Json.Encode.string valueAsString)
                                    |> percentEncode
                                )

                        CommaSeperated ->
                            Json.Encode.string valueAsString

                Nothing ->
                    case selectedValueEncoding of
                        JsonEncoded ->
                            Json.Encode.string
                                (Json.Encode.encode 0 (Json.Encode.string "")
                                    |> percentEncode
                                )

                        CommaSeperated ->
                            Json.Encode.string ""

        SelectionMode.MultiSelect ->
            let
                selectedValues =
                    selectedOptions options
                        |> List.map Option.getOptionValueAsString
            in
            case selectedValueEncoding of
                JsonEncoded ->
                    Json.Encode.string
                        (Json.Encode.encode 0 (Json.Encode.list Json.Encode.string selectedValues)
                            |> percentEncode
                        )

                CommaSeperated ->
                    Json.Encode.string (String.join "," selectedValues)