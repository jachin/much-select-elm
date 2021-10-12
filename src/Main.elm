module Main exposing (..)

import Browser
import Html
    exposing
        ( Html
        , div
        , input
        , node
        , span
        , text
        )
import Html.Attributes
    exposing
        ( class
        , classList
        , disabled
        , id
        , maxlength
        , name
        , placeholder
        , style
        , tabindex
        , type_
        , value
        )
import Html.Events
    exposing
        ( onBlur
        , onClick
        , onFocus
        , onInput
        , onMouseDown
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
        , OptionValue
        , highlightOptionInListByValue
        , removeHighlightOptionInList
        , selectHighlightedOption
        , selectOptionInListByOptionValue
        , selectSingleOptionInList
        , selectedOptionsToTuple
        )
import OptionLabel exposing (OptionLabel(..), optionLabelToString)
import OptionPresentor exposing (tokensToHtml)
import OptionSearcher
import Ports
    exposing
        ( addOptionsReceiver
        , allowCustomOptionsReceiver
        , blurInput
        , customOptionSelected
        , deselectOptionReceiver
        , disableChangedReceiver
        , errorMessage
        , focusInput
        , inputKeyUp
        , loadingChangedReceiver
        , maxDropdownItemsChangedReceiver
        , muchSelectIsReady
        , optionDeselected
        , optionSelected
        , optionsChangedReceiver
        , placeholderChangedReceiver
        , removeOptionsReceiver
        , scrollDropdownToElement
        , selectOptionReceiver
        , selectedItemStaysInPlaceChangedReceiver
        , valueCasingDimensionsChangedReceiver
        , valueChanged
        , valueChangedReceiver
        , valueCleared
        , valuesDecoder
        )
import PositiveInt exposing (PositiveInt)
import SelectionMode
    exposing
        ( CustomOptions(..)
        , SelectedItemPlacementMode(..)
        , SelectionMode(..)
        )


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
    | AllowCustomOptionsChanged Bool
    | DisabledAttributeChanged Bool
    | SelectedItemStaysInPlaceChanged Bool
    | SelectHighlightedOption
    | DeleteInputForSingleSelect
    | EscapeKeyInInputFilter
    | MoveHighlightedOptionUp
    | MoveHighlightedOptionDown
    | ValueCasingWidthUpdate { width : Float, height : Float }
    | ClearAllSelectedOptions
      -- SelectedValueHighlight?!? WTF? Yes, this is because in multi selected
      --  mode a user can 'highlight' any number of the selected values by clicking
      --  on them and then delete them (with the delete key).
      --  If you can think of a better name we're all ears.
    | ToggleSelectedValueHighlight OptionValue
    | DeleteKeydownForMultiSelect


type alias Model =
    { initialValue : List String
    , placeholder : String
    , size : String
    , selectionMode : SelectionMode
    , options : List Option
    , optionsForTheDropdown : List Option
    , showDropdown : Bool
    , searchString : String
    , rightSlot : RightSlot
    , maxDropdownItems : PositiveInt
    , disabled : Bool
    , focused : Bool
    , valueCasingWidth : Float
    , valueCasingHeight : Float
    , deleteKeyPressed : Bool
    }


