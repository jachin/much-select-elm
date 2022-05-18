module Demo exposing (main)

import Browser
import Html exposing (Attribute, Html, button, div, option, select, text)
import Html.Attributes exposing (attribute, type_)
import Html.Attributes.Extra
import Html.Events exposing (onClick)
import Json.Encode


type alias Flags =
    ()


type alias Model =
    { allowCustomOptions : Bool }


type Msg
    = ValueChanged (List String)
    | ToggleAllowCustomValues


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
    ( { allowCustomOptions = False }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ValueChanged strings ->
            ( model, Cmd.none )

        ToggleAllowCustomValues ->
            ( { model | allowCustomOptions = not model.allowCustomOptions }, Cmd.none )


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


view : Model -> Html Msg
view model =
    let
        transformers =
            [ Lowercase ]

        validators =
            [ NoWhiteSpace ShowError "No white space allowd" ]
    in
    div []
        [ Html.node "much-select"
            [ allowCustomOptionsAttribute model.allowCustomOptions ]
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
        , button [ onClick ToggleAllowCustomValues ] [ text "toggle allow custom values" ]
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
