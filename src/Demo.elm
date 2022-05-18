module Demo exposing (main)

import Browser
import Html exposing (Attribute, Html, button, div, option, select, text)
import Html.Attributes exposing (attribute)
import Html.Attributes.Extra
import Html.Events exposing (onClick)


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
    div []
        [ Html.node "much-select"
            [ allowCustomOptionsAttribute model.allowCustomOptions ]
            [ select [ slot "select-input" ]
                [ option [] [ text "Tom" ]
                , option [] [ text "Bert" ]
                , option [] [ text "William" ]
                ]
            ]
        , button [ onClick ToggleAllowCustomValues ] [ text "toggle allow custom values" ]
        ]
