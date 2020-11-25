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
        , fontWeight
        , height
        , hex
        , inlineBlock
        , int
        , left
        , minWidth
        , padding
        , pointer
        , position
        , px
        , relative
        , rem
        , rgb
        , top
        )
import Html.Styled exposing (Html, div, input, text, toUnstyled)
import Html.Styled.Attributes exposing (class, css, placeholder, type_, value)
import Html.Styled.Events
    exposing
        ( onBlur
        , onFocus
        , onInput
        , onMouseDown
        , onMouseEnter
        , onMouseLeave
        )
import Json.Decode
import Option
    exposing
        ( Option(..)
        , OptionDisplay(..)
        , OptionLabel(..)
        , getOptionDescriptionString
        , getOptionDisplay
        , getOptionLabelString
        , highlightOptionInList
        , optionHadDescription
        , optionListGrouped
        , removeHighlightOptionInList
        , selectOptionInList
        , selectOptionsInOptionsList
        , selectSingleOptionInList
        , selectedOptionsToTuple
        )
import Ports
    exposing
        ( disableChangedReceiver
        , loadingChangedReceiver
        , placeholderChangedReceiver
        , valueChanged
        , valueChangedReceiver
        , valuesDecoder
        )


type Msg
    = InputBlur
    | InputFocus
    | DropdownMouseOverOption Option
    | DropdownMouseOutOption Option
    | DropdownMouseClickOption Option
    | SearchInputOnInput String
    | ValueChanged Json.Decode.Value
    | PlaceholderAttributeChanged String
    | LoadingAttributeChanged Bool
    | DisabledAttributeChanged Bool


type alias Model =
    { initialValue : String
    , placeholder : String
    , size : String
    , selectionMode : SelectionMode
    , options : List Option
    , showDropdown : Bool
    , searchString : String
    , loading : Bool
    , disabled : Bool
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

        ValueChanged valuesJson ->
            let
                valuesResult =
                    Json.Decode.decodeValue valuesDecoder valuesJson
            in
            case valuesResult of
                Ok values ->
                    ( { model | options = selectOptionsInOptionsList values model.options }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        PlaceholderAttributeChanged newPlaceholder ->
            ( { model | placeholder = newPlaceholder }, Cmd.none )

        LoadingAttributeChanged bool ->
            ( { model | loading = bool }, Cmd.none )

        DisabledAttributeChanged bool ->
            ( { model | disabled = bool }, Cmd.none )


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
            , placeholder model.placeholder
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
            (optionsToDropdownOptions model.selectionMode model.options)

    else
        text ""


optionsToDropdownOptions : SelectionMode -> List Option -> List (Html Msg)
optionsToDropdownOptions selectionMode options =
    optionListGrouped options
        |> List.map (optionListGroupToDropdown selectionMode)
        |> List.concat


optionListGroupToDropdown : SelectionMode -> ( String, List Option ) -> List (Html Msg)
optionListGroupToDropdown selectionMode ( optGroupLabelStr, options ) =
    case optGroupLabelStr of
        "" ->
            List.map (optionToDropdownOption selectionMode) options

        _ ->
            List.append
                [ div
                    [ class "optgroup"
                    , css
                        [ backgroundColor (rgb 200 200 200)
                        , fontSize (rem 0.85)
                        , fontWeight (int 300)
                        , padding (px 5)
                        ]
                    ]
                    [ text optGroupLabelStr ]
                ]
                (List.map (optionToDropdownOption selectionMode) options)


optionToDropdownOption : SelectionMode -> Option -> Html Msg
optionToDropdownOption selectionMode option =
    let
        descriptionHtml =
            if optionHadDescription option then
                div
                    [ class "description"
                    , css
                        [ fontSize (rem 0.85)
                        , padding (px 3)
                        ]
                    ]
                    [ text (getOptionDescriptionString option) ]

            else
                text ""
    in
    case getOptionDisplay option of
        OptionShown ->
            div
                [ onMouseEnter (DropdownMouseOverOption option)
                , onMouseLeave (DropdownMouseOutOption option)
                , onMouseDown (DropdownMouseClickOption option)
                , class "option"
                , css
                    [ backgroundColor (rgb 255 255 255)
                    , padding (px 5)
                    , cursor pointer
                    ]
                ]
                [ text (getOptionLabelString option), descriptionHtml ]

        OptionHidden ->
            text ""

        OptionSelected ->
            case selectionMode of
                SingleSelect ->
                    div
                        [ class "selected"
                        , class "option"
                        , css
                            [ backgroundColor (hex "111111")
                            , color (hex "EEEEEE")
                            , padding (px 5)
                            , cursor pointer
                            ]
                        ]
                        [ text (getOptionLabelString option), descriptionHtml ]

                MultiSelect ->
                    text ""

        OptionHighlighted ->
            div
                [ onMouseEnter (DropdownMouseOverOption option)
                , onMouseLeave (DropdownMouseOutOption option)
                , onMouseDown (DropdownMouseClickOption option)
                , class "highlighted"
                , class "option"
                , css
                    [ backgroundColor (hex "666666")
                    , color (hex "EEEEEE")
                    , padding (px 5)
                    , cursor pointer
                    ]
                ]
                [ text (getOptionLabelString option), descriptionHtml ]


optionsToValuesHtml : List Option -> List (Html Msg)
optionsToValuesHtml options =
    options
        |> List.map
            (\option ->
                case option of
                    Option display (OptionLabel labelStr) _ _ _ ->
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
    , loading : Bool
    , disabled : Bool
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
      , loading = flags.loading
      , disabled = flags.disabled
      }
    , Cmd.none
    )


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view >> toUnstyled
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ valueChangedReceiver ValueChanged
        , placeholderChangedReceiver PlaceholderAttributeChanged
        , loadingChangedReceiver LoadingAttributeChanged
        , disableChangedReceiver DisabledAttributeChanged
        ]
