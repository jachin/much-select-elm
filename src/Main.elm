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
import Html.Lazy
import Json.Decode
import Json.Encode
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
        , allOptions
        , allowCustomOptionsReceiver
        , blurInput
        , customOptionHintReceiver
        , customOptionSelected
        , deselectOptionReceiver
        , disableChangedReceiver
        , errorMessage
        , focusInput
        , initialValueSet
        , inputBlurred
        , inputKeyUp
        , loadingChangedReceiver
        , maxDropdownItemsChangedReceiver
        , muchSelectIsReady
        , multiSelectChangedReceiver
        , multiSelectSingleItemRemovalChangedReceiver
        , optionDeselected
        , optionSelected
        , optionsChangedReceiver
        , placeholderChangedReceiver
        , removeOptionsReceiver
        , requestAllOptionsReceiver
        , scrollDropdownToElement
        , searchStringMinimumLengthChangedReceiver
        , selectOptionReceiver
        , selectedItemStaysInPlaceChangedReceiver
        , showDropdownFooterChangedReceiver
        , valueCasingDimensionsChangedReceiver
        , valueChanged
        , valueChangedReceiver
        , valueCleared
        , valueDecoder
        , valuesDecoder
        )
import PositiveInt exposing (PositiveInt)
import SelectionMode
    exposing
        ( CustomOptions(..)
        , SelectedItemPlacementMode(..)
        , SelectionMode(..)
        , SingleItemRemoval(..)
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
    | DeselectOptionInternal Option
    | PlaceholderAttributeChanged String
    | LoadingAttributeChanged Bool
    | MaxDropdownItemsChanged Int
    | ShowDropdownFooterChanged Bool
    | AllowCustomOptionsChanged Bool
    | CustomOptionHintChanged (Maybe String)
    | DisabledAttributeChanged Bool
    | MultiSelectAttributeChanged Bool
    | MultiSelectSingleItemRemovalAttributeChanged Bool
    | SearchStringMinimumLengthAttributeChanged Int
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
    | RequestAllOptions


type alias Model =
    { initialValue : List String
    , placeholder : String
    , customOptionHint : Maybe String
    , selectionMode : SelectionMode
    , options : List Option
    , optionsForTheDropdown : List Option
    , showDropdown : Bool
    , searchString : String
    , searchStringMinimumLength : PositiveInt
    , rightSlot : RightSlot
    , maxDropdownItems : PositiveInt
    , disabled : Bool
    , focused : Bool
    , valueCasingWidth : Float
    , valueCasingHeight : Float
    , deleteKeyPressed : Bool
    , showDropdownFooter : Bool
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
                ( model, focusInput () )

            else
                ( { model | focused = True }, focusInput () )

        BringInputOutOfFocus ->
            if model.focused then
                ( { model | focused = False }, blurInput () )

            else
                ( model, blurInput () )

        InputBlur ->
            let
                optionsWithoutUnselectedCustomOptions =
                    Option.removeUnselectedCustomOptions model.options
                        |> Option.unhighlightSelectedOptions

                -- clear out the search string
                updatedModel =
                    updateModelWithSearchStringChanges
                        model.searchStringMinimumLength
                        model.maxDropdownItems
                        ""
                        optionsWithoutUnselectedCustomOptions
                        model
            in
            ( { updatedModel
                | showDropdown = False
                , focused = False
              }
            , inputBlurred ()
            )

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
                        MultiSelect _ _ ->
                            selectOptionInListByOptionValue optionValue model.options

                        SingleSelect _ _ ->
                            selectSingleOptionInList optionValue model.options
            in
            case model.selectionMode of
                SingleSelect _ _ ->
                    ( updateModelWithSearchStringChanges model.searchStringMinimumLength model.maxDropdownItems "" options model
                    , Cmd.batch
                        [ makeCommandMessagesWhenValuesChanges options (Just optionValue)
                        , blurInput ()
                        ]
                    )

                MultiSelect _ _ ->
                    ( updateModelWithSearchStringChanges model.searchStringMinimumLength model.maxDropdownItems "" options model
                    , Cmd.batch
                        [ makeCommandMessagesWhenValuesChanges options (Just optionValue)
                        , focusInput ()
                        ]
                    )

        SearchInputOnInput searchString ->
            ( updateModelWithSearchStringChanges model.searchStringMinimumLength model.maxDropdownItems searchString model.options model
            , inputKeyUp searchString
            )

        ValueChanged valuesJson ->
            let
                valuesResult =
                    case model.selectionMode of
                        SingleSelect _ _ ->
                            Json.Decode.decodeValue valueDecoder valuesJson

                        MultiSelect _ _ ->
                            Json.Decode.decodeValue valuesDecoder valuesJson
            in
            case valuesResult of
                Ok values ->
                    let
                        newOptions =
                            Option.addAndSelectOptionsInOptionsListByString
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

                                MultiSelect _ _ ->
                                    -- Also filter out any empty options.
                                    Option.mergeTwoListsOfOptionsPreservingSelectedOptions SelectedItemStaysInPlace
                                        model.options
                                        (newOptions
                                            |> List.filter (not << Option.isEmptyOption)
                                        )
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
                                MultiSelect _ _ ->
                                    selectOptionInListByOptionValue optionValue model.options

                                SingleSelect _ _ ->
                                    selectSingleOptionInList optionValue model.options
                    in
                    ( updateModelWithSearchStringChanges
                        model.searchStringMinimumLength
                        model.maxDropdownItems
                        ""
                        options
                        model
                    , makeCommandMessagesWhenValuesChanges options (Just optionValue)
                    )

                Err error ->
                    ( model, errorMessage (Json.Decode.errorToString error) )

        DeselectOptionInternal optionToDeselect ->
            deselectOption model optionToDeselect

        DeselectOption optionJson ->
            case Json.Decode.decodeValue Option.decoder optionJson of
                Ok option ->
                    deselectOption model option

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

        ShowDropdownFooterChanged bool ->
            ( { model
                | showDropdownFooter = bool
              }
            , Cmd.none
            )

        AllowCustomOptionsChanged canAddCustomOptions ->
            ( { model | selectionMode = SelectionMode.setAllowCustomOptionsWithBool canAddCustomOptions model.selectionMode }
            , Cmd.none
            )

        CustomOptionHintChanged maybeString ->
            ( { model | customOptionHint = maybeString }, Cmd.none )

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

        MultiSelectSingleItemRemovalAttributeChanged shouldEnableMultiSelectSingleItemRemoval ->
            let
                multiSelectSingleItemRemoval =
                    if shouldEnableMultiSelectSingleItemRemoval then
                        EnableSingleItemRemoval

                    else
                        DisableSingleItemRemoval

                newMode =
                    case model.selectionMode of
                        SingleSelect _ _ ->
                            model.selectionMode

                        MultiSelect customOptions _ ->
                            MultiSelect customOptions multiSelectSingleItemRemoval
            in
            ( { model
                | selectionMode = newMode
              }
            , Cmd.batch [ muchSelectIsReady (), Cmd.none ]
            )

        MultiSelectAttributeChanged isInMultiSelectMode ->
            let
                options =
                    if isInMultiSelectMode then
                        model.options

                    else
                        Option.deselectAllButTheFirstSelectedOptionInList model.options

                cmd =
                    if isInMultiSelectMode then
                        Cmd.none

                    else
                        makeCommandMessagesWhenValuesChanges (Option.selectedOptions options) Nothing
            in
            ( { model
                | selectionMode = SelectionMode.setMultiSelectModeWithBool isInMultiSelectMode model.selectionMode
                , options = options
                , optionsForTheDropdown = figureOutWhichOptionsToShow model.maxDropdownItems options
              }
            , Cmd.batch [ muchSelectIsReady (), cmd ]
            )

        SearchStringMinimumLengthAttributeChanged searchStringMinimumLength ->
            ( { model | searchStringMinimumLength = PositiveInt.new searchStringMinimumLength }, Cmd.none )

        SelectHighlightedOption ->
            let
                options =
                    selectHighlightedOption model.selectionMode model.options
            in
            case model.selectionMode of
                SingleSelect _ _ ->
                    ( updateModelWithSearchStringChanges
                        model.searchStringMinimumLength
                        model.maxDropdownItems
                        ""
                        options
                        model
                    , Cmd.batch
                        -- TODO Figure out what the highlighted option in here
                        [ makeCommandMessagesWhenValuesChanges options Nothing
                        , blurInput ()
                        ]
                    )

                MultiSelect _ _ ->
                    ( updateModelWithSearchStringChanges
                        model.searchStringMinimumLength
                        model.maxDropdownItems
                        ""
                        options
                        model
                      -- TODO Figure out what the highlighted option in here
                    , Cmd.batch
                        [ makeCommandMessagesWhenValuesChanges options Nothing
                        , focusInput ()
                        ]
                    )

        DeleteInputForSingleSelect ->
            case model.selectionMode of
                SingleSelect _ _ ->
                    if Option.hasSelectedOption model.options then
                        -- if there are ANY selected options, clear them all;
                        clearAllSelectedOption model

                    else
                        ( model, Cmd.none )

                MultiSelect _ _ ->
                    ( model, Cmd.none )

        EscapeKeyInInputFilter ->
            ( updateModelWithSearchStringChanges model.searchStringMinimumLength
                model.maxDropdownItems
                ""
                model.options
                model
            , blurInput ()
            )

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

        ToggleSelectedValueHighlight optionValue ->
            let
                updatedOptions =
                    Option.toggleSelectedHighlightByOptionValue model.options optionValue
            in
            ( { model
                | options = updatedOptions
                , optionsForTheDropdown = figureOutWhichOptionsToShow model.maxDropdownItems updatedOptions
              }
            , Cmd.none
            )

        DeleteKeydownForMultiSelect ->
            if String.length model.searchString > 0 then
                ( model, Cmd.none )

            else
                let
                    newOptions =
                        if Option.hasSelectedHighlightedOptions model.options then
                            Option.deselectAllSelectedHighlightedOptions model.options

                        else
                            Option.deselectLastSelectedOption model.options
                in
                ( { model
                    | options = newOptions
                    , optionsForTheDropdown = figureOutWhichOptionsToShow model.maxDropdownItems newOptions
                  }
                , Cmd.batch
                    [ valueChanged (selectedOptionsToTuple newOptions)
                    , focusInput ()
                    ]
                )

        RequestAllOptions ->
            ( model, allOptions (Json.Encode.list Option.encode model.options) )


deselectOption : Model -> Option -> ( Model, Cmd Msg )
deselectOption model option =
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

        deselectEventCmdMsg =
            if List.isEmpty deselectedItems then
                Cmd.none

            else
                optionDeselected deselectedItems

        newOptions =
            Option.deselectAllOptionsInOptionsList model.options

        focusCmdMsg =
            if model.focused then
                focusInput ()

            else
                Cmd.none
    in
    ( { model
        | options = Option.deselectAllOptionsInOptionsList newOptions
        , optionsForTheDropdown = figureOutWhichOptionsToShow model.maxDropdownItems newOptions
        , rightSlot = updateRightSlot model.rightSlot model.selectionMode False
        , searchString = ""
      }
    , Cmd.batch
        [ makeCommandMessagesWhenValuesChanges [] Nothing
        , deselectEventCmdMsg
        , focusCmdMsg
        ]
    )


updateModelWithSearchStringChanges : PositiveInt -> PositiveInt -> String -> List Option -> Model -> Model
updateModelWithSearchStringChanges searchStringMinimumLength maxNumberOfDropdownItems searchString options model =
    if String.length searchString == 0 then
        -- the search string is empty, let's make sure everything get cleared out of the model.
        let
            updatedOptions =
                OptionSearcher.updateOptions model.selectionMode model.customOptionHint searchString options
                    |> Option.sortOptionsByGroupAndLabel
        in
        { model
            | searchString = searchString
            , options = updatedOptions
            , optionsForTheDropdown = figureOutWhichOptionsToShow maxNumberOfDropdownItems updatedOptions
        }

    else if String.length searchString < PositiveInt.toInt searchStringMinimumLength then
        -- We have a search string but it's below are minimum for filtering. This means we still want to update the
        -- search string it self in the model but we don't need to do anything with the options
        let
            updatedOptions =
                OptionSearcher.updateOptions model.selectionMode model.customOptionHint "" options
                    |> Option.sortOptionsByGroupAndLabel
        in
        { model
            | searchString = searchString
            , options = updatedOptions
            , optionsForTheDropdown = figureOutWhichOptionsToShow maxNumberOfDropdownItems updatedOptions
        }

    else
        -- We have a search string and it's over the minimum length for filter. Let's update the model and filter the
        -- the options.
        let
            optionsUpdatedWithSearchString =
                OptionSearcher.updateOptions model.selectionMode model.customOptionHint searchString options

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

                MultiSelect _ _ ->
                    if hasSelectedOption then
                        ShowClearButton

                    else
                        ShowDropdownIndicator

        ShowLoadingIndicator ->
            ShowLoadingIndicator

        ShowDropdownIndicator ->
            case selectionMode of
                SingleSelect _ _ ->
                    ShowDropdownIndicator

                MultiSelect _ _ ->
                    if hasSelectedOption then
                        ShowClearButton

                    else
                        ShowDropdownIndicator

        ShowClearButton ->
            if hasSelectedOption then
                ShowClearButton

            else
                ShowDropdownIndicator


updateRightSlotLoading : Bool -> SelectionMode -> Bool -> RightSlot
updateRightSlotLoading isLoading selectionMode hasSelectedOption =
    if isLoading then
        ShowLoadingIndicator

    else
        case selectionMode of
            SingleSelect _ _ ->
                ShowDropdownIndicator

            MultiSelect _ _ ->
                if hasSelectedOption then
                    ShowClearButton

                else
                    ShowDropdownIndicator


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
                        , ( "not-focused", not model.focused )
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
                            dropdownIndicator model.focused model.disabled

                        ShowClearButton ->
                            node "slot" [ name "clear-button" ] []
                    ]
                , dropdown model
                ]

        MultiSelect _ enableSingleItemRemoval ->
            let
                hasOptionSelected =
                    Option.hasSelectedOption model.options

                showPlaceholder =
                    not hasOptionSelected && not model.focused

                placeholderAttribute =
                    if showPlaceholder then
                        placeholder model.placeholder

                    else
                        Html.Attributes.classList []

                inputFilter =
                    input
                        [ type_ "text"
                        , onBlur InputBlur
                        , onFocus InputFocus
                        , onInput SearchInputOnInput
                        , value model.searchString
                        , placeholderAttribute
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
                        [ ( "show-placeholder", showPlaceholder )
                        , ( "has-option-selected", hasOptionSelected )
                        , ( "no-option-selected", not hasOptionSelected )
                        , ( "multi", True )
                        , ( "disabled", model.disabled )
                        , ( "focused", model.focused )
                        , ( "not-focused", not model.focused )
                        ]
                    ]
                    (optionsToValuesHtml model.options enableSingleItemRemoval
                        ++ [ inputFilter
                           , rightSlotHtml
                                model.rightSlot
                                model.focused
                                model.disabled
                           ]
                        ++ [ dropdown model ]
                    )
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


