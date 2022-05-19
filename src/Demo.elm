module Demo exposing (main)

import Browser
import Html exposing (Attribute, Html, button, div, fieldset, form, input, label, legend, option, select, text)
import Html.Attributes exposing (attribute, for, id, name, type_, value)
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
    }


type Msg
    = ValueChanged MuchSelectValue
    | InputKeyUpDebounced String
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
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ValueChanged _ ->
            ( model, Cmd.none )

        InputKeyUpDebounced _ ->
            ( model, Cmd.none )

        ToggleAllowCustomValues ->
            ( { model | allowCustomOptions = not model.allowCustomOptions }, Cmd.none )

        ToggleMultiSelect ->
            ( { model | allowMultiSelect = not model.allowMultiSelect }, Cmd.none )

        ChangeOutputStyle string ->
            ( { model | outputStyle = string }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


slot : String -> Attribute msg
slot string =
    attribute "slot" string


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


type alias MuchSelectValue =
    { value : String, label : String }


valueDecoder : Json.Decode.Decoder MuchSelectValue
valueDecoder =
    Json.Decode.map2
        MuchSelectValue
        (Json.Decode.field "value" Json.Decode.string)
        (Json.Decode.field "label" Json.Decode.string)


singleValueChangedAttribute : Attribute Msg
singleValueChangedAttribute =
    on "valueChanged" (Json.Decode.map ValueChanged (Json.Decode.at [ "detail", "value" ] valueDecoder))


inputKeyupAttribute : Attribute Msg
inputKeyupAttribute =
    on "inputKeyUpDebounced"
        (Json.Decode.at
            [ "detail", "searchString" ]
            Json.Decode.string
            |> Json.Decode.map InputKeyUpDebounced
        )


view : Model -> Html Msg
view model =
    let
        transformers =
            [ Lowercase ]

        validators =
            [ NoWhiteSpace ShowError "No white space allowed" ]
    in
    div []
        [ Html.node "much-select"
            [ attribute "events-only" ""
            , allowCustomOptionsAttribute model.allowCustomOptions
            , multiSelectAttribute model.allowMultiSelect
            , outputStyleAttribute model.outputStyle
            , singleValueChangedAttribute
            , inputKeyupAttribute
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
            ]
        , form []
            [ fieldset []
                [ legend [] [ text "Input Methods" ]
                , button [ onClick ToggleAllowCustomValues, type_ "button" ] [ text "toggle allow custom values" ]
                , button [ onClick ToggleMultiSelect, type_ "button" ] [ text "toggle multi select" ]
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
                    , onChange ChangeOutputStyle
                    ]
                    []
                , label [ for "output-style-custom-html" ] [ text "Custom HTML" ]
                , input
                    [ type_ "radio"
                    , name "output-style"
                    , id "output-style-datalist"
                    , value "datalist"
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


type ValidatorLevel
    = ShowError
    | Silent


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


encodeValidatorLevel : ValidatorLevel -> Json.Encode.Value
encodeValidatorLevel validatorLevel =
    case validatorLevel of
        ShowError ->
            Json.Encode.string "error"

        Silent ->
            Json.Encode.string "silent"
