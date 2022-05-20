module Demo exposing (main)

import Browser
import Html
    exposing
        ( Attribute
        , Html
        , button
        , div
        , fieldset
        , form
        , input
        , label
        , legend
        , option
        , select
        , table
        , td
        , text
        , tr
        )
import Html.Attributes exposing (attribute, checked, for, id, name, type_, value)
import Html.Attributes.Extra
import Html.Events exposing (on, onClick)
import Html.Events.Extra exposing (onChange)
import Json.Decode
import Json.Encode


type alias Flags =
    ()


type alias Model =
    { allowCustomOptions : Bool
    , allowMultiSelect : Bool
    , outputStyle : String
    , customValidationResult : ValidationResult
    }


type Msg
    = MuchSelectReady
    | ValueChanged (List MuchSelectValue)
    | ValueCleared
    | OptionSelected
    | BlurOrUnfocusedValueChanged String
    | InputKeyUpDebounced String
    | InputKeyUp String
    | OptionsUpdated
    | OptionDeselected
    | CustomValueSelected String
    | CustomValidationRequest String Int
    | ToggleAllowCustomValues
    | ToggleMultiSelect
    | ChangeOutputStyle String


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { allowCustomOptions = False
      , allowMultiSelect = False
      , outputStyle = "custom-html"
      , customValidationResult = NothingToValidate
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ValueChanged _ ->
            ( model, Cmd.none )

        ValueCleared ->
            ( model, Cmd.none )

        BlurOrUnfocusedValueChanged _ ->
            ( model, Cmd.none )

        InputKeyUpDebounced _ ->
            ( model, Cmd.none )

        ToggleAllowCustomValues ->
            ( { model | allowCustomOptions = not model.allowCustomOptions }, Cmd.none )

        ToggleMultiSelect ->
            ( { model | allowMultiSelect = not model.allowMultiSelect }, Cmd.none )

        ChangeOutputStyle string ->
            ( { model | outputStyle = string }, Cmd.none )

        MuchSelectReady ->
            ( model, Cmd.none )

        OptionSelected ->
            ( model, Cmd.none )

        OptionDeselected ->
            ( model, Cmd.none )

        OptionsUpdated ->
            ( model, Cmd.none )

        InputKeyUp _ ->
            ( model, Cmd.none )

        CustomValueSelected _ ->
            ( model, Cmd.none )

        CustomValidationRequest string int ->
            let
                isValid =
                    not (String.startsWith "asdf" string)

                customValidationResult =
                    if isValid then
                        ValidationPass string int

                    else
                        ValidationFailed string int [ ( "Come on, you can do better than 'asdf'", "error" ) ]
            in
            ( { model | customValidationResult = customValidationResult }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


slot : String -> Attribute msg
slot string =
    attribute "slot" string


onInputKeyupDebounced : Attribute Msg
onInputKeyupDebounced =
    on "inputKeyUpDebounced"
        (Json.Decode.at
            [ "detail", "searchString" ]
            Json.Decode.string
            |> Json.Decode.map InputKeyUpDebounced
        )


onInputKeyUp : Attribute Msg
onInputKeyUp =
    on "inputKeyUpDebounced"
        (Json.Decode.at
            [ "detail", "searchString" ]
            Json.Decode.string
            |> Json.Decode.map InputKeyUp
        )


onReady : Attribute Msg
onReady =
    on "muchSelectReady" (Json.Decode.succeed MuchSelectReady)


type alias MuchSelectValue =
    { value : String, label : String }


valueDecoder : Json.Decode.Decoder MuchSelectValue
valueDecoder =
    Json.Decode.map2
        MuchSelectValue
        (Json.Decode.field "value" Json.Decode.string)
        (Json.Decode.field "label" Json.Decode.string)


onValueChanged : Attribute Msg
onValueChanged =
    on "valueChanged" (Json.Decode.map ValueChanged (Json.Decode.at [ "detail", "values" ] (Json.Decode.list valueDecoder)))


onValueCleared : Attribute Msg
onValueCleared =
    on "valueCleared" (Json.Decode.succeed ValueCleared)


onOptionSelected : Attribute Msg
onOptionSelected =
    on "optionSelected" (Json.Decode.succeed OptionSelected)


onCustomValueSelected : Attribute Msg
onCustomValueSelected =
    on "customValueSelected"
        (Json.Decode.at
            [ "detail", "value" ]
            Json.Decode.string
            |> Json.Decode.map CustomValueSelected
        )


onOptionDeselected : Attribute Msg
onOptionDeselected =
    on "optionDeselected" (Json.Decode.succeed OptionDeselected)


onBlurOrUnfocusedValueChanged : Attribute Msg
onBlurOrUnfocusedValueChanged =
    on "blurOrUnfocusedValueChanged"
        (Json.Decode.map BlurOrUnfocusedValueChanged
            (Json.Decode.at [ "detail", "value" ]
                Json.Decode.string
            )
        )


onOptionsUpdated : Attribute Msg
onOptionsUpdated =
    on "optionsUpdated" (Json.Decode.succeed OptionsUpdated)


onCustomValidationRequest : Attribute Msg
onCustomValidationRequest =
    on "customValidateRequest"
        (Json.Decode.map2 CustomValidationRequest
            (Json.Decode.at [ "detail", "stringToValidate" ]
                Json.Decode.string
            )
            (Json.Decode.at [ "detail", "selectedValueIndex" ]
                Json.Decode.int
            )
        )


allowCustomOptionsAttribute : Bool -> Attribute msg
allowCustomOptionsAttribute bool =
    if bool then
        attribute "allow-custom-options" ""

    else
        Html.Attributes.Extra.empty


multiSelectAttribute : Bool -> Attribute msg
multiSelectAttribute bool =
    if bool then
        attribute "multi-select" ""

    else
        Html.Attributes.Extra.empty


outputStyleAttribute : String -> Attribute msg
outputStyleAttribute string =
    attribute "output-style" string


view : Model -> Html Msg
view model =
    let
        transformers =
            [ Lowercase ]

        validators =
            [ NoWhiteSpace ShowError "No white space allowed"
            , Custom
            ]
    in
    div []
        [ Html.node "much-select"
            [ attribute "events-only" ""
            , allowCustomOptionsAttribute model.allowCustomOptions
            , multiSelectAttribute model.allowMultiSelect
            , outputStyleAttribute model.outputStyle
            , onValueChanged
            , onCustomValidationRequest
            , onCustomValueSelected
            , onBlurOrUnfocusedValueChanged
            , onValueCleared
            , onInputKeyupDebounced
            , onInputKeyUp
            , onReady
            , onOptionSelected
            , onOptionDeselected
            , onOptionsUpdated
            ]
            [ select [ slot "select-input" ]
                [ option [] [ text "tom" ]
                , option [] [ text "bert" ]
                , option [] [ text "william" ]
                ]
            , Html.node "script"
                [ slot "transformation-validation"
                , type_ "application/json"
                ]
                [ text (Json.Encode.encode 0 (encode transformers validators)) ]
            , Html.node "script"
                [ slot "custom-validation-result"
                , type_ "application/json"
                ]
                [ text (Json.Encode.encode 0 (encodeCustomValidateResult model.customValidationResult)) ]
            ]
        , form []
            [ fieldset []
                [ legend [] [ text "Input Methods" ]
                , table []
                    [ tr []
                        [ td [] [ text "Allow Custom Options" ]
                        , td []
                            [ if model.allowCustomOptions then
                                text "ON"

                              else
                                text "OFF"
                            ]
                        , td []
                            [ button [ onClick ToggleAllowCustomValues, type_ "button" ] [ text "toggle" ]
                            ]
                        ]
                    , tr []
                        [ td [] [ text "Multi Select" ]
                        , td []
                            [ if model.allowMultiSelect then
                                text "ON"

                              else
                                text "OFF"
                            ]
                        , td []
                            [ button [ onClick ToggleMultiSelect, type_ "button" ] [ text "toggle" ]
                            ]
                        ]
                    ]
                ]
            , fieldset []
                [ legend []
                    [ text "Output Style"
                    ]
                , input
                    [ type_ "radio"
                    , name "output-style"
                    , id "output-style-custom-html"
                    , value "custom-html"
                    , checked (model.outputStyle == "custom-html")
                    , onChange ChangeOutputStyle
                    ]
                    []
                , label [ for "output-style-custom-html" ] [ text "Custom HTML" ]
                , input
                    [ type_ "radio"
                    , name "output-style"
                    , id "output-style-datalist"
                    , value "datalist"
                    , checked (model.outputStyle == "datalist")
                    , onChange ChangeOutputStyle
                    ]
                    []
                , label [ for "output-style-datalist" ] [ text "datalist" ]
                ]
            ]
        ]


type Transformer
    = Lowercase


type Validator
    = NoWhiteSpace ValidatorLevel String
    | MinimumLength ValidatorLevel String Int
    | Custom


type ValidatorLevel
    = ShowError
    | Silent


type ValidationResult
    = NothingToValidate
    | ValidationPass String Int
    | ValidationFailed String Int (List ( String, String ))


encode : List Transformer -> List Validator -> Json.Encode.Value
encode transformers validators =
    Json.Encode.object
        [ ( "transformers", Json.Encode.list encodeTransformer transformers )
        , ( "validators", Json.Encode.list encodeValidator validators )
        ]


encodeTransformer : Transformer -> Json.Encode.Value
encodeTransformer transformer =
    case transformer of
        Lowercase ->
            Json.Encode.object [ ( "name", Json.Encode.string "lowercase" ) ]


encodeValidator : Validator -> Json.Encode.Value
encodeValidator validator =
    case validator of
        NoWhiteSpace validatorLevel string ->
            Json.Encode.object
                [ ( "name", Json.Encode.string "no-white-space" )
                , ( "level", encodeValidatorLevel validatorLevel )
                , ( "message", Json.Encode.string string )
                ]

        MinimumLength validatorLevel string int ->
            Json.Encode.object
                [ ( "name", Json.Encode.string "minimum-length" )
                , ( "level", encodeValidatorLevel validatorLevel )
                , ( "message", Json.Encode.string string )
                , ( "minimum-length", Json.Encode.int int )
                ]

        Custom ->
            Json.Encode.object
                [ ( "name", Json.Encode.string "custom" )
                ]


encodeValidatorLevel : ValidatorLevel -> Json.Encode.Value
encodeValidatorLevel validatorLevel =
    case validatorLevel of
        ShowError ->
            Json.Encode.string "error"

        Silent ->
            Json.Encode.string "silent"


encodeCustomValidateResult : ValidationResult -> Json.Encode.Value
encodeCustomValidateResult validationResult =
    case validationResult of
        NothingToValidate ->
            Json.Encode.string ""

        ValidationPass string int ->
            Json.Encode.object
                [ ( "isValid", Json.Encode.bool True )
                , ( "value", Json.Encode.string string )
                , ( "selectedValueIndex", Json.Encode.int int )
                ]

        ValidationFailed string int errorMessages ->
            let
                encodeErrorMessage ( errorMessage, errorLevel ) =
                    Json.Encode.object
                        [ ( "errorMessage", Json.Encode.string errorMessage )
                        , ( "level", Json.Encode.string errorLevel )
                        ]
            in
            Json.Encode.object
                [ ( "isValid", Json.Encode.bool False )
                , ( "value", Json.Encode.string string )
                , ( "selectedValueIndex", Json.Encode.int int )
                , ( "errorMessages", Json.Encode.list encodeErrorMessage errorMessages )
                ]
