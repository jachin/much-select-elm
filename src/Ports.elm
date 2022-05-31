port module Ports exposing
    ( addOptionsReceiver
    , allOptions
    , allowCustomOptionsReceiver
    , blurInput
    , customOptionSelected
    , customValidationReceiver
    , deselectOptionReceiver
    , disableChangedReceiver
    , errorMessage
    , focusInput
    , initialValueSet
    , inputBlurred
    , inputFocused
    , inputKeyUp
    , invalidValue
    , loadingChangedReceiver
    , maxDropdownItemsChangedReceiver
    , muchSelectIsReady
    , multiSelectChangedReceiver
    , multiSelectSingleItemRemovalChangedReceiver
    , optionDeselected
    , optionEncoder
    , optionSelected
    , optionSortingChangedReceiver
    , optionsEncoder
    , optionsReplacedReceiver
    , optionsUpdated
    , outputStyleChangedReceiver
    , placeholderChangedReceiver
    , removeOptionsReceiver
    , requestAllOptionsReceiver
    , scrollDropdownToElement
    , searchOptionsWithWebWorker
    , searchStringMinimumLengthChangedReceiver
    , selectOptionReceiver
    , selectedItemStaysInPlaceChangedReceiver
    , sendCustomValidationRequest
    , showDropdownFooterChangedReceiver
    , transformationAndValidationReceiver
    , updateOptionsFromDom
    , updateOptionsInWebWorker
    , updateSearchResultDataWithWebWorkerReceiver
    , valueCasingDimensionsChangedReceiver
    , valueChanged
    , valueChangedReceiver
    , valueCleared
    , valueDecoder
    , valuesDecoder
    )

import Json.Decode
import Json.Encode
import Option exposing (Option)
import OptionLabel


port muchSelectIsReady : () -> Cmd msg


port errorMessage : String -> Cmd msg


port valueChanged : Json.Encode.Value -> Cmd msg


port invalidValue : Json.Encode.Value -> Cmd msg


port initialValueSet : Json.Encode.Value -> Cmd msg


port customOptionSelected : List String -> Cmd msg


port valueCleared : () -> Cmd msg


port optionSelected : Json.Encode.Value -> Cmd msg


port optionDeselected : Json.Encode.Value -> Cmd msg


optionsEncoder : List Option -> Json.Encode.Value
optionsEncoder options =
    Json.Encode.list optionEncoder options


optionEncoder : Option -> Json.Encode.Value
optionEncoder option =
    Json.Encode.object
        [ ( "value", Json.Encode.string (Option.getOptionValueAsString option) )
        , ( "label", Json.Encode.string (Option.getOptionLabel option |> OptionLabel.optionLabelToString) )
        , ( "isValid", Json.Encode.bool (Option.isValid option) )
        ]


port inputKeyUp : String -> Cmd msg


{-| This port is involved in caring out the blurring process.
-}
port blurInput : () -> Cmd msg


{-| This port is called after this much select has been blurred.
-}
port inputBlurred : () -> Cmd msg


{-| This port is involved in caring out the focusing process.
-}
port focusInput : () -> Cmd msg


{-| This port is called after this much select has been focused
-}
port inputFocused : () -> Cmd msg


port allOptions : Json.Decode.Value -> Cmd msg


port updateOptionsFromDom : () -> Cmd msg


port searchOptionsWithWebWorker : Json.Decode.Value -> Cmd msg


port updateOptionsInWebWorker : () -> Cmd msg


port sendCustomValidationRequest : ( String, Int ) -> Cmd msg


port customValidationReceiver : (Json.Decode.Value -> msg) -> Sub msg


port transformationAndValidationReceiver : (Json.Decode.Value -> msg) -> Sub msg


port requestAllOptionsReceiver : (() -> msg) -> Sub msg


{-| This is called when options have been updated, the bool is true if all the options have been "replaced" and it's
false if the have just been "tweaked"
-}
port optionsUpdated : Bool -> Cmd msg


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


port optionsReplacedReceiver : (Json.Decode.Value -> msg) -> Sub msg


port addOptionsReceiver : (Json.Decode.Value -> msg) -> Sub msg


port removeOptionsReceiver : (Json.Decode.Value -> msg) -> Sub msg


port selectOptionReceiver : (Json.Decode.Value -> msg) -> Sub msg


port deselectOptionReceiver : (Json.Decode.Value -> msg) -> Sub msg


port placeholderChangedReceiver : (( Bool, String ) -> msg) -> Sub msg


port loadingChangedReceiver : (Bool -> msg) -> Sub msg


port disableChangedReceiver : (Bool -> msg) -> Sub msg


port multiSelectChangedReceiver : (Bool -> msg) -> Sub msg


port multiSelectSingleItemRemovalChangedReceiver : (Bool -> msg) -> Sub msg


port searchStringMinimumLengthChangedReceiver : (Int -> msg) -> Sub msg


port selectedItemStaysInPlaceChangedReceiver : (Bool -> msg) -> Sub msg


port maxDropdownItemsChangedReceiver : (Int -> msg) -> Sub msg


port showDropdownFooterChangedReceiver : (Bool -> msg) -> Sub msg


port allowCustomOptionsReceiver : (( Bool, String ) -> msg) -> Sub msg


port valueCasingDimensionsChangedReceiver : ({ width : Float, height : Float } -> msg) -> Sub msg


port optionSortingChangedReceiver : (String -> msg) -> Sub msg


port outputStyleChangedReceiver : (String -> msg) -> Sub msg


port updateSearchResultDataWithWebWorkerReceiver : (Json.Encode.Value -> msg) -> Sub msg
