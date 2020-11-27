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
        , OptionGroup
        , OptionLabel(..)
        , OptionValue
        , highlightOptionInList
        , removeHighlightOptionInList
        , selectOptionInList
        , selectOptionsInOptionsList
        , selectSingleOptionInList
        , selectedOptionsToTuple
        )
import OptionPresentor exposing (OptionPresenter)
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
    | DropdownMouseOverOption OptionValue
    | DropdownMouseOutOption OptionValue
    | DropdownMouseClickOption OptionValue
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

        DropdownMouseOverOption optionValue ->
            ( { model | options = highlightOptionInList optionValue model.options }, Cmd.none )

        DropdownMouseOutOption optionValue ->
            ( { model | options = removeHighlightOptionInList optionValue model.options }, Cmd.none )

        DropdownMouseClickOption optionValue ->
            let
                options =
                    case model.selectionMode of
                        MultiSelect ->
                            selectOptionInList optionValue model.options

                        SingleSelect ->
                            selectSingleOptionInList optionValue model.options
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
            (optionsToDropdownOptions model.selectionMode
                (OptionPresentor.prepareOptionsForPresentation model.searchString model.options)
            )

    else
        text ""


optionsToDropdownOptions : SelectionMode -> List OptionPresenter -> List (Html Msg)
optionsToDropdownOptions selectionMode options =
    let
        one =
            optionToDropdownOption selectionMode

        helper : OptionGroup -> List OptionPresenter -> List (OptionPresenter -> List (Html Msg))
        helper previousGroup options_ =
            case List.head options_ of
                Just option_ ->
                    let
                        thingy =
                            if previousGroup == option_.group then
                                one False

                            else
                                one True
                    in
                    List.append [ thingy ] (helper option_.group (options_ |> List.tail |> Maybe.withDefault []))

                Nothing ->
                    []

        partials : List (OptionPresenter -> List (Html Msg))
        partials =
            helper Option.emptyOptionGroup options
    in
    List.map2
        (\option partial ->
            partial option
        )
        options
        partials
        |> List.concat


optionToDropdownOption : SelectionMode -> Bool -> OptionPresenter -> List (Html Msg)
optionToDropdownOption selectionMode prependOptionGroup option =
    let
        optionGroupHtml =
            if prependOptionGroup then
                div
                    [ class "optgroup"
                    , css
                        [ backgroundColor (rgb 200 200 200)
                        , fontSize (rem 0.85)
                        , fontWeight (int 300)
                        , padding (px 5)
                        ]
                    ]
                    [ text (Option.optionGroupToString option.group) ]

            else
                text ""

        descriptionHtml =
            if OptionPresentor.hasDescription option then
                div
                    [ class "description"
                    , css
                        [ fontSize (rem 0.85)
                        , padding (px 3)
                        ]
                    ]
                    [ text (Option.optionDescriptionToString option.description) ]

            else
                text ""
    in
    case option.display of
        OptionShown ->
            [ optionGroupHtml
            , div
                [ onMouseEnter (DropdownMouseOverOption option.value)
                , onMouseLeave (DropdownMouseOutOption option.value)
                , onMouseDown (DropdownMouseClickOption option.value)
                , class "option"
                , css
                    [ backgroundColor (rgb 255 255 255)
                    , padding (px 5)
                    , cursor pointer
                    ]
                ]
                [ text (Option.optionLabelToString option.label), descriptionHtml ]
            ]

        OptionHidden ->
            [ optionGroupHtml, text "" ]

        OptionSelected ->
            case selectionMode of
                SingleSelect ->
                    [ optionGroupHtml
                    , div
                        [ class "selected"
                        , class "option"
                        , css
                            [ backgroundColor (hex "111111")
                            , color (hex "EEEEEE")
                            , padding (px 5)
                            , cursor pointer
                            ]
                        ]
                        [ text (Option.optionLabelToString option.label), descriptionHtml ]
                    ]

                MultiSelect ->
                    [ optionGroupHtml, text "" ]

        OptionHighlighted ->
            [ optionGroupHtml
            , div
                [ onMouseEnter (DropdownMouseOverOption option.value)
                , onMouseLeave (DropdownMouseOutOption option.value)
                , onMouseDown (DropdownMouseClickOption option.value)
                , class "highlighted"
                , class "option"
                , css
                    [ backgroundColor (hex "666666")
                    , color (hex "EEEEEE")
                    , padding (px 5)
                    , cursor pointer
                    ]
                ]
                [ text (Option.optionLabelToString option.label), descriptionHtml ]
            ]

        OptionDisabled ->
            [ optionGroupHtml
            , div
                [ class "disabled"
                , class "option"
                , css
                    [ backgroundColor (hex "666666")
                    , color (hex "EEEEEE")
                    , padding (px 5)
                    , cursor pointer
                    ]
                ]
                [ text (Option.optionLabelToString option.label), descriptionHtml ]
            ]


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

                            OptionDisabled ->
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
