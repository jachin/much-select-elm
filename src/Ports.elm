port module Ports exposing
    ( blurInput
    , disableChangedReceiver
    , focusInput
    , loadingChangedReceiver
    , maxDropdownItemsChangedReceiver
    , optionsChangedReceiver
    , placeholderChangedReceiver
    , valueChanged
    , valueChangedReceiver
    , valuesDecoder
    )

import Json.Decode


port valueChanged : List ( String, String ) -> Cmd msg


port blurInput : () -> Cmd msg


port focusInput : () -> Cmd msg


valuesDecoder : Json.Decode.Decoder (List String)
valuesDecoder =
    Json.Decode.list Json.Decode.string


port valueChangedReceiver : (Json.Decode.Value -> msg) -> Sub msg


port optionsChangedReceiver : (Json.Decode.Value -> msg) -> Sub msg


port placeholderChangedReceiver : (String -> msg) -> Sub msg


port loadingChangedReceiver : (Bool -> msg) -> Sub msg


port disableChangedReceiver : (Bool -> msg) -> Sub msg


port maxDropdownItemsChangedReceiver : (Int -> msg) -> Sub msg
