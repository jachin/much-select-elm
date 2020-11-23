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
import Html.Styled.Events
    exposing
        ( onBlur
        , onFocus
        , onInput
        , onMouseDown
        , onMouseOut
        , onMouseOver
        )
import Json.Decode
import Option
    exposing
        ( Option(..)
        , OptionDisplay(..)
        , OptionLabel(..)
        , getOptionDisplay
        , getOptionLabelString
        , highlightOptionInList
        , newOption
        , removeHighlightOptionInList
        , selectOptionInList
        , selectSingleOptionInList
        , selectedOptionsToTuple
        )
import Ports exposing (valueChanged)


type Msg
    = InputBlur
    | InputFocus
    | DropdownMouseOverOption Option
    | DropdownMouseOutOption Option
    | DropdownMouseClickOption Option
    | SearchInputOnInput String


type alias Model =
    { initialValue : String
    , placeholder : String
    , size : String
    , selectionMode : SelectionMode
    , options : List Option
    , showDropdown : Bool
    , searchString : String
    }


type SelectionMode
    = SingleSelect
    | MultiSelect


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
            let
                options =
                    case model.selectionMode of
                        MultiSelect ->
                            selectOptionInList option model.options

                        SingleSelect ->
                            selectSingleOptionInList option model.options
            in
            ( { model | options = options }, valueChanged (selectedOptionsToTuple options) )

        SearchInputOnInput string ->
            ( { model | searchString = string }, Cmd.none )


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
            (List.map (optionToDropdownOption model.selectionMode) model.options)

    else
        text ""


optionToDropdownOption : SelectionMode -> Option -> Html Msg
optionToDropdownOption selectionMode option =
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
            case selectionMode of
                SingleSelect ->
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

                MultiSelect ->
                    text ""

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
    options
        |> List.map
            (\option ->
                case option of
                    Option display (OptionLabel labelStr) _ ->
                        case display of
                            OptionShown ->
                                text ""

                            OptionHidden ->
                                text ""

                            OptionSelected ->
                                div [ class "value" ] [ text labelStr ]

                            OptionHighlighted ->
                                text ""
            )


type alias Flags =
    { value : String
    , placeholder : String
    , size : String
    , allowMultiSelect : Bool
    , optionsJson : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { initialValue = flags.value
      , placeholder = flags.placeholder
      , size = flags.size
      , selectionMode =
            if flags.allowMultiSelect then
                MultiSelect

            else
                SingleSelect

      -- TODO if this decoder fails we should "do" something about it.
      , options =
            Json.Decode.decodeString Option.optionsDecoder flags.optionsJson
                |> Result.withDefault []
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
