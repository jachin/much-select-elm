module Main exposing (..)

import Browser
import Css
    exposing
        ( position
        , relative
        )
import Html.Parser
import Html.Parser.Util
import Html.Styled exposing (Html, div, fromUnstyled, input, text, toUnstyled)
import Html.Styled.Attributes exposing (class, css, disabled, id, placeholder, type_, value)
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
    , loadingIndicatorHtml : List (Html Msg)
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
            , id "input-filter"
            , disabled model.disabled
            ]
            []
        , if model.loading then
            div [ id "loading-indicator" ] model.loadingIndicatorHtml

          else
            text ""
        , dropdown model
        ]


dropdown : Model -> Html Msg
dropdown model =
    let
        options =
            optionsToDropdownOptions
                DropdownMouseOverOption
                DropdownMouseOutOption
                DropdownMouseClickOption
                model.selectionMode
                (OptionPresentor.prepareOptionsForPresentation model.searchString model.options)
    in
    if model.showDropdown then
        div
            [ id "dropdown"
            , class "showing"
            ]
            options

    else
        div [ id "dropdown", class "hiding" ] options


optionsToDropdownOptions :
    (OptionValue -> msg)
    -> (OptionValue -> msg)
    -> (OptionValue -> msg)
    -> SelectionMode
    -> List (OptionPresenter msg)
    -> List (Html msg)
optionsToDropdownOptions mouseOverMsgConstructor mouseOutMsgConstructor clickMsgConstructor selectionMode options =
    let
        partialWithSelectionMode =
            optionToDropdownOption mouseOverMsgConstructor mouseOutMsgConstructor clickMsgConstructor selectionMode

        helper : OptionGroup -> List (OptionPresenter msg) -> List (OptionPresenter msg -> List (Html msg))
        helper previousGroup options_ =
            case List.head options_ of
                Just option_ ->
                    let
                        partial_ =
                            if previousGroup == option_.group then
                                partialWithSelectionMode False

                            else
                                partialWithSelectionMode True
                    in
                    List.append [ partial_ ] (helper option_.group (options_ |> List.tail |> Maybe.withDefault []))

                Nothing ->
                    []

        partialsWithGroupChangesFlagged : List (OptionPresenter msg -> List (Html msg))
        partialsWithGroupChangesFlagged =
            helper Option.emptyOptionGroup options
    in
    List.map2
        (\option partial ->
            partial option
        )
        options
        partialsWithGroupChangesFlagged
        |> List.concat


optionToDropdownOption :
    (OptionValue -> msg)
    -> (OptionValue -> msg)
    -> (OptionValue -> msg)
    -> SelectionMode
    -> Bool
    -> OptionPresenter msg
    -> List (Html msg)
optionToDropdownOption mouseOverMsgConstructor mouseOutMsgConstructor clickMsgConstructor selectionMode prependOptionGroup option =
    let
        optionGroupHtml =
            if prependOptionGroup then
                div
                    [ class "optgroup"
                    ]
                    [ text (Option.optionGroupToString option.group) ]

            else
                text ""

        descriptionHtml : Html msg
        descriptionHtml =
            if OptionPresentor.hasDescription option then
                div
                    [ class "description"
                    ]
                    [ fromUnstyled option.descriptionMarkup ]

            else
                text ""
    in
    case option.display of
        OptionShown ->
            [ optionGroupHtml
            , div
                [ onMouseEnter (mouseOverMsgConstructor option.value)
                , onMouseLeave (mouseOutMsgConstructor option.value)
                , onMouseDown (clickMsgConstructor option.value)
                , class "option"
                ]
                [ fromUnstyled option.labelMarkup, descriptionHtml ]
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
                        ]
                        [ fromUnstyled option.labelMarkup, descriptionHtml ]
                    ]

                MultiSelect ->
                    [ optionGroupHtml, text "" ]

        OptionHighlighted ->
            [ optionGroupHtml
            , div
                [ onMouseEnter (mouseOverMsgConstructor option.value)
                , onMouseLeave (mouseOutMsgConstructor option.value)
                , onMouseDown (clickMsgConstructor option.value)
                , class "highlighted"
                , class "option"
                ]
                [ fromUnstyled option.labelMarkup, descriptionHtml ]
            ]

        OptionDisabled ->
            [ optionGroupHtml
            , div
                [ class "disabled"
                , class "option"
                ]
                [ fromUnstyled option.labelMarkup, descriptionHtml ]
            ]


optionsToValuesHtml : List Option -> List (Html msg)
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
    , loadingIndicatorHtml : String
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
      , loadingIndicatorHtml = textHtml flags.loadingIndicatorHtml
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


textHtml : String -> List (Html msg)
textHtml t =
    case Html.Parser.run t of
        Ok nodes ->
            Html.Parser.Util.toVirtualDom nodes
                |> List.map fromUnstyled

        Err _ ->
            []