dropdownIndicator : Bool -> Bool -> Html Msg
dropdownIndicator focused disabled =
    if disabled then
        text ""

    else
        div
            [ id "dropdown-indicator"
            , classList [ ( "down", focused ), ( "up", not focused ) ]
            ]
            [ text "▾" ]


type alias DropdownItemEventListeners msg =
    { mouseOverMsgConstructor : OptionValue -> msg
    , mouseOutMsgConstructor : OptionValue -> msg
    , clickMsgConstructor : OptionValue -> msg
    , noOpMsgConstructor : msg
    }


dropdown : Model -> Html Msg
dropdown model =
    let
        optionsHtml =
            if List.isEmpty model.optionsForTheDropdown then
                [ div [ class "option disabled" ] [ node "slot" [ name "no-options" ] [ text "No available options" ] ] ]

            else
                optionsToDropdownOptions
                    { mouseOverMsgConstructor = DropdownMouseOverOption
                    , mouseOutMsgConstructor = DropdownMouseOutOption
                    , clickMsgConstructor = DropdownMouseClickOption
                    , noOpMsgConstructor = NoOp
                    }
                    model.selectionMode
                    model.optionsForTheDropdown

        dropdownFooterHtml =
            if model.showDropdownFooter && List.length model.optionsForTheDropdown < List.length model.options then
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

    else if model.showDropdown && not (List.isEmpty optionsHtml) then
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
    DropdownItemEventListeners Msg
    -> SelectionMode
    -> List Option
    -> List (Html Msg)
