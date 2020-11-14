module Main exposing (..)

import Browser
import Html exposing (Html, div, input, text)
import Html.Attributes exposing (type_)


type Msg
    = NoOp


type alias Model =
    { name : String
    , options : List Option
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ input [ type_ "text" ] []
        , div [] (List.map optionToDropdownOption model.options)
        ]


optionToDropdownOption : Option -> Html Msg
optionToDropdownOption (Option _ _ label _) =
    div [] [ text (optionLabelToString label) ]


type alias Flags =
    { name : String }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( Model flags.name
        [ newOption "Red"
        , newOption "Green"
        , newOption "Blue"
        , newOption "Orange"
        , newOption "Green"
        , newOption "Purple"
        ]
    , Cmd.none
    )


main : Program Flags Model Msg
main =
    Browser.element
        { init = init, update = update, subscriptions = \_ -> Sub.none, view = view }


type OptionSelected
    = OptionSelected
    | OptionNotSelected


type OptionVisibility
    = OptionShown
    | OptionHidden


type OptionLabel
    = OptionLabel String


optionLabelToString : OptionLabel -> String
optionLabelToString optionLabel =
    case optionLabel of
        OptionLabel label ->
            label


type OptionValue
    = OptionValue String


type Option
    = Option OptionSelected OptionVisibility OptionLabel OptionValue


newOption : String -> Option
newOption string =
    Option OptionNotSelected OptionShown (OptionLabel string) (OptionValue string)
