module Demo exposing (main)

import Browser
import Html exposing (Html)


type alias Flags =
    ()


type alias Model =
    ()


type Msg
    = ValueChanged (List String)


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
    ( (), Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ValueChanged strings ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view model =
    Html.node "much-select" [] []
