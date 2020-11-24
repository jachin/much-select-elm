port module Ports exposing
    ( placeholderChangedReceiver
    , valueChanged
    , valueChangedReceiver
    , valuesDecoder
    )

import Json.Decode


port valueChanged : List ( String, String ) -> Cmd msg


valuesDecoder : Json.Decode.Decoder (List String)
valuesDecoder =
    Json.Decode.list Json.Decode.string


port valueChangedReceiver : (Json.Decode.Value -> msg) -> Sub msg


port placeholderChangedReceiver : (String -> msg) -> Sub msg
