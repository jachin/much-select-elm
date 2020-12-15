module Main exposing (..)

import Browser
import Css
    exposing
        ( block
        , display
        , hidden
        , none
        , px
        , visibility
        , visible
        , width
        )
import Html.Styled
    exposing
        ( Html
        , div
        , fromUnstyled
        , input
        , node
        , span
        , text
        , toUnstyled
        )
import Html.Styled.Attributes
    exposing
        ( class
        , classList
        , css
        , disabled
        , id
        , name
        , placeholder
        , tabindex
        , type_
        , value
        )
import Html.Styled.Events
    exposing
        ( onBlur
        , onClick
        , onFocus
        , onInput
        , onMouseEnter
        , onMouseLeave
        )
import Json.Decode
import Keyboard exposing (Key(..))
import Keyboard.Events as Keyboard
import List.Extra exposing (mapAccuml)
import Option
    exposing
        ( Option(..)
        , OptionDisplay(..)
        , OptionGroup
        , OptionLabel(..)
        , OptionValue
        , highlightOptionInListByValue
        , removeHighlightOptionInList
        , selectHighlightedOption
        , selectOptionInListByOptionValue
        , selectOptionsInOptionsListByString
        , selectSingleOptionInList
        , selectedOptionsToTuple
        )
import OptionPresentor exposing (OptionPresenter)
import OptionSearcher exposing (bestMatch)
import Ports
    exposing
        ( addOptionsReceiver
        , blurInput
        , deselectOptionReceiver
        , disableChangedReceiver
        , errorMessage
        , focusInput
        , loadingChangedReceiver
        , maxDropdownItemsChangedReceiver
        , optionsChangedReceiver
        , placeholderChangedReceiver
        , removeOptionsReceiver
        , selectBoxWidthChangedReceiver
        , selectOptionReceiver
        , valueChanged
        , valueChangedReceiver
        , valuesDecoder
        )
import SelectionMode exposing (SelectionMode(..))


type Msg
    = NoOp
    | BringInputInFocus
    | BringInputOutOfFocus
    | InputBlur
    | InputFocus
    | DropdownMouseOverOption OptionValue
    | DropdownMouseOutOption OptionValue
    | DropdownMouseClickOption OptionValue
    | SearchInputOnInput String
    | ValueChanged Json.Decode.Value
    | OptionsChanged Json.Decode.Value
    | AddOptions Json.Decode.Value
    | RemoveOptions Json.Decode.Value
    | SelectOption Json.Decode.Value
    | DeselectOption Json.Decode.Value
    | PlaceholderAttributeChanged String
    | LoadingAttributeChanged Bool
    | MaxDropdownItemsChanged Int
    | DisabledAttributeChanged Bool
    | SelectHighlightedOption
    | DeleteInputForSingleSelect
    | EscapeKeyInInputFilter
    | MoveHighlightedOptionUp
    | MoveHighlightedOptionDown
    | SelectBoxWidthUpdate Float


