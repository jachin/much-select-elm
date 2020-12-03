port module Ports exposing
    ( blurInput
    , disableChangedReceiver
    , loadingChangedReceiver
    , optionsChangedReceiver
    , placeholderChangedReceiver
    , valueChanged
    , valueChangedReceiver
    , valuesDecoder
    )

import Json.Decode


port valueChanged : List ( String, String ) -> Cmd msg


port blurInput : () -> Cmd msg


valuesDecoder : Json.Decode.Decoder (List String)
valuesDecoder =
    Json.Decode.list Json.Decode.string


port valueChangedReceiver : (Json.Decode.Value -> msg) -> Sub msg


port optionsChangedReceiver : (Json.Decode.Value -> msg) -> Sub msg


port placeholderChangedReceiver : (String -> msg) -> Sub msg


port loadingChangedReceiver : (Bool -> msg) -> Sub msg


port disableChangedReceiver : (Bool -> msg) -> Sub msg

port maxDropdownItemsChangedReceiver : (String -> msg) -> Sub msg