port module Ports exposing
    ( addOptionsReceiver
    , allOptions
    , allowCustomOptionsReceiver
    , blurInput
    , customOptionHintReceiver
    , customOptionSelected
    , deselectOptionReceiver
    , disableChangedReceiver
    , errorMessage
    , focusInput
    , inputBlurred
    , inputKeyUp
    , loadingChangedReceiver
    , maxDropdownItemsChangedReceiver
    , muchSelectIsReady
    , multiSelectChangedReceiver
    , optionDeselected
    , optionSelected
    , optionsChangedReceiver
    , placeholderChangedReceiver
    , removeOptionsReceiver
    , requestAllOptionsReceiver
    , scrollDropdownToElement
    , selectOptionReceiver
    , selectedItemStaysInPlaceChangedReceiver
    , valueCasingDimensionsChangedReceiver
    , valueChanged
    , valueChangedReceiver
    , valueCleared
    , valueDecoder
    , valuesDecoder
    )

import Json.Decode


port muchSelectIsReady : () -> Cmd msg


port errorMessage : String -> Cmd msg


port valueChanged : List ( String, String ) -> Cmd msg


port customOptionSelected : List String -> Cmd msg


port valueCleared : () -> Cmd msg


port optionSelected : ( String, String ) -> Cmd msg


port optionDeselected : List ( String, String ) -> Cmd msg


port inputKeyUp : String -> Cmd msg


port blurInput : () -> Cmd msg


port inputBlurred : () -> Cmd msg


port focusInput : () -> Cmd msg


port allOptions : Json.Decode.Value -> Cmd msg


port requestAllOptionsReceiver : (() -> msg) -> Sub msg


port scrollDropdownToElement : String -> Cmd msg


valuesDecoder : Json.Decode.Decoder (List String)
valuesDecoder =
    Json.Decode.oneOf
        [ Json.Decode.list Json.Decode.string
        , Json.Decode.string
            |> Json.Decode.map
                List.singleton
        ]


valueDecoder : Json.Decode.Decoder (List String)
valueDecoder =
    Json.Decode.oneOf
        [ Json.Decode.string
            |> Json.Decode.map
                List.singleton
        , Json.Decode.list Json.Decode.string
            |> Json.Decode.andThen
                (\listOfString ->
                    case listOfString of
                        [ _ ] ->
                            Json.Decode.succeed listOfString

                        _ ->
                            Json.Decode.fail "Only 1 value is allowed when in single select mode."
                )
        , Json.Decode.null []
        ]


port valueChangedReceiver : (Json.Decode.Value -> msg) -> Sub msg


port optionsChangedReceiver : (Json.Decode.Value -> msg) -> Sub msg


port addOptionsReceiver : (Json.Decode.Value -> msg) -> Sub msg


port removeOptionsReceiver : (Json.Decode.Value -> msg) -> Sub msg


port selectOptionReceiver : (Json.Decode.Value -> msg) -> Sub msg


port deselectOptionReceiver : (Json.Decode.Value -> msg) -> Sub msg


port placeholderChangedReceiver : (String -> msg) -> Sub msg


port loadingChangedReceiver : (Bool -> msg) -> Sub msg


port disableChangedReceiver : (Bool -> msg) -> Sub msg


port multiSelectChangedReceiver : (Bool -> msg) -> Sub msg


port selectedItemStaysInPlaceChangedReceiver : (Bool -> msg) -> Sub msg


port maxDropdownItemsChangedReceiver : (Int -> msg) -> Sub msg


port allowCustomOptionsReceiver : (Bool -> msg) -> Sub msg


port customOptionHintReceiver : (Maybe String -> msg) -> Sub msg


port valueCasingDimensionsChangedReceiver : ({ width : Float, height : Float } -> msg) -> Sub msg