type alias Model =
    { initialValue : List String
    , placeholder : String
    , size : String
    , selectionMode : SelectionMode
    , options : List Option
    , showDropdown : Bool
    , searchString : String
    , loading : Bool
    , maxDropdownItems : Int
    , disabled : Bool
    , focused : Bool
    , selectBoxWidth : Float
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        BringInputInFocus ->
            ( { model | focused = True }, focusInput () )

        BringInputOutOfFocus ->
            ( { model | focused = False }, blurInput () )

        InputBlur ->
            ( { model | showDropdown = False, focused = False }, Cmd.none )

        InputFocus ->
            ( { model | showDropdown = True }, Cmd.none )

        DropdownMouseOverOption optionValue ->
            ( { model | options = highlightOptionInListByValue optionValue model.options }, Cmd.none )

        DropdownMouseOutOption optionValue ->
            ( { model | options = removeHighlightOptionInList optionValue model.options }, Cmd.none )

        DropdownMouseClickOption optionValue ->
            let
                options =
                    case model.selectionMode of
                        MultiSelect ->
                            selectOptionInListByOptionValue optionValue model.options

                        SingleSelect ->
                            selectSingleOptionInList optionValue model.options
            in
            ( { model | options = options }, Cmd.batch [ valueChanged (selectedOptionsToTuple options), blurInput () ] )

        SearchInputOnInput string ->
            case bestMatch string model.options of
                Just (Option _ _ value _ _) ->
                    ( { model | searchString = string, options = highlightOptionInListByValue value model.options }, Cmd.none )

                Just (EmptyOption _ _) ->
                    ( { model | searchString = string }, Cmd.none )

                Nothing ->
                    ( { model | searchString = string }, Cmd.none )

        ValueChanged valuesJson ->
            let
                valuesResult =
                    Json.Decode.decodeValue valuesDecoder valuesJson
            in
            case valuesResult of
                Ok values ->
                    ( { model | options = selectOptionsInOptionsListByString values model.options }, Cmd.none )

                Err error ->
                    ( model, errorMessage (Json.Decode.errorToString error) )

        OptionsChanged optionsJson ->
            case Json.Decode.decodeValue Option.optionsDecoder optionsJson of
                Ok newOptions ->
                    let
                        newOptionWithOldSelectedOption =
                            Option.mergeTwoListsOfOptionsPreservingSelectedOptions model.options newOptions

                        -- TODO if there is an option selected that is not in this list
                        --       of options add the selected option to the list options.
                    in
                    ( { model | options = newOptionWithOldSelectedOption }, Cmd.none )

                Err error ->
                    ( model, errorMessage (Json.Decode.errorToString error) )

        AddOptions optionsJson ->
            case Json.Decode.decodeValue Option.optionsDecoder optionsJson of
                Ok newOptions ->
                    ( { model | options = Option.addAdditionalOptionsToOptionList model.options newOptions }, Cmd.none )

                Err error ->
                    ( model, errorMessage (Json.Decode.errorToString error) )

        RemoveOptions optionsJson ->
            case Json.Decode.decodeValue Option.optionsDecoder optionsJson of
                Ok optionsToRemove ->
                    ( { model | options = Option.removeOptionsFromOptionList model.options optionsToRemove }, Cmd.none )

                Err error ->
                    ( model, errorMessage (Json.Decode.errorToString error) )

        SelectOption optionJson ->
            case Json.Decode.decodeValue Option.decoder optionJson of
                Ok option ->
                    let
                        optionValue =
                            Option.getOptionValue option

                        options =
                            case model.selectionMode of
                                MultiSelect ->
                                    selectOptionInListByOptionValue optionValue model.options

                                SingleSelect ->
                                    selectSingleOptionInList optionValue model.options
                    in
                    ( { model | options = options }, Cmd.batch [ valueChanged (selectedOptionsToTuple options) ] )

                Err error ->
                    ( model, errorMessage (Json.Decode.errorToString error) )

        DeselectOption optionJson ->
            case Json.Decode.decodeValue Option.decoder optionJson of
                Ok option ->
                    let
                        optionValue =
                            Option.getOptionValue option

                        options =
                            Option.deselectOptionInListByOptionValue optionValue model.options
                    in
                    ( { model | options = options }, Cmd.batch [ valueChanged (selectedOptionsToTuple options) ] )

                Err error ->
                    ( model, errorMessage (Json.Decode.errorToString error) )

        PlaceholderAttributeChanged newPlaceholder ->
            ( { model | placeholder = newPlaceholder }, Cmd.none )

        LoadingAttributeChanged bool ->
            ( { model | loading = bool }, Cmd.none )

        MaxDropdownItemsChanged int ->
            ( { model | maxDropdownItems = int }, Cmd.none )

        DisabledAttributeChanged bool ->
            ( { model | disabled = bool }, Cmd.none )

        SelectHighlightedOption ->
            let
                options =
                    selectHighlightedOption model.selectionMode model.options
            in
            case model.selectionMode of
                SingleSelect ->
                    ( { model | options = options, searchString = "" }
                    , Cmd.batch
                        [ valueChanged (selectedOptionsToTuple options)
                        , blurInput ()
                        ]
                    )

                MultiSelect ->
                    ( { model | options = options, searchString = "" }, valueChanged (selectedOptionsToTuple options) )

        DeleteInputForSingleSelect ->
            case model.selectionMode of
                SingleSelect ->
                    if Option.hasSelectedOption model.options then
                        ( { model
                            | options = Option.deselectAllOptionsInOptionsList model.options
                            , searchString = ""
                          }
                        , Cmd.none
                        )

                    else
                        ( model, Cmd.none )

                MultiSelect ->
                    ( model, Cmd.none )

        EscapeKeyInInputFilter ->
            ( { model | searchString = "" }, blurInput () )

        MoveHighlightedOptionUp ->
            ( { model | options = Option.moveHighlightedOptionUp model.options }, Cmd.none )

        MoveHighlightedOptionDown ->
            ( { model | options = Option.moveHighlightedOptionDown model.options }, Cmd.none )

        SelectBoxWidthUpdate width ->
            ( { model | selectBoxWidth = width }, Cmd.none )


view : Model -> Html Msg
view model =
    case model.selectionMode of
        SingleSelect ->
            let
                hasOptionSelected =
                    Option.hasSelectedOption model.options

                hasOptions =
                    List.isEmpty model.options |> not

                valueStr =
                    if hasOptionSelected then
                        model.options
                            |> Option.selectedOptionsToTuple
                            |> List.map Tuple.second
                            |> List.head
                            |> Maybe.withDefault ""

                    else if model.focused then
                        model.searchString

                    else
                        model.placeholder
            in
            div [ id "wrapper", css [ width (px model.selectBoxWidth) ] ]
                [ div
                    [ id "select-box"
                    , onClick BringInputInFocus
                    , onFocus BringInputInFocus
                    , tabindex 0
                    , classList
                        [ ( "placeholder", not hasOptionSelected )
                        , ( "value", hasOptionSelected )
                        , ( "single", True )
                        , ( "disabled", model.disabled )
                        ]
                    , css
                        [ if model.focused then
                            display none

                          else
                            display block
                        , width (px model.selectBoxWidth)
                        ]
                    ]
                    [ if hasOptionSelected then
                        span [ class "value" ] [ text valueStr ]

                      else
                        span [ class "placeholder" ] [ text model.placeholder ]
                    ]
                , input
                    [ type_ "text"
                    , onBlur InputBlur
                    , onFocus InputFocus
                    , onInput SearchInputOnInput
                    , value valueStr
                    , placeholder model.placeholder
                    , id "input-filter"
                    , disabled model.disabled
                    , css
                        [ if model.focused then
                            visibility visible

                          else
                            visibility hidden
                        , width (px model.selectBoxWidth)
                        ]
                    , Keyboard.on Keyboard.Keydown
                        [ ( Enter, SelectHighlightedOption )
                        , ( Backspace, DeleteInputForSingleSelect )
                        , ( Escape, EscapeKeyInInputFilter )
                        , ( ArrowUp, MoveHighlightedOptionUp )
                        , ( ArrowDown, MoveHighlightedOptionDown )
                        ]
                        |> Html.Styled.Attributes.fromUnstyled
                    ]
                    []
                , if model.loading then
                    node "slot" [ name "loading-indicator" ] []

                  else
                    text ""
                , dropdownIndicator model.focused model.disabled hasOptions
                , dropdown model
                ]

        MultiSelect ->
            let
                hasOptionSelected =
                    Option.hasSelectedOption model.options
            in
            div [ id "wrapper", classList [ ( "disabled", model.disabled ) ] ]
                [ div
                    [ id "select-box"
                    , onClick BringInputInFocus
                    , onFocus BringInputInFocus
                    , tabindex 0
                    , classList
                        [ ( "placeholder", not hasOptionSelected )
                        , ( "mulit", True )
                        , ( "disabled", model.disabled )
                        ]
                    , css
                        [ if model.focused then
                            display none

                          else
                            display block
                        , width (px model.selectBoxWidth)
                        ]
                    ]
                    [ if hasOptionSelected then
                        div [ id "values" ] (optionsToValuesHtml model.options)

                      else
                        span [ class "placeholder" ] [ text model.placeholder ]
                    ]
                , input
                    [ type_ "text"
                    , onBlur InputBlur
                    , onFocus InputFocus
                    , onInput SearchInputOnInput
                    , value model.searchString
                    , placeholder model.placeholder
                    , id "input-filter"
                    , disabled model.disabled
                    , css
                        [ if model.focused then
                            visibility visible

                          else
                            visibility hidden
                        , width (px model.selectBoxWidth)
                        ]
                    , Keyboard.on Keyboard.Keydown
                        [ ( Enter, SelectHighlightedOption )
                        , ( Escape, EscapeKeyInInputFilter )
                        , ( ArrowUp, MoveHighlightedOptionUp )
                        , ( ArrowDown, MoveHighlightedOptionDown )
                        ]
                        |> Html.Styled.Attributes.fromUnstyled
                    ]
                    []
                , dropdown model
                ]


dropdownIndicator : Bool -> Bool -> Bool -> Html Msg
dropdownIndicator focused disabled hasOptions =
    if disabled || not hasOptions then
        text ""

    else if focused then
        div
            [ id "select-indicator"
            , mousedownPreventDefaultAndStopPropagation BringInputOutOfFocus
            , class "down"
            ]
            [ text "🔽" ]

    else
        div
            [ id "select-indicator"
            , mousedownPreventDefaultAndStopPropagation BringInputInFocus
            , class "up"
            ]
            [ text "🔼" ]


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
    if model.showDropdown && not (List.isEmpty model.options) then
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
            optionToDropdownOption
                mouseOverMsgConstructor
                mouseOutMsgConstructor
                clickMsgConstructor
                selectionMode

        helper : OptionGroup -> OptionPresenter msg -> ( OptionGroup, List (Html msg) )
        helper previousGroup option_ =
            ( option_.group
            , option_ |> partialWithSelectionMode (previousGroup /= option_.group)
            )
    in
    options
        |> mapAccuml helper Option.emptyOptionGroup
        |> Tuple.second
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
                    [ span [ class "optgroup-header" ] [ text (Option.optionGroupToString option.group) ] ]

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
                , mousedownPreventDefaultAndStopPropagation (clickMsgConstructor option.value)
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
                , mousedownPreventDefaultAndStopPropagation (clickMsgConstructor option.value)
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

                    EmptyOption display (OptionLabel labelStr) ->
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
    , maxDropdownItems : Int
    , disabled : Bool
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        selectionMode =
            if flags.allowMultiSelect then
                MultiSelect

            else
                SingleSelect

        initialValues : List String
        initialValues =
            case selectionMode of
                SingleSelect ->
                    [ flags.value ]

                MultiSelect ->
                    String.split "," flags.value

        ( optionsWithInitialValueSelected, errorCmd ) =
            case Json.Decode.decodeString Option.optionsDecoder flags.optionsJson of
                Ok options ->
                    case selectionMode of
                        SingleSelect ->
                            case List.head initialValues of
                                Just initialValueStr ->
                                    if Option.isOptionInListOfOptionsByValue (Option.stringToOptionValue initialValueStr) options then
                                        ( Option.selectOptionsInOptionsListByString initialValues options, Cmd.none )

                                    else
                                        ( (Option.newOption initialValueStr |> Option.selectOption) :: options, Cmd.none )

                                Nothing ->
                                    ( options, Cmd.none )

                        MultiSelect ->
                            let
                                optionsWithInitialValues =
                                    Option.addAndSelectOptionsInOptionsListByString initialValues options
                            in
                            ( optionsWithInitialValues, Cmd.none )

                Err error ->
                    ( [], errorMessage (Json.Decode.errorToString error) )
    in
    ( { initialValue = initialValues
      , placeholder = flags.placeholder
      , size = flags.size
      , selectionMode = selectionMode
      , options = optionsWithInitialValueSelected
      , showDropdown = False
      , searchString = ""
      , loading = flags.loading
      , maxDropdownItems = flags.maxDropdownItems
      , disabled = flags.disabled
      , focused = False
      , selectBoxWidth = 100
      }
    , errorCmd
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
        , addOptionsReceiver AddOptions
        , removeOptionsReceiver RemoveOptions
        , placeholderChangedReceiver PlaceholderAttributeChanged
        , loadingChangedReceiver LoadingAttributeChanged
        , disableChangedReceiver DisabledAttributeChanged
        , optionsChangedReceiver OptionsChanged
        , maxDropdownItemsChangedReceiver MaxDropdownItemsChanged
        , selectBoxWidthChangedReceiver SelectBoxWidthUpdate
        , selectOptionReceiver SelectOption
        , deselectOptionReceiver DeselectOption
        ]


mousedownPreventDefaultAndStopPropagation : a -> Html.Styled.Attribute a
mousedownPreventDefaultAndStopPropagation message =
    Html.Styled.Events.custom "mousedown"
        (Json.Decode.succeed
            { message = message
            , stopPropagation = True
            , preventDefault = True
            }
        )