optionsToDropdownOptions eventHandlers selectionMode options =
    let
        partialWithSelectionMode =
            optionToDropdownOption
                eventHandlers
                selectionMode

        helper : OptionGroup -> Option -> ( OptionGroup, List (Html Msg) )
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
    DropdownItemEventListeners Msg
    -> SelectionMode
    -> Bool
    -> Option
    -> List (Html Msg)
optionToDropdownOption eventHandlers selectionMode prependOptionGroup option =
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

        descriptionHtml : Html Msg
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

        labelHtml : Html Msg
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
                [ onMouseEnter (option |> Option.getOptionValue |> eventHandlers.mouseOverMsgConstructor)
                , onMouseLeave (option |> Option.getOptionValue |> eventHandlers.mouseOutMsgConstructor)
                , mousedownPreventDefault (option |> Option.getOptionValue |> eventHandlers.clickMsgConstructor)
                , onClickPreventDefault eventHandlers.noOpMsgConstructor
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
                        [ onMouseEnter (option |> Option.getOptionValue |> eventHandlers.mouseOverMsgConstructor)
                        , onMouseLeave (option |> Option.getOptionValue |> eventHandlers.mouseOutMsgConstructor)
                        , mousedownPreventDefault (option |> Option.getOptionValue |> eventHandlers.clickMsgConstructor)
                        , class "selected"
                        , class "option"
                        , valueDataAttribute
                        ]
                        [ labelHtml, descriptionHtml ]
                    ]

                MultiSelect _ _ ->
                    [ optionGroupHtml, text "" ]

        OptionSelectedHighlighted _ ->
            case selectionMode of
                SingleSelect _ _ ->
                    [ optionGroupHtml
                    , div
                        [ onMouseEnter (option |> Option.getOptionValue |> eventHandlers.mouseOverMsgConstructor)
                        , onMouseLeave (option |> Option.getOptionValue |> eventHandlers.mouseOutMsgConstructor)
                        , mousedownPreventDefault (option |> Option.getOptionValue |> eventHandlers.clickMsgConstructor)
                        , class "selected"
                        , class "highlighted"
                        , class "option"
                        , valueDataAttribute
                        ]
                        [ labelHtml, descriptionHtml ]
                    ]

                MultiSelect _ _ ->
                    [ optionGroupHtml, text "" ]

        OptionHighlighted ->
            [ optionGroupHtml
            , div
                [ onMouseEnter (option |> Option.getOptionValue |> eventHandlers.mouseOverMsgConstructor)
                , onMouseLeave (option |> Option.getOptionValue |> eventHandlers.mouseOutMsgConstructor)
                , mousedownPreventDefault (option |> Option.getOptionValue |> eventHandlers.clickMsgConstructor)
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


optionsToValuesHtml : List Option -> SingleItemRemoval -> List (Html Msg)
optionsToValuesHtml options enableSingleItemRemoval =
    options
        |> Option.selectedOptions
        |> List.map (Html.Lazy.lazy2 optionToValueHtml enableSingleItemRemoval)


optionToValueHtml : SingleItemRemoval -> Option -> Html Msg
optionToValueHtml enableSingleItemRemoval option =
    case option of
        Option display optionLabel optionValue _ _ _ ->
            let
                removalHtml =
                    case enableSingleItemRemoval of
                        EnableSingleItemRemoval ->
                            span [ mousedownPreventDefault <| DeselectOptionInternal option, class "remove-option" ] [ text "" ]

                        DisableSingleItemRemoval ->
                            text ""
            in
            case display of
                OptionShown ->
                    text ""

                OptionHidden ->
                    text ""

                OptionSelected _ ->
                    div
                        [ class "value"
                        ]
                        [ valueLabelHtml (OptionLabel.getLabelString optionLabel) optionValue, removalHtml ]

                OptionSelectedHighlighted _ ->
                    div
                        [ classList
                            [ ( "value", True )
                            , ( "highlighted-value", True )
                            ]
                        ]
                        [ valueLabelHtml (OptionLabel.getLabelString optionLabel) optionValue, removalHtml ]

                OptionHighlighted ->
                    text ""

                OptionDisabled ->
                    text ""

        CustomOption display optionLabel optionValue _ ->
            case display of
                OptionShown ->
                    text ""

                OptionHidden ->
                    text ""

                OptionSelected _ ->
                    div
                        [ class "value"
                        , mousedownPreventDefault
                            (ToggleSelectedValueHighlight optionValue)
                        ]
                        [ valueLabelHtml (OptionLabel.getLabelString optionLabel) optionValue ]

                OptionSelectedHighlighted _ ->
                    div
                        [ classList
                            [ ( "value", True )
                            , ( "highlighted-value", True )
                            ]
                        ]
                        [ valueLabelHtml (OptionLabel.getLabelString optionLabel) optionValue ]

                OptionHighlighted ->
                    text ""

                OptionDisabled ->
                    text ""

        EmptyOption display optionLabel ->
            case display of
                OptionShown ->
                    text ""

                OptionHidden ->
                    text ""

                OptionSelected _ ->
                    div [ class "value" ] [ text (OptionLabel.getLabelString optionLabel) ]

                OptionSelectedHighlighted _ ->
                    text ""

                OptionHighlighted ->
                    text ""

                OptionDisabled ->
                    text ""


valueLabelHtml : String -> OptionValue -> Html Msg
valueLabelHtml labelText optionValue =
    span
        [ class "value-label"
        , mousedownPreventDefault
            (ToggleSelectedValueHighlight optionValue)
        ]
        [ text labelText ]


rightSlotHtml : RightSlot -> Bool -> Bool -> Html Msg
rightSlotHtml rightSlot focused disabled =
    case rightSlot of
        ShowNothing ->
            text ""

        ShowLoadingIndicator ->
            node "slot"
                [ name "loading-indicator" ]
                [ defaultLoadingIndicator ]

        ShowDropdownIndicator ->
            dropdownIndicator focused disabled

        ShowClearButton ->
            div
                [ id "clear-button-wrapper"
                , onClickPreventDefault ClearAllSelectedOptions
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


makeCommandMessageForInitialValue : List Option -> Cmd Msg
makeCommandMessageForInitialValue selectedOptions =
    case selectedOptions of
        [] ->
            Cmd.none

        selectionOptions_ ->
            initialValueSet (selectedOptionsToTuple selectionOptions_)


type alias Flags =
    { value : Json.Decode.Value
    , placeholder : String
    , customOptionHint : Maybe String
    , allowMultiSelect : Bool
    , enableMultiSelectSingleItemRemoval : Bool
    , optionsJson : String
    , loading : Bool
    , maxDropdownItems : Int
    , disabled : Bool
    , allowCustomOptions : Bool
    , selectedItemStaysInPlace : Bool
    , searchStringMinimumLength : Int
    , showDropdownFooter : Bool
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
                let
                    singleItemRemoval =
                        if flags.enableMultiSelectSingleItemRemoval then
                            EnableSingleItemRemoval

                        else
                            DisableSingleItemRemoval
                in
                MultiSelect allowCustomOptions singleItemRemoval

            else
                SingleSelect allowCustomOptions selectedItemPlacementMode

        ( initialValues, initialValueErrCmd ) =
            case Json.Decode.decodeValue (Json.Decode.oneOf [ valuesDecoder, valueDecoder ]) flags.value of
                Ok values ->
                    case selectionMode of
                        SingleSelect _ _ ->
                            ( values, Cmd.none )

                        MultiSelect _ _ ->
                            ( values, Cmd.none )

                Err error ->
                    ( [], errorMessage (Json.Decode.errorToString error) )

        ( optionsWithInitialValueSelected, errorCmd ) =
            case Json.Decode.decodeString Option.optionsDecoder flags.optionsJson of
                Ok options ->
                    case selectionMode of
                        SingleSelect _ _ ->
                            case List.head initialValues of
                                Just initialValueStr_ ->
                                    if Option.isOptionValueInListOfOptionsByValue (Option.stringToOptionValue initialValueStr_) options then
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

                        MultiSelect _ _ ->
                            let
                                -- Don't include any empty options, that doesn't make sense.
                                optionsWithInitialValues =
                                    options
                                        |> List.filter (not << Option.isEmptyOption)
                                        |> Option.addAndSelectOptionsInOptionsListByString initialValues
                            in
                            ( optionsWithInitialValues, Cmd.none )

                Err error ->
                    ( [], errorMessage (Json.Decode.errorToString error) )
    in
    ( { initialValue = initialValues
      , deleteKeyPressed = False
      , placeholder = flags.placeholder
      , customOptionHint = flags.customOptionHint
      , selectionMode = selectionMode
      , options = optionsWithInitialValueSelected
      , optionsForTheDropdown =
            figureOutWhichOptionsToShow
                maxDropdownItems
                optionsWithInitialValueSelected
      , showDropdown = False
      , searchString = ""
      , searchStringMinimumLength =
            Maybe.withDefault (PositiveInt.new 2)
                (PositiveInt.maybeNew flags.searchStringMinimumLength)
      , rightSlot =
            if flags.loading then
                ShowLoadingIndicator

            else
                case selectionMode of
                    SingleSelect _ _ ->
                        ShowDropdownIndicator

                    MultiSelect _ _ ->
                        if Option.hasSelectedOption optionsWithInitialValueSelected then
                            ShowClearButton

                        else
                            ShowDropdownIndicator
      , maxDropdownItems = maxDropdownItems
      , disabled = flags.disabled
      , focused = False

      -- TODO Should these be passed as flags?
      , valueCasingWidth = 100
      , valueCasingHeight = 45
      , showDropdownFooter = flags.showDropdownFooter
      }
    , Cmd.batch
        [ errorCmd
        , initialValueErrCmd
        , muchSelectIsReady ()
        , makeCommandMessageForInitialValue (Option.selectedOptions optionsWithInitialValueSelected)
        ]
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
        , showDropdownFooterChangedReceiver ShowDropdownFooterChanged
        , allowCustomOptionsReceiver AllowCustomOptionsChanged
        , customOptionHintReceiver CustomOptionHintChanged
        , valueCasingDimensionsChangedReceiver ValueCasingWidthUpdate
        , selectOptionReceiver SelectOption
        , deselectOptionReceiver DeselectOption
        , multiSelectChangedReceiver MultiSelectAttributeChanged
        , multiSelectSingleItemRemovalChangedReceiver MultiSelectSingleItemRemovalAttributeChanged
        , searchStringMinimumLengthChangedReceiver SearchStringMinimumLengthAttributeChanged
        , requestAllOptionsReceiver (\() -> RequestAllOptions)
        ]


{-| Performs the mousedown event, but also prevent default.

We used to also stop propagation but that is actually a problem because that stops all the click events
default actions from being suppressed (I think).

-}
mousedownPreventDefault : msg -> Html.Attribute msg
mousedownPreventDefault message =
    Html.Events.custom "mousedown"
        (Json.Decode.succeed
            { message = message
            , stopPropagation = False
            , preventDefault = True
            }
        )


{-| Performs the event onClick, but also prevent default.

We used to also stop propagation but that is actually a problem because we want

-}
onClickPreventDefault : msg -> Html.Attribute msg
onClickPreventDefault message =
    Html.Events.custom "click"
        (Json.Decode.succeed
            { message = message
            , stopPropagation = False
            , preventDefault = True
            }
        )