type RightSlot
    = ShowNothing
    | ShowLoadingIndicator
    | ShowDropdownIndicator
    | ShowClearButton


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        BringInputInFocus ->
            if model.focused then
                ( model, Cmd.none )

            else
                ( { model | focused = True }, focusInput () )

        BringInputOutOfFocus ->
            if model.focused then
                ( { model | focused = False }, blurInput () )

            else
                ( model, Cmd.none )

        InputBlur ->
            ( { model | showDropdown = False, focused = False, searchString = "" }, Cmd.none )

        InputFocus ->
            ( { model | showDropdown = True }, Cmd.none )

        DropdownMouseOverOption optionValue ->
            let
                updateOptions =
                    highlightOptionInListByValue optionValue model.options

                optionsForTheDropdown =
                    highlightOptionInListByValue optionValue model.optionsForTheDropdown
            in
            ( { model
                | options = updateOptions
                , optionsForTheDropdown = optionsForTheDropdown
              }
            , Cmd.none
            )

        DropdownMouseOutOption optionValue ->
            let
                updatedOptions =
                    removeHighlightOptionInList optionValue model.options

                optionsForTheDropdown =
                    removeHighlightOptionInList optionValue model.optionsForTheDropdown
            in
            ( { model
                | options = updatedOptions
                , optionsForTheDropdown = optionsForTheDropdown
              }
            , Cmd.none
            )

        DropdownMouseClickOption optionValue ->
            let
                options =
                    case model.selectionMode of
                        MultiSelect _ ->
                            selectOptionInListByOptionValue optionValue model.options

                        SingleSelect _ _ ->
                            selectSingleOptionInList optionValue model.options
            in
            ( updateModelWithSearchStringChanges model.maxDropdownItems "" options model
            , Cmd.batch
                [ makeCommandMessagesWhenValuesChanges options (Just optionValue)
                , blurInput ()
                ]
            )

        SearchInputOnInput searchString ->
            ( updateModelWithSearchStringChanges model.maxDropdownItems searchString model.options model
            , inputKeyUp searchString
            )

        ValueChanged valuesJson ->
            let
                valuesResult =
                    Json.Decode.decodeValue valuesDecoder valuesJson
            in
            case valuesResult of
                Ok values ->
                    let
                        newOptions =
                            Option.addAndSelectOptionsInOptionsListByString
                                (SelectionMode.getSelectedItemPlacementMode model.selectionMode)
                                values
                                model.options
                    in
                    ( { model
                        | options = newOptions
                        , optionsForTheDropdown = figureOutWhichOptionsToShow model.maxDropdownItems newOptions
                        , rightSlot =
                            updateRightSlot
                                model.rightSlot
                                model.selectionMode
                                (Option.hasSelectedOption model.options)
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( model, errorMessage (Json.Decode.errorToString error) )

        OptionsChanged optionsJson ->
            case Json.Decode.decodeValue Option.optionsDecoder optionsJson of
                Ok newOptions ->
                    let
                        newOptionWithOldSelectedOption =
                            case model.selectionMode of
                                SingleSelect _ selectedItemPlacementMode ->
                                    Option.mergeTwoListsOfOptionsPreservingSelectedOptions selectedItemPlacementMode model.options newOptions

                                MultiSelect _ ->
                                    -- Also filter out any empty options.
                                    newOptions
                                        |> List.filter (not << Option.isEmptyOption)
                                        |> Option.mergeTwoListsOfOptionsPreservingSelectedOptions SelectedItemStaysInPlace model.options
                    in
                    ( { model
                        | options = newOptionWithOldSelectedOption
                        , optionsForTheDropdown = figureOutWhichOptionsToShow model.maxDropdownItems newOptionWithOldSelectedOption
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( model, errorMessage (Json.Decode.errorToString error) )

        AddOptions optionsJson ->
            case Json.Decode.decodeValue Option.optionsDecoder optionsJson of
                Ok newOptions ->
                    let
                        updatedOptions =
                            Option.addAdditionalOptionsToOptionList model.options newOptions
                    in
                    ( { model
                        | options = updatedOptions
                        , optionsForTheDropdown = figureOutWhichOptionsToShow model.maxDropdownItems updatedOptions
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( model, errorMessage (Json.Decode.errorToString error) )

        RemoveOptions optionsJson ->
            case Json.Decode.decodeValue Option.optionsDecoder optionsJson of
                Ok optionsToRemove ->
                    let
                        updatedOptions =
                            Option.removeOptionsFromOptionList model.options optionsToRemove
                    in
                    ( { model
                        | options = updatedOptions
                        , optionsForTheDropdown = figureOutWhichOptionsToShow model.maxDropdownItems updatedOptions
                      }
                    , Cmd.none
                    )

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
                                MultiSelect _ ->
                                    selectOptionInListByOptionValue optionValue model.options

                                SingleSelect _ _ ->
                                    selectSingleOptionInList optionValue model.options
                    in
                    ( updateModelWithSearchStringChanges model.maxDropdownItems "" options model
                    , makeCommandMessagesWhenValuesChanges options (Just optionValue)
                    )

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
                    ( { model
                        | options = options
                        , optionsForTheDropdown = figureOutWhichOptionsToShow model.maxDropdownItems options
                      }
                    , makeCommandMessagesWhenValuesChanges options Nothing
                    )

                Err error ->
                    ( model, errorMessage (Json.Decode.errorToString error) )

        PlaceholderAttributeChanged newPlaceholder ->
            ( { model | placeholder = newPlaceholder }, Cmd.none )

        LoadingAttributeChanged bool ->
            ( { model
                | rightSlot =
                    updateRightSlotLoading
                        bool
                        model.selectionMode
                        (Option.hasSelectedOption model.options)
              }
            , Cmd.none
            )

        MaxDropdownItemsChanged int ->
            let
                maxDropdownItems =
                    PositiveInt.new int
            in
            ( { model
                | maxDropdownItems = maxDropdownItems
                , optionsForTheDropdown = figureOutWhichOptionsToShow maxDropdownItems model.options
              }
            , Cmd.none
            )

        AllowCustomOptionsChanged canAddCustomOptions ->
            ( { model | selectionMode = SelectionMode.setAllowCustomOptionsWithBool canAddCustomOptions model.selectionMode }
            , Cmd.none
            )

        DisabledAttributeChanged bool ->
            ( { model | disabled = bool }, Cmd.none )

        SelectedItemStaysInPlaceChanged selectedItemStaysInPlace ->
            ( { model
                | selectionMode =
                    SelectionMode.setSelectedItemStaysInPlace
                        selectedItemStaysInPlace
                        model.selectionMode
              }
            , Cmd.none
            )

        SelectHighlightedOption ->
            let
                options =
                    selectHighlightedOption model.selectionMode model.options
            in
            case model.selectionMode of
                SingleSelect _ _ ->
                    ( updateModelWithSearchStringChanges model.maxDropdownItems "" options model
                    , Cmd.batch
                        -- TODO Figure out what the highlighted option in here
                        [ makeCommandMessagesWhenValuesChanges options Nothing
                        , blurInput ()
                        ]
                    )

                MultiSelect _ ->
                    ( { model | options = options, searchString = "" }
                      -- TODO Figure out what the highlighted option in here
                    , makeCommandMessagesWhenValuesChanges options Nothing
                    )

        DeleteInputForSingleSelect ->
            case model.selectionMode of
                SingleSelect _ _ ->
                    if Option.hasSelectedOption model.options then
                        -- if there are ANY selected options, clear them all;
                        clearAllSelectedOption model

                    else
                        ( model, Cmd.none )

                MultiSelect _ ->
                    ( model, Cmd.none )

        EscapeKeyInInputFilter ->
            ( updateModelWithSearchStringChanges model.maxDropdownItems "" model.options model, blurInput () )

        MoveHighlightedOptionUp ->
            let
                updatedOptions =
                    Option.moveHighlightedOptionUp model.options
            in
            ( { model
                | options = Option.moveHighlightedOptionUp model.options
                , optionsForTheDropdown = figureOutWhichOptionsToShow model.maxDropdownItems updatedOptions
              }
            , scrollDropdownToElement "something"
            )

        MoveHighlightedOptionDown ->
            let
                updatedOptions =
                    Option.moveHighlightedOptionDown model.options
            in
            ( { model
                | options = updatedOptions
                , optionsForTheDropdown = figureOutWhichOptionsToShow model.maxDropdownItems updatedOptions
              }
            , scrollDropdownToElement "something"
            )

        ValueCasingWidthUpdate dims ->
            ( { model | valueCasingWidth = dims.width, valueCasingHeight = dims.height }, Cmd.none )

        ClearAllSelectedOptions ->
            clearAllSelectedOption model

        ToggleSelectedValueHighlight _ ->
            let
                updatedOptions =
                    Option.moveHighlightedOptionDown model.options
            in
            ( { model
                | options = updatedOptions
                , optionsForTheDropdown = figureOutWhichOptionsToShow model.maxDropdownItems updatedOptions
              }
            , Cmd.none
            )

        DeleteKeydownForMultiSelect ->
            let
                newOptions =
                    Option.deselectAllSelectedHighlightedOptions model.options
            in
            ( { model
                | options = newOptions
                , optionsForTheDropdown = figureOutWhichOptionsToShow model.maxDropdownItems newOptions
              }
            , valueChanged (selectedOptionsToTuple newOptions)
            )


clearAllSelectedOption : Model -> ( Model, Cmd Msg )
clearAllSelectedOption model =
    let
        deselectedItems =
            if List.isEmpty <| Option.selectedOptionsToTuple model.options then
                -- no deselected options
                []

            else
                -- an option has been deselected. return the deselected value as a tuple.
                Option.selectedOptionsToTuple model.options

        deselectEventMsg =
            if List.isEmpty deselectedItems then
                Cmd.none

            else
                optionDeselected deselectedItems

        newOptions =
            Option.deselectAllOptionsInOptionsList model.options
    in
    ( { model
        | options = Option.deselectAllOptionsInOptionsList newOptions
        , optionsForTheDropdown = figureOutWhichOptionsToShow model.maxDropdownItems newOptions
        , rightSlot = ShowNothing
        , searchString = ""
      }
    , Cmd.batch
        [ makeCommandMessagesWhenValuesChanges [] Nothing
        , deselectEventMsg
        ]
    )


updateModelWithSearchStringChanges : PositiveInt -> String -> List Option -> Model -> Model
updateModelWithSearchStringChanges maxNumberOfDropdownItems searchString options model =
    let
        optionsUpdatedWithSearchString =
            OptionSearcher.updateOptions model.selectionMode searchString options
    in
    case searchString of
        "" ->
            let
                updatedOptions =
                    OptionSearcher.updateOptions model.selectionMode searchString options
                        |> Option.sortOptionsByGroupAndLabel
            in
            { model
                | searchString = searchString
                , options = updatedOptions
                , optionsForTheDropdown = figureOutWhichOptionsToShow maxNumberOfDropdownItems updatedOptions
            }

        _ ->
            let
                optionsSortedByTotalScore =
                    optionsUpdatedWithSearchString
                        |> Option.sortOptionsByTotalScore

                maybeFirstOption =
                    List.head optionsSortedByTotalScore

                optionsSortedByTotalScoreWithTheFirstOptionHighlighted =
                    case maybeFirstOption of
                        Just firstOption ->
                            Option.highlightOptionInList firstOption optionsSortedByTotalScore

                        Nothing ->
                            optionsSortedByTotalScore
            in
            { model
                | searchString = searchString
                , options = optionsSortedByTotalScoreWithTheFirstOptionHighlighted
                , optionsForTheDropdown =
                    figureOutWhichOptionsToShow
                        maxNumberOfDropdownItems
                        optionsSortedByTotalScoreWithTheFirstOptionHighlighted
            }


figureOutWhichOptionsToShow : PositiveInt -> List Option -> List Option
figureOutWhichOptionsToShow maxDropdownItems options =
    let
        optionsThatCouldBeShown =
            Option.filterOptionsToShowInDropdown options

        lastIndexOfOptions =
            List.length optionsThatCouldBeShown - 1

        maxNumberOfDropdownItems =
            PositiveInt.toInt maxDropdownItems
    in
    if List.length optionsThatCouldBeShown <= maxNumberOfDropdownItems then
        optionsThatCouldBeShown

    else
        case Option.findHighlightedOrSelectedOptionIndex optionsThatCouldBeShown of
            Just index ->
                case index of
                    0 ->
                        List.take maxNumberOfDropdownItems optionsThatCouldBeShown

                    _ ->
                        if index == List.length optionsThatCouldBeShown - 1 then
                            List.drop (List.length options - maxNumberOfDropdownItems) optionsThatCouldBeShown

                        else
                            let
                                isEven =
                                    modBy 2 maxNumberOfDropdownItems
                                        == 0

                                half =
                                    if isEven then
                                        maxNumberOfDropdownItems // 2

                                    else
                                        (maxNumberOfDropdownItems // 2) + 1
                            in
                            if index + half > lastIndexOfOptions then
                                -- The "window" runs off the "tail" of the list, so just take the last options
                                List.drop (List.length options - maxNumberOfDropdownItems) optionsThatCouldBeShown

                            else if index - half < 0 then
                                -- The "window" runs off the "head" of the list, so just take the first options
                                List.take maxNumberOfDropdownItems optionsThatCouldBeShown

                            else
                                options |> List.drop (index + 1 - half) |> List.take maxNumberOfDropdownItems

            Nothing ->
                List.take maxNumberOfDropdownItems options


updateRightSlot : RightSlot -> SelectionMode -> Bool -> RightSlot
updateRightSlot current selectionMode hasSelectedOption =
    case current of
        ShowNothing ->
            case selectionMode of
                SingleSelect _ _ ->
                    ShowDropdownIndicator

                MultiSelect _ ->
                    if hasSelectedOption then
                        ShowClearButton

                    else
                        ShowNothing

        ShowLoadingIndicator ->
            ShowLoadingIndicator

        ShowDropdownIndicator ->
            ShowDropdownIndicator

        ShowClearButton ->
            if hasSelectedOption then
                ShowClearButton

            else
                ShowNothing


updateRightSlotLoading : Bool -> SelectionMode -> Bool -> RightSlot
updateRightSlotLoading isLoading selectionMode hasSelectedOption =
    if isLoading then
        ShowLoadingIndicator

    else
        case selectionMode of
            SingleSelect _ _ ->
                ShowDropdownIndicator

            MultiSelect _ ->
                if hasSelectedOption then
                    ShowClearButton

                else
                    ShowNothing


view : Model -> Html Msg
view model =
    let
        tabIndexAttribute =
            if model.disabled then
                style "" ""

            else
                tabindex 0
    in
    case model.selectionMode of
        SingleSelect _ _ ->
            let
                hasOptionSelected =
                    Option.hasSelectedOption model.options

                showPlaceholder =
                    not hasOptionSelected && not model.focused

                hasOptions =
                    (List.isEmpty model.options |> not) && String.isEmpty model.searchString

                valueStr =
                    if hasOptionSelected then
                        model.options
                            |> Option.selectedOptionsToTuple
                            |> List.map Tuple.second
                            |> List.head
                            |> Maybe.withDefault ""

                    else
                        ""
            in
            div [ id "wrapper" ]
                [ div
                    [ id "value-casing"
                    , onMouseDown BringInputInFocus
                    , onFocus BringInputInFocus
                    , tabIndexAttribute
                    , classList
                        [ ( "show-placeholder", showPlaceholder )
                        , ( "has-option-selected", hasOptionSelected )
                        , ( "no-option-selected", not hasOptionSelected )
                        , ( "single", True )
                        , ( "disabled", model.disabled )
                        , ( "focused", model.focused )
                        , ( "not-focused", model.focused )
                        ]
                    ]
                    [ span
                        [ id "selected-value" ]
                        [ text valueStr ]
                    , singleSelectInputField
                        model.searchString
                        model.disabled
                        model.focused
                        model.placeholder
                        hasOptionSelected
                    , case model.rightSlot of
                        ShowNothing ->
                            text ""

                        ShowLoadingIndicator ->
                            node "slot" [ name "loading-indicator" ] [ defaultLoadingIndicator ]

                        ShowDropdownIndicator ->
                            dropdownIndicator model.focused model.disabled hasOptions

                        ShowClearButton ->
                            node "slot" [ name "clear-button" ] []
                    , dropdown model
                    ]
                ]

        MultiSelect _ ->
            let
                hasOptionSelected =
                    Option.hasSelectedOption model.options

                showPlaceholder =
                    not hasOptionSelected && not model.focused

                inputFilter =
                    input
                        [ type_ "text"
                        , onBlur InputBlur
                        , onFocus InputFocus
                        , onInput SearchInputOnInput
                        , value model.searchString
                        , id "input-filter"
                        , disabled model.disabled
                        , Keyboard.on Keyboard.Keydown
                            [ ( Enter, SelectHighlightedOption )
                            , ( Escape, EscapeKeyInInputFilter )
                            , ( ArrowUp, MoveHighlightedOptionUp )
                            , ( ArrowDown, MoveHighlightedOptionDown )
                            ]
                        ]
                        []
            in
            div [ id "wrapper", classList [ ( "disabled", model.disabled ) ] ]
                [ div
                    [ id "value-casing"
                    , onClick BringInputInFocus
                    , onFocus BringInputInFocus
                    , Keyboard.on Keyboard.Keydown
                        [ ( Delete, DeleteKeydownForMultiSelect )
                        , ( Backspace, DeleteKeydownForMultiSelect )
                        ]
                    , tabIndexAttribute
                    , classList
                        [ ( "placeholder", showPlaceholder )
                        , ( "multi", True )
                        , ( "disabled", model.disabled )
                        ]
                    ]
                    ([ span
                        [ class "placeholder"
                        ]
                        [ text model.placeholder ]
                     ]
                        ++ optionsToValuesHtml model.options
                        ++ [ inputFilter
                           , rightSlotHtml model.rightSlot model.focused model.disabled hasOptionSelected
                           ]
                    )
                , dropdown model
                ]


singleSelectInputField : String -> Bool -> Bool -> String -> Bool -> Html Msg
singleSelectInputField searchString isDisabled focused placeholder_ hasSelectedOptions =
    let
        keyboardEvents =
            Keyboard.customPerKey Keyboard.Keydown
                [ ( Enter
                  , { message = SelectHighlightedOption
                    , preventDefault = False
                    , stopPropagation = False
                    }
                  )
                , ( Backspace
                  , { message = DeleteInputForSingleSelect
                    , preventDefault = False
                    , stopPropagation = False
                    }
                  )
                , ( Delete
                  , { message = DeleteInputForSingleSelect
                    , preventDefault = False
                    , stopPropagation = False
                    }
                  )
                , ( Escape
                  , { message = EscapeKeyInInputFilter
                    , preventDefault = False
                    , stopPropagation = False
                    }
                  )

                -- We need to prevent default on these because when we use the arrow keys we want to move
                --  the highlighted option up and down but we do not want to move the cursor in the text box
                --  to the end and the beginning of the input.
                , ( ArrowUp
                  , { message = MoveHighlightedOptionUp
                    , preventDefault = True
                    , stopPropagation = False
                    }
                  )
                , ( ArrowDown
                  , { message = MoveHighlightedOptionDown
                    , preventDefault = True
                    , stopPropagation = False
                    }
                  )
                ]

        idAttr =
            id "input-filter"

        typeAttr =
            type_ "text"

        onBlurAttr =
            onBlur InputBlur

        onFocusAttr =
            onFocus InputFocus

        showPlaceholder =
            not hasSelectedOptions && not focused

        placeholderAttribute =
            if showPlaceholder then
                placeholder placeholder_

            else
                style "" ""
    in
    if isDisabled then
        input
            [ disabled True
            , idAttr
            , placeholderAttribute
            ]
            []

    else if hasSelectedOptions then
        input
            [ typeAttr
            , idAttr
            , onBlurAttr
            , onFocusAttr
            , value ""
            , maxlength 0
            , placeholderAttribute
            , keyboardEvents
            ]
            []

    else
        input
            [ typeAttr
            , idAttr
            , onBlurAttr
            , onFocusAttr
            , onInput SearchInputOnInput
            , value searchString
            , placeholderAttribute
            , keyboardEvents
            ]
            []


dropdownIndicator : Bool -> Bool -> Bool -> Html Msg
dropdownIndicator focused disabled hasOptions =
    if disabled || not hasOptions then
        text ""

    else
        div
            [ id "dropdown-indicator"
            , classList [ ( "down", focused ), ( "up", not focused ) ]
            ]
            [ text "▾" ]


dropdown : Model -> Html Msg
dropdown model =
    let
        optionsHtml =
            optionsToDropdownOptions
                DropdownMouseOverOption
                DropdownMouseOutOption
                DropdownMouseClickOption
                model.selectionMode
                model.optionsForTheDropdown

        dropdownFooterHtml =
            if List.length model.optionsForTheDropdown < List.length model.options then
                div [ id "dropdown-footer" ]
                    [ text
                        ("showing "
                            ++ (model.optionsForTheDropdown |> List.length |> String.fromInt)
                            ++ " of "
                            ++ (model.options |> List.length |> String.fromInt)
                            ++ " options"
                        )
                    ]

            else
                text ""

        dropdownCss =
            [ style "top"
                (String.fromFloat model.valueCasingHeight ++ "px")
            , style
                "width"
                (String.fromFloat model.valueCasingWidth ++ "px")
            ]
    in
    if model.disabled then
        text ""

    else if model.showDropdown && not (List.isEmpty model.optionsForTheDropdown) && not (List.isEmpty optionsHtml) then
        div
            ([ id "dropdown"
             , class "showing"
             ]
                ++ dropdownCss
            )
            (optionsHtml ++ [ dropdownFooterHtml ])

    else
        div
            ([ id "dropdown"
             , class "hiding"
             ]
                ++ dropdownCss
            )
            (optionsHtml ++ [ dropdownFooterHtml ])


optionsToDropdownOptions :
    (OptionValue -> msg)
    -> (OptionValue -> msg)
    -> (OptionValue -> msg)
    -> SelectionMode
    -> List Option
    -> List (Html msg)
optionsToDropdownOptions mouseOverMsgConstructor mouseOutMsgConstructor clickMsgConstructor selectionMode options =
    let
        partialWithSelectionMode =
            optionToDropdownOption
                mouseOverMsgConstructor
                mouseOutMsgConstructor
                clickMsgConstructor
                selectionMode

        helper : OptionGroup -> Option -> ( OptionGroup, List (Html msg) )
        helper previousGroup option_ =
            ( Option.getOptionGroup option_
            , option_ |> partialWithSelectionMode (previousGroup /= Option.getOptionGroup option_)
            )
    in
    options
        |> mapAccuml helper Option.emptyOptionGroup
        |> Tuple.second
        |> List.concat
        |> List.filter (\htmlTag -> htmlTag /= text "")


optionToDropdownOption :
    (OptionValue -> msg)
    -> (OptionValue -> msg)
    -> (OptionValue -> msg)
    -> SelectionMode
    -> Bool
    -> Option
    -> List (Html msg)
optionToDropdownOption mouseOverMsgConstructor mouseOutMsgConstructor clickMsgConstructor selectionMode prependOptionGroup option =
    let
        optionGroupHtml =
            if prependOptionGroup then
                div
                    [ class "optgroup"
                    ]
                    [ span [ class "optgroup-header" ]
                        [ text
                            (option
                                |> Option.getOptionGroup
                                |> Option.optionGroupToString
                            )
                        ]
                    ]

            else
                text ""

        descriptionHtml : Html msg
        descriptionHtml =
            if option |> Option.getOptionDescription |> Option.optionDescriptionToBool then
                case Option.getMaybeOptionSearchFilter option of
                    Just optionSearchFilter ->
                        div
                            [ class "description"
                            ]
                            [ span [] (tokensToHtml optionSearchFilter.descriptionTokens)
                            ]

                    Nothing ->
                        div
                            [ class "description"
                            ]
                            [ span []
                                [ option
                                    |> Option.getOptionDescription
                                    |> Option.optionDescriptionToString
                                    |> text
                                ]
                            ]

            else
                text ""

        labelHtml : Html msg
        labelHtml =
            case Option.getMaybeOptionSearchFilter option of
                Just optionSearchFilter ->
                    span [] (tokensToHtml optionSearchFilter.labelTokens)

                Nothing ->
                    span [] [ Option.getOptionLabel option |> optionLabelToString |> text ]

        valueDataAttribute =
            Html.Attributes.attribute "data-value" (Option.getOptionValueAsString option)
    in
    case Option.getOptionDisplay option of
        OptionShown ->
            [ optionGroupHtml
            , div
                [ onMouseEnter (option |> Option.getOptionValue |> mouseOverMsgConstructor)
                , onMouseLeave (option |> Option.getOptionValue |> mouseOutMsgConstructor)
                , mousedownPreventDefaultAndStopPropagation (option |> Option.getOptionValue |> clickMsgConstructor)
                , class "option"
                , valueDataAttribute
                ]
                [ labelHtml, descriptionHtml ]
            ]

        OptionHidden ->
            [ optionGroupHtml, text "" ]

        OptionSelected _ ->
            case selectionMode of
                SingleSelect _ _ ->
                    [ optionGroupHtml
                    , div
                        [ onMouseEnter (option |> Option.getOptionValue |> mouseOverMsgConstructor)
                        , onMouseLeave (option |> Option.getOptionValue |> mouseOutMsgConstructor)
                        , mousedownPreventDefaultAndStopPropagation (option |> Option.getOptionValue |> clickMsgConstructor)
                        , class "selected"
                        , class "option"
                        , valueDataAttribute
                        ]
                        [ labelHtml, descriptionHtml ]
                    ]

                MultiSelect _ ->
                    [ optionGroupHtml, text "" ]

        OptionSelectedHighlighted _ ->
            case selectionMode of
                SingleSelect _ _ ->
                    [ optionGroupHtml
                    , div
                        [ onMouseEnter (option |> Option.getOptionValue |> mouseOverMsgConstructor)
                        , onMouseLeave (option |> Option.getOptionValue |> mouseOutMsgConstructor)
                        , mousedownPreventDefaultAndStopPropagation (option |> Option.getOptionValue |> clickMsgConstructor)
                        , class "selected"
                        , class "highlighted"
                        , class "option"
                        , valueDataAttribute
                        ]
                        [ labelHtml, descriptionHtml ]
                    ]

                MultiSelect _ ->
                    [ optionGroupHtml, text "" ]

        OptionHighlighted ->
            [ optionGroupHtml
            , div
                [ onMouseEnter (option |> Option.getOptionValue |> mouseOverMsgConstructor)
                , onMouseLeave (option |> Option.getOptionValue |> mouseOutMsgConstructor)
                , mousedownPreventDefaultAndStopPropagation (option |> Option.getOptionValue |> clickMsgConstructor)
                , class "highlighted"
                , class "option"
                , valueDataAttribute
                ]
                [ labelHtml, descriptionHtml ]
            ]

        OptionDisabled ->
            [ optionGroupHtml
            , div
                [ class "disabled"
                , class "option"
                , valueDataAttribute
                ]
                [ labelHtml, descriptionHtml ]
            ]


optionsToValuesHtml : List Option -> List (Html Msg)
optionsToValuesHtml options =
    options
        |> List.map
            (\option ->
                case option of
                    Option display (OptionLabel labelStr _ _) optionValue _ _ _ ->
                        case display of
                            OptionShown ->
                                text ""

                            OptionHidden ->
                                text ""

                            OptionSelected _ ->
                                div
                                    [ class "value"
                                    , mousedownPreventDefaultAndStopPropagation
                                        (ToggleSelectedValueHighlight optionValue)
                                    ]
                                    [ text labelStr ]

                            OptionSelectedHighlighted _ ->
                                div
                                    [ classList
                                        [ ( "value", True )
                                        , ( "selected-value", True )
                                        ]
                                    , mousedownPreventDefaultAndStopPropagation
                                        (ToggleSelectedValueHighlight optionValue)
                                    ]
                                    [ text labelStr ]

                            OptionHighlighted ->
                                text ""

                            OptionDisabled ->
                                text ""

                    CustomOption display (OptionLabel labelStr _ _) optionValue _ ->
                        case display of
                            OptionShown ->
                                text ""

                            OptionHidden ->
                                text ""

                            OptionSelected _ ->
                                div
                                    [ class "value"
                                    , mousedownPreventDefaultAndStopPropagation
                                        (ToggleSelectedValueHighlight optionValue)
                                    ]
                                    [ text labelStr ]

                            OptionSelectedHighlighted _ ->
                                div
                                    [ classList
                                        [ ( "value", True )
                                        , ( "selected-value", True )
                                        ]
                                    , mousedownPreventDefaultAndStopPropagation
                                        (ToggleSelectedValueHighlight optionValue)
                                    ]
                                    [ text labelStr ]

                            OptionHighlighted ->
                                text ""

                            OptionDisabled ->
                                text ""

                    EmptyOption display (OptionLabel labelStr _ _) ->
                        case display of
                            OptionShown ->
                                text ""

                            OptionHidden ->
                                text ""

                            OptionSelected _ ->
                                div [ class "value" ] [ text labelStr ]

                            OptionSelectedHighlighted _ ->
                                text ""

                            OptionHighlighted ->
                                text ""

                            OptionDisabled ->
                                text ""
            )


rightSlotHtml : RightSlot -> Bool -> Bool -> Bool -> Html Msg
rightSlotHtml rightSlot focused disabled hasOptionSelected =
    case rightSlot of
        ShowNothing ->
            text ""

        ShowLoadingIndicator ->
            node "slot"
                [ name "loading-indicator" ]
                [ defaultLoadingIndicator ]

        ShowDropdownIndicator ->
            dropdownIndicator focused disabled hasOptionSelected

        ShowClearButton ->
            div
                [ id "clear-button-wrapper"
                , onClick ClearAllSelectedOptions
                ]
                [ node "slot"
                    [ name "clear-button"
                    ]
                    [ text "✕"
                    ]
                ]


defaultLoadingIndicator : Html msg
defaultLoadingIndicator =
    div [ class "default-loading-indicator" ] []


makeCommandMessagesWhenValuesChanges : List Option -> Maybe OptionValue -> Cmd Msg
makeCommandMessagesWhenValuesChanges selectedOptions maybeSelectedValue =
    let
        selectedCustomOptions =
            Option.customSelectedOptions selectedOptions

        clearCmd =
            if List.isEmpty selectedOptions then
                valueCleared ()

            else
                Cmd.none

        customOptionCmd =
            if List.isEmpty selectedCustomOptions then
                Cmd.none

            else
                customOptionSelected (Option.optionsValues selectedCustomOptions)

        -- Any time we select a new value we need to emit an `optionSelected` event.
        optionSelectedCmd =
            case maybeSelectedValue of
                Just selectedValue ->
                    case Option.findOptionByOptionValue selectedValue selectedOptions of
                        Just option ->
                            optionSelected (Option.optionToValueLabelTuple option)

                        Nothing ->
                            Cmd.none

                Nothing ->
                    Cmd.none
    in
    Cmd.batch
        [ valueChanged (selectedOptionsToTuple selectedOptions)
        , customOptionCmd
        , clearCmd
        , optionSelectedCmd
        ]


type alias Flags =
    { value : String
    , placeholder : String
    , size : String
    , allowMultiSelect : Bool
    , optionsJson : String
    , loading : Bool
    , maxDropdownItems : Int
    , disabled : Bool
    , allowCustomOptions : Bool
    , selectedItemStaysInPlace : Bool
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        maxDropdownItems =
            PositiveInt.new flags.maxDropdownItems

        allowCustomOptions =
            if flags.allowCustomOptions then
                AllowCustomOptions

            else
                NoCustomOptions

        selectedItemPlacementMode =
            if flags.selectedItemStaysInPlace then
                SelectedItemStaysInPlace

            else
                SelectedItemMovesToTheTop

        selectionMode =
            if flags.allowMultiSelect then
                MultiSelect allowCustomOptions

            else
                SingleSelect allowCustomOptions selectedItemPlacementMode

        initialValueStr =
            String.trim flags.value

        initialValues : List String
        initialValues =
            case initialValueStr of
                "" ->
                    []

                _ ->
                    case selectionMode of
                        SingleSelect _ _ ->
                            [ initialValueStr ]

                        MultiSelect _ ->
                            String.split "," initialValueStr

        ( optionsWithInitialValueSelected, errorCmd ) =
            case Json.Decode.decodeString Option.optionsDecoder flags.optionsJson of
                Ok options ->
                    case selectionMode of
                        SingleSelect _ _ ->
                            case List.head initialValues of
                                Just initialValueStr_ ->
                                    if Option.isOptionInListOfOptionsByValue (Option.stringToOptionValue initialValueStr_) options then
                                        let
                                            optionsWithUniqueValues =
                                                options |> List.Extra.uniqueBy Option.getOptionValueAsString
                                        in
                                        ( Option.selectOptionsInOptionsListByString
                                            initialValues
                                            optionsWithUniqueValues
                                        , Cmd.none
                                        )

                                    else
                                        -- TODO Perhaps we should call a helper function instead of calling selectOption here
                                        ( (Option.newOption initialValueStr_ Nothing |> Option.selectOption 0) :: options, Cmd.none )

                                Nothing ->
                                    let
                                        optionsWithUniqueValues =
                                            options |> List.Extra.uniqueBy Option.getOptionValueAsString
                                    in
                                    ( optionsWithUniqueValues, Cmd.none )

                        MultiSelect _ ->
                            let
                                -- Don't include any empty options, that doesn't make sense.
                                optionsWithInitialValues =
                                    options
                                        |> List.filter (not << Option.isEmptyOption)
                                        |> Option.addAndSelectOptionsInOptionsListByString SelectedItemStaysInPlace initialValues
                            in
                            ( optionsWithInitialValues, Cmd.none )

                Err error ->
                    ( [], errorMessage (Json.Decode.errorToString error) )
    in
    ( { initialValue = initialValues
      , deleteKeyPressed = False
      , placeholder = flags.placeholder
      , size = flags.size
      , selectionMode = selectionMode
      , options = optionsWithInitialValueSelected
      , optionsForTheDropdown =
            figureOutWhichOptionsToShow
                maxDropdownItems
                optionsWithInitialValueSelected
      , showDropdown = False
      , searchString = ""
      , rightSlot =
            if flags.loading then
                ShowLoadingIndicator

            else
                case selectionMode of
                    SingleSelect _ _ ->
                        ShowDropdownIndicator

                    MultiSelect _ ->
                        if Option.hasSelectedOption optionsWithInitialValueSelected then
                            ShowClearButton

                        else
                            ShowNothing
      , maxDropdownItems = maxDropdownItems
      , disabled = flags.disabled
      , focused = False

      -- TODO Should these be passed as flags?
      , valueCasingWidth = 100
      , valueCasingHeight = 45
      }
    , Cmd.batch [ errorCmd, muchSelectIsReady () ]
    )


main : Program Flags Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
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
        , selectedItemStaysInPlaceChangedReceiver SelectedItemStaysInPlaceChanged
        , optionsChangedReceiver OptionsChanged
        , maxDropdownItemsChangedReceiver MaxDropdownItemsChanged
        , allowCustomOptionsReceiver AllowCustomOptionsChanged
        , valueCasingDimensionsChangedReceiver ValueCasingWidthUpdate
        , selectOptionReceiver SelectOption
        , deselectOptionReceiver DeselectOption
        ]


mousedownPreventDefaultAndStopPropagation : a -> Html.Attribute a
mousedownPreventDefaultAndStopPropagation message =
    Html.Events.custom "mousedown"
        (Json.Decode.succeed
            { message = message
            , stopPropagation = True
            , preventDefault = True
            }
        )
