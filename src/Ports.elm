port module Ports exposing
    ( addItem
    , addOptionsReceiver
    , allowCustomOptionsReceiver
    , blurInput
    , customOptionSelected
    , deselectOptionReceiver
    , disableChangedReceiver
    , errorMessage
    , focusInput
    , inputKeyUp
    , loadingChangedReceiver
    , maxDropdownItemsChangedReceiver
    , optionsChangedReceiver
    , placeholderChangedReceiver
    , removeOptionsReceiver
    , selectOptionReceiver
    , valueCasingDimensionsChangedReceiver
    , valueChanged
    , valueChangedReceiver
    , valueCleared
    , valuesDecoder
    , deselectItem)

import Json.Decode


port errorMessage : String -> Cmd msg


port valueChanged : List ( String, String ) -> Cmd msg


port customOptionSelected : List String -> Cmd msg


port valueCleared : () -> Cmd msg



-- What's up with this odd name "addItem", its how selectize referred to selected options.


port addItem : ( String, String ) -> Cmd msg


port inputKeyUp : String -> Cmd msg


port blurInput : () -> Cmd msg


port focusInput : () -> Cmd msg

port deselectItem: String -> Cmd msg

valuesDecoder : Json.Decode.Decoder (List String)
valuesDecoder =
    Json.Decode.list Json.Decode.string


port valueChangedReceiver : (Json.Decode.Value -> msg) -> Sub msg


port optionsChangedReceiver : (Json.Decode.Value -> msg) -> Sub msg


port addOptionsReceiver : (Json.Decode.Value -> msg) -> Sub msg


port removeOptionsReceiver : (Json.Decode.Value -> msg) -> Sub msg


port selectOptionReceiver : (Json.Decode.Value -> msg) -> Sub msg


port deselectOptionReceiver : (Json.Decode.Value -> msg) -> Sub msg


port placeholderChangedReceiver : (String -> msg) -> Sub msg


port loadingChangedReceiver : (Bool -> msg) -> Sub msg


port disableChangedReceiver : (Bool -> msg) -> Sub msg


port maxDropdownItemsChangedReceiver : (Int -> msg) -> Sub msg


port allowCustomOptionsReceiver : (Bool -> msg) -> Sub msg


port valueCasingDimensionsChangedReceiver : ({ width : Float, height : Float } -> msg) -> Sub msg
