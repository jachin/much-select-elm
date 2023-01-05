module SelectedValueEncoding exposing (..)

import Json.Decode
import Ports exposing (valueDecoder, valuesDecoder)
import Url exposing (percentDecode)


type SelectedValueEncoding
    = CommaSeperated
    | JsonEncoded


defaultSelectedValueEncoding =
    CommaSeperated


fromString : String -> Result String SelectedValueEncoding
fromString string =
    case string of
        "json" ->
            Ok JsonEncoded

        "comma" ->
            Ok CommaSeperated

        _ ->
            Err ("Invalid selected value encoding: " ++ string)


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
