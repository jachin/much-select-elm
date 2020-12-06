port module Ports exposing
    ( addOptionsReceiver
    , blurInput
    , disableChangedReceiver
    , errorMessage
    , focusInput
    , loadingChangedReceiver
    , maxDropdownItemsChangedReceiver
    , optionsChangedReceiver
    , placeholderChangedReceiver
    , selectBoxWidthChangedReceiver
    , valueChanged
    , valueChangedReceiver
    , valuesDecoder
    )

import Json.Decode


port errorMessage : String -> Cmd msg


port valueChanged : List ( String, String ) -> Cmd msg


port blurInput : () -> Cmd msg


port focusInput : () -> Cmd msg


valuesDecoder : Json.Decode.Decoder (List String)
valuesDecoder =
    Json.Decode.list Json.Decode.string


port valueChangedReceiver : (Json.Decode.Value -> msg) -> Sub msg


port optionsChangedReceiver : (Json.Decode.Value -> msg) -> Sub msg


port addOptionsReceiver : (Json.Decode.Value -> msg) -> Sub msg


port placeholderChangedReceiver : (String -> msg) -> Sub msg


port loadingChangedReceiver : (Bool -> msg) -> Sub msg


port disableChangedReceiver : (Bool -> msg) -> Sub msg


port maxDropdownItemsChangedReceiver : (Int -> msg) -> Sub msg


port selectBoxWidthChangedReceiver : (Float -> msg) -> Sub msg
