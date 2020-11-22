module Main exposing (..)

import Browser
import Css
    exposing
        ( absolute
        , backgroundColor
        , color
        , cursor
        , display
        , fontSize
        , height
        , hex
        , inlineBlock
        , left
        , minWidth
        , padding
        , pointer
        , position
        , px
        , relative
        , rgb
        , top
        )
import Html.Styled exposing (Html, div, input, text, toUnstyled)
import Html.Styled.Attributes exposing (class, css, type_, value)
import Html.Styled.Events exposing (onBlur, onFocus, onInput, onMouseDown, onMouseOut, onMouseOver)


type Msg
    = InputBlur
    | InputFocus
    | DropdownMouseOverOption Option
    | DropdownMouseOutOption Option
    | DropdownMouseClickOption Option
    | SearchInputOnInput String


type alias Model =
    { name : String
    , options : List Option
    , showDropdown : Bool
    , searchString : String
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputBlur ->
            ( { model | showDropdown = False }, Cmd.none )

        InputFocus ->
            ( { model | showDropdown = True }, Cmd.none )

        DropdownMouseOverOption option ->
            ( { model | options = highlightOptionInList option model.options }, Cmd.none )

        DropdownMouseOutOption option ->
            ( { model | options = removeHighlightOptionInList option model.options }, Cmd.none )

        DropdownMouseClickOption option ->
            ( { model | options = selectOptionInList option model.options }, Cmd.none )

        SearchInputOnInput string ->
            ( { model | searchString = string}, Cmd.none )


view : Model -> Html Msg
view model =
    div [ css [ position relative ] ]
        [ div [ class "value" ] (optionsToValuesHtml model.options)
        , input
            [ type_ "text"
            , onBlur InputBlur
            , onFocus InputFocus
            , onInput SearchInputOnInput
            , value model.searchString
            , css [ height (px 40), fontSize (px 25) ]
            ]
            []
        , dropdown model
        ]


dropdown : Model -> Html Msg
dropdown model =
    if model.showDropdown then
        div
            [ css
                [ backgroundColor (hex "EEEEEE")
                , display inlineBlock
                , padding (px 5)
                , position absolute
                , top (px 50)
                , left (px 0)
                , fontSize (px 20)
                , minWidth (px 200)
                ]
            ]
            (List.map optionToDropdownOption model.options)

    else
        text ""


optionToDropdownOption : Option -> Html Msg
optionToDropdownOption option =
    case getOptionDisplay option of
        OptionShown ->
            div
                [ onMouseOver (DropdownMouseOverOption option)
                , onMouseOut (DropdownMouseOutOption option)
                , onMouseDown (DropdownMouseClickOption option)
                , css
                    [ backgroundColor (rgb 255 255 255)
                    , padding (px 5)
                    , cursor pointer
                    ]
                ]
                [ text (getOptionLabelString option) ]

        OptionHidden ->
            text ""

        OptionSelected ->
            div
                [ class "selected"
                , css
                    [ backgroundColor (hex "111111")
                    , color (hex "EEEEEE")
                    , padding (px 5)
                    , cursor pointer
                    ]
                ]
                [ text (getOptionLabelString option) ]

        OptionHighlighted ->
            div
                [ onMouseOver (DropdownMouseOverOption option)
                , onMouseOut (DropdownMouseOutOption option)
                , onMouseDown (DropdownMouseClickOption option)
                , class "highlighted"
                , css
                    [ backgroundColor (hex "666666")
                    , color (hex "EEEEEE")
                    , padding (px 5)
                    , cursor pointer
                    ]
                ]
                [ text (getOptionLabelString option) ]


optionsToValuesHtml : List Option -> List (Html Msg)
optionsToValuesHtml options =
    options |>
        List.map (\option ->
            case option of
                (Option display (OptionLabel labelStr) _ ) ->
                    case display of
                        OptionShown ->
                            text ""

                        OptionHidden ->
                            text ""

                        OptionSelected ->
                            div [ class "value" ] [ text labelStr  ]

                        OptionHighlighted ->
                            text ""


        )


type alias Flags =
    { name : String }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { name = flags.name
      , options =
            [ newOption "Red"
            , newOption "Yellow"
            , newOption "Orange"
            , newOption "Green"
            , newOption "Blue"
            , newOption "Purple"
            ]
      , showDropdown = False
      , searchString = ""
      }
    , Cmd.none
    )


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view >> toUnstyled
        }


type OptionDisplay
    = OptionShown
    | OptionHidden
    | OptionSelected
    | OptionHighlighted


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
    = Option OptionDisplay OptionLabel OptionValue


newOption : String -> Option
newOption string =
    Option OptionShown (OptionLabel string) (OptionValue string)


getOptionDisplay : Option -> OptionDisplay
getOptionDisplay (Option display _ _) =
    display


getOptionLabelString : Option -> String
getOptionLabelString (Option _ label _) =
    optionLabelToString label


highlightOptionInList : Option -> List Option -> List Option
highlightOptionInList option options =
    List.map
        (\option_ ->
            if option_ == option then
                highlightOption option_

            else
                removeHighlightOption option_
        )
        options


removeHighlightOptionInList : Option -> List Option -> List Option
removeHighlightOptionInList option options =
    List.map
        (\option_ ->
            if option_ == option then
                removeHighlightOption option

            else
                option_
        )
        options


selectOptionInList : Option -> List Option -> List Option
selectOptionInList option options =
    List.map
        (\option_ ->
            if option_ == option then
                selectOption option_

            else
                option_
        )
        options

selectSingleOptionInList : Option -> List Option -> List Option
selectSingleOptionInList option options =
    options
    |> List.map
            (\option_ ->
                if option_ == option then
                    selectOption option_

                else
                    option_
            )



highlightOption : Option -> Option
highlightOption (Option display label value) =
    case display of
        OptionShown ->
            Option OptionHighlighted label value

        OptionHidden ->
            Option OptionHidden label value

        OptionSelected ->
            Option OptionSelected label value

        OptionHighlighted ->
            Option OptionHighlighted label value



removeHighlightOption : Option -> Option
removeHighlightOption (Option display label value) =
    case display of
        OptionShown ->
            Option OptionShown label value

        OptionHidden ->
            Option OptionHidden label value

        OptionSelected ->
            Option OptionSelected label value

        OptionHighlighted ->
            Option OptionShown label value



selectOption : Option -> Option
selectOption (Option display label value) =
    case display of
        OptionShown ->
            Option OptionSelected label value

        OptionHidden ->
            Option OptionSelected label value

        OptionSelected ->
            Option OptionSelected label value

        OptionHighlighted ->
            Option OptionSelected label value

deselect



selectedValueLabel : List Option -> String
selectedValueLabel options =
    options
        |> List.filter
            (\option_ ->
                case option_ of
                    Option display _ _ ->
                        case display of
                            OptionShown ->
                                False

                            OptionHidden ->
                                False

                            OptionSelected ->
                                True

                            OptionHighlighted ->
                                False
            )
        |> List.head
        |> Maybe.map getOptionLabelString
        |> Maybe.withDefault ""
