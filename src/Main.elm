module Main exposing (..)

import Browser
import Debouncer.Messages
    exposing
        ( Debouncer
        , Milliseconds
        , fromSeconds
        , provideInput
        , settleWhenQuietFor
        , toDebouncer
        )
import Html exposing (Html, button, div, input, node, optgroup, span, text)
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
import Html.Attributes.Extra exposing (attributeIf)
import Html.Events exposing (onBlur, onClick, onFocus, onInput, onMouseDown, onMouseEnter, onMouseLeave)
import Html.Lazy
import Json.Decode
import Json.Encode
import Keyboard exposing (Key(..))
import Keyboard.Events as Keyboard
import List.Extra
import Option
    exposing
        ( Option(..)
        , OptionDisplay(..)
        , OptionGroup
        )
import OptionLabel exposing (OptionLabel(..), optionLabelToString)
import OptionPresentor exposing (tokensToHtml)
import OptionSearcher exposing (doesSearchStringFindNothing, updateOrAddCustomOption)
import OptionSorting
    exposing
        ( OptionSort(..)
        , sortOptions
        , sortOptionsBySearchFilterTotalScore
        , stringToOptionSort
        )
import OptionValue exposing (OptionValue(..))
import OptionsUtilities
    exposing
        ( addAdditionalOptionsToOptionList
        , addAndSelectOptionsInOptionsListByString
        , adjustHighlightedOptionAfterSearch
        , customSelectedOptions
        , deselectAllButTheFirstSelectedOptionInList
        , deselectAllOptionsInOptionsList
        , deselectAllSelectedHighlightedOptions
        , deselectLastSelectedOption
        , deselectOptionInListByOptionValue
        , filterOptionsToShowInDropdown
        , findHighlightedOption
        , findHighlightedOrSelectedOptionIndex
        , findOptionByOptionValue
        , groupOptionsInOrder
        , hasSelectedHighlightedOptions
        , hasSelectedOption
        , highlightOptionInListByValue
        , isOptionValueInListOfOptionsByValue
        , moveHighlightedOptionDown
        , moveHighlightedOptionUp
        , optionsValues
        , removeHighlightOptionInList
        , removeOptionsFromOptionList
        , removeUnselectedCustomOptions
        , replaceOptions
        , selectHighlightedOption
        , selectOptionInListByOptionValue
        , selectOptionsInOptionsListByString
        , selectSingleOptionInList
        , selectedOptions
        , selectedOptionsToTuple
        , toggleSelectedHighlightByOptionValue
        , unhighlightSelectedOptions
        , updateDatalistOptionsWithValue
        )
import OutputStyle
    exposing
        ( DropdownStyle(..)
        , MaxDropdownItems(..)
        , SearchStringMinimumLength(..)
        , SingleItemRemoval(..)
        )
import Ports
    exposing
        ( addOptionsReceiver
        , allOptions
        , allowCustomOptionsReceiver
        , blurInput
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
        , optionSortingChangedReceiver
        , optionsReplacedReceiver
        , optionsUpdated
        , outputStyleChangedReceiver
        , placeholderChangedReceiver
        , removeOptionsReceiver
        , requestAllOptionsReceiver
        , scrollDropdownToElement
        , searchOptionsWithWebWorker
        , searchStringMinimumLengthChangedReceiver
        , selectOptionReceiver
        , selectedItemStaysInPlaceChangedReceiver
        , showDropdownFooterChangedReceiver
        , updateOptionsInWebWorker
        , updateSearchResultDataWithWebWorkerReceiver
        , valueCasingDimensionsChangedReceiver
        , valueChanged
        , valueChangedReceiver
        , valueCleared
        , valueDecoder
        , valuesDecoder
        )
import PositiveInt exposing (PositiveInt)
import SearchString exposing (SearchString)
import SelectionMode
    exposing
        ( OutputStyle(..)
        , SelectionConfig(..)
        , defaultSelectionConfig
        , getMaxDropdownItems
        , getOutputStyle
        , getPlaceholder
        , getSearchStringMinimumLength
        , getSingleItemRemoval
        , isDisabled
        , isFocused
        , isSingleSelect
        , makeSelectionConfig
        , setDropdownStyle
        , setIsDisabled
        , setIsFocused
        , setMaxDropdownItems
        , setSearchStringMinimumLength
        , setSelectedItemStaysInPlaceWithBool
        , setShowDropdown
        , setSingleItemRemoval
        , showDropdown
        , showDropdownFooter
        )
import Task


type Msg
    = NoOp
    | BringInputInFocus
    | BringInputOutOfFocus
    | InputBlur
    | InputFocus
    | DropdownMouseOverOption OptionValue
    | DropdownMouseOutOption OptionValue
    | DropdownMouseClickOption OptionValue
    | UpdateSearchString String
    | UpdateOptionValueValue Int String
    | UpdateOptionsWithSearchString
    | MsgQuietUpdateOptionsWithSearchString (Debouncer.Messages.Msg Msg)
    | TextInputOnInput String
    | ValueChanged Json.Decode.Value
    | OptionsReplaced Json.Decode.Value
    | OptionSortingChanged String
    | AddOptions Json.Decode.Value
    | RemoveOptions Json.Decode.Value
    | SelectOption Json.Decode.Value
    | DeselectOption Json.Decode.Value
    | DeselectOptionInternal Option
    | PlaceholderAttributeChanged String
    | LoadingAttributeChanged Bool
    | MaxDropdownItemsChanged Int
    | ShowDropdownFooterChanged Bool
    | AllowCustomOptionsChanged ( Bool, String )
    | DisabledAttributeChanged Bool
    | MultiSelectAttributeChanged Bool
    | MultiSelectSingleItemRemovalAttributeChanged Bool
    | SearchStringMinimumLengthAttributeChanged Int
    | SelectedItemStaysInPlaceChanged Bool
    | OutputStyleChanged String
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
    | AddMultiSelectValue Int
    | RemoveMultiSelectValue Int
    | RequestAllOptions
    | UpdateSearchResultsForOptions Json.Encode.Value


type alias Model =
    { initialValue : List String
    , placeholder : String
    , selectionConfig : SelectionConfig
    , options : List Option
    , optionSort : OptionSort
    , quietSearchForDynamicInterval : Debouncer Msg
    , searchString : SearchString
    , focusedIndex : Int
    , rightSlot : RightSlot
    , valueCasing : ValueCasing
    , deleteKeyPressed : Bool
    }


{-| A type for (helping) keeping track of the focus state. While we are losing focus or while we are gaining focus we'll
be in transition.
-}
type FocusTransition
    = InFocusTransition
    | NotInFocusTransition


type RightSlot
    = ShowNothing
    | ShowLoadingIndicator
    | ShowDropdownIndicator FocusTransition
    | ShowClearButton
    | ShowAddButton
    | ShowAddAndRemoveButtons


type ValueCasing
    = ValueCasing Float Float


updateDebouncer : Debouncer.Messages.UpdateConfig Msg Model
updateDebouncer =
    { mapMsg = MsgQuietUpdateOptionsWithSearchString
    , getDebouncer = .quietSearchForDynamicInterval
    , setDebouncer = \debouncer model -> { model | quietSearchForDynamicInterval = debouncer }
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        BringInputInFocus ->
            case getOutputStyle model.selectionConfig of
                CustomHtml ->
                    if isRightSlotTransitioning model.rightSlot then
                        ( model, Cmd.none )

                    else if isFocused model.selectionConfig then
                        ( model, focusInput () )

                    else
                        ( { model
                            | selectionConfig = setIsFocused True model.selectionConfig
                            , rightSlot = updateRightSlotTransitioning InFocusTransition model.rightSlot
                          }
                        , focusInput ()
                        )

                Datalist ->
                    ( model, focusInput () )

        BringInputOutOfFocus ->
            if isRightSlotTransitioning model.rightSlot then
                ( model, Cmd.none )

            else if isFocused model.selectionConfig then
                ( { model
                    | selectionConfig = setIsFocused False model.selectionConfig
                    , rightSlot = updateRightSlotTransitioning InFocusTransition model.rightSlot
                  }
                , blurInput ()
                )

            else
                ( model, blurInput () )

        InputBlur ->
            case getOutputStyle model.selectionConfig of
                CustomHtml ->
                    let
                        optionsWithoutUnselectedCustomOptions =
                            removeUnselectedCustomOptions model.options
                                |> unhighlightSelectedOptions
                    in
                    ( { model
                        | searchString = SearchString.reset
                        , options = optionsWithoutUnselectedCustomOptions
                        , selectionConfig =
                            model.selectionConfig
                                |> setShowDropdown False
                                |> setIsFocused False
                        , rightSlot = updateRightSlotTransitioning NotInFocusTransition model.rightSlot
                      }
                        |> updateModelWithChangesThatEffectTheOptionsWhenTheSearchStringChanges
                    , Cmd.batch
                        [ inputBlurred ()
                        , Task.perform
                            (\_ ->
                                UpdateOptionsWithSearchString
                                    |> provideInput
                                    |> MsgQuietUpdateOptionsWithSearchString
                            )
                            (Task.succeed
                                always
                            )
                        ]
                    )

                Datalist ->
                    ( { model
                        | selectionConfig = setIsFocused False model.selectionConfig
                      }
                    , Cmd.batch
                        [ inputBlurred ()
                        ]
                    )

        InputFocus ->
            case getOutputStyle model.selectionConfig of
                CustomHtml ->
                    ( { model
                        | selectionConfig =
                            model.selectionConfig
                                |> setShowDropdown True
                                |> setIsFocused True
                        , rightSlot = updateRightSlotTransitioning NotInFocusTransition model.rightSlot
                      }
                    , Cmd.none
                    )

                Datalist ->
                    ( { model
                        | selectionConfig = setIsFocused True model.selectionConfig
                      }
                    , Cmd.none
                    )

        DropdownMouseOverOption optionValue ->
            let
                updatedOptions =
                    model.options
                        |> highlightOptionInListByValue optionValue
            in
            ( { model
                | options = updatedOptions
              }
                |> updateModelWithChangesThatEffectTheOptionsWhenTheMouseMoves
            , Cmd.none
            )

        DropdownMouseOutOption optionValue ->
            let
                updatedOptions =
                    removeHighlightOptionInList optionValue model.options
            in
            ( { model
                | options = updatedOptions
              }
                |> updateModelWithChangesThatEffectTheOptionsWhenTheMouseMoves
            , Cmd.none
            )

        DropdownMouseClickOption optionValue ->
            let
                updatedOptions =
                    case model.selectionConfig of
                        MultiSelectConfig _ _ _ ->
                            selectOptionInListByOptionValue optionValue model.options

                        SingleSelectConfig _ _ _ ->
                            selectSingleOptionInList optionValue model.options
            in
            case model.selectionConfig of
                SingleSelectConfig _ _ _ ->
                    ( { model
                        | options = updatedOptions
                        , searchString = SearchString.reset
                      }
                        |> updateModelWithChangesThatEffectTheOptionsWhenTheSearchStringChanges
                    , Cmd.batch
                        [ makeCommandMessagesWhenValuesChanges updatedOptions (Just optionValue)
                        , blurInput ()
                        ]
                    )

                MultiSelectConfig _ _ _ ->
                    ( { model
                        | options = updatedOptions
                        , searchString = SearchString.reset
                      }
                        |> updateModelWithChangesThatEffectTheOptionsWhenTheSearchStringChanges
                    , Cmd.batch
                        [ makeCommandMessagesWhenValuesChanges updatedOptions (Just optionValue)
                        , focusInput ()
                        ]
                    )

        UpdateSearchString searchString ->
            ( { model
                | searchString = SearchString.new searchString
              }
            , Cmd.batch
                [ inputKeyUp searchString
                , Task.perform
                    (\_ ->
                        UpdateOptionsWithSearchString
                            |> provideInput
                            |> MsgQuietUpdateOptionsWithSearchString
                    )
                    (Task.succeed
                        always
                    )
                ]
            )

        UpdateOptionValueValue selectedValueIndex valueString ->
            let
                updatedOptions =
                    updateDatalistOptionsWithValue
                        (OptionValue.stringToOptionValue valueString)
                        selectedValueIndex
                        model.options

                maybeSelectedOptionValue =
                    Just (OptionValue.stringToOptionValue valueString)
            in
            ( { model
                | options = updatedOptions
                , rightSlot = updateRightSlot model.rightSlot model.selectionConfig True (updatedOptions |> selectedOptions)
              }
            , makeCommandMessagesWhenValuesChanges
                (updatedOptions |> selectedOptions |> OptionsUtilities.cleanupEmptySelectedOptions)
                maybeSelectedOptionValue
            )

        UpdateOptionsWithSearchString ->
            ( updateModelWithChangesThatEffectTheOptionsWhenTheSearchStringChanges model, searchOptionsWithWebWorker (SearchString.toString model.searchString) )

        MsgQuietUpdateOptionsWithSearchString subMsg ->
            Debouncer.Messages.update update updateDebouncer subMsg model

        TextInputOnInput inputString ->
            ( { model
                | searchString = SearchString.new inputString
                , options = updateOrAddCustomOption (SearchString.new inputString) model.selectionConfig model.options
              }
            , inputKeyUp inputString
            )

        ValueChanged valuesJson ->
            let
                valuesResult =
                    case SelectionMode.getSelectionMode model.selectionConfig of
                        SelectionMode.SingleSelect ->
                            Json.Decode.decodeValue valueDecoder valuesJson

                        SelectionMode.MultiSelect ->
                            Json.Decode.decodeValue valuesDecoder valuesJson
            in
            case valuesResult of
                Ok values ->
                    case SelectionMode.getOutputStyle model.selectionConfig of
                        CustomHtml ->
                            let
                                newOptions =
                                    addAndSelectOptionsInOptionsListByString
                                        values
                                        model.options
                            in
                            ( { model
                                | options = newOptions
                              }
                                |> updateModelWithChangesThatEffectTheOptionsWhenTheSearchStringChanges
                            , Cmd.none
                            )

                        Datalist ->
                            ( model, Cmd.none )

                Err error ->
                    ( model, errorMessage (Json.Decode.errorToString error) )

        OptionsReplaced newOptionsJson ->
            case Json.Decode.decodeValue (Option.optionsDecoder (SelectionMode.getOutputStyle model.selectionConfig)) newOptionsJson of
                Ok newOptions ->
                    let
                        newOptionWithOldSelectedOption =
                            replaceOptions
                                model.selectionConfig
                                model.options
                                newOptions
                    in
                    ( { model
                        | options = newOptionWithOldSelectedOption
                      }
                        |> updateModelWithChangesThatEffectTheOptionsWhenTheSearchStringChanges
                    , Cmd.batch
                        [ optionsUpdated True
                        , updateOptionsInWebWorker ()
                        ]
                    )

                Err error ->
                    ( model, errorMessage (Json.Decode.errorToString error) )

        AddOptions optionsJson ->
            case Json.Decode.decodeValue (Option.optionsDecoder (SelectionMode.getOutputStyle model.selectionConfig)) optionsJson of
                Ok newOptions ->
                    let
                        updatedOptions =
                            addAdditionalOptionsToOptionList model.options newOptions
                    in
                    ( { model
                        | options = updatedOptions
                        , quietSearchForDynamicInterval = makeDynamicDebouncer (List.length updatedOptions)
                      }
                        |> updateModelWithChangesThatEffectTheOptionsWhenTheSearchStringChanges
                    , Cmd.batch
                        [ optionsUpdated False
                        , updateOptionsInWebWorker ()
                        ]
                    )

                Err error ->
                    ( model, errorMessage (Json.Decode.errorToString error) )

        RemoveOptions optionsJson ->
            case Json.Decode.decodeValue (Option.optionsDecoder (SelectionMode.getOutputStyle model.selectionConfig)) optionsJson of
                Ok optionsToRemove ->
                    let
                        updatedOptions =
                            removeOptionsFromOptionList model.options optionsToRemove
                    in
                    ( { model
                        | options = updatedOptions
                        , quietSearchForDynamicInterval = makeDynamicDebouncer (List.length updatedOptions)
                      }
                        |> updateModelWithChangesThatEffectTheOptionsWhenTheSearchStringChanges
                    , Cmd.batch
                        [ optionsUpdated True
                        , updateOptionsInWebWorker ()
                        ]
                    )

                Err error ->
                    ( model, errorMessage (Json.Decode.errorToString error) )

        SelectOption optionJson ->
            case Json.Decode.decodeValue (Option.decoder (SelectionMode.getOutputStyle model.selectionConfig)) optionJson of
                Ok option ->
                    let
                        optionValue =
                            Option.getOptionValue option

                        updatedOptions =
                            case model.selectionConfig of
                                MultiSelectConfig _ _ _ ->
                                    selectOptionInListByOptionValue optionValue model.options

                                SingleSelectConfig _ _ _ ->
                                    selectSingleOptionInList optionValue model.options
                    in
                    ( { model
                        | options = updatedOptions
                      }
                        |> updateModelWithChangesThatEffectTheOptionsWhenTheSearchStringChanges
                    , Cmd.batch
                        [ makeCommandMessagesWhenValuesChanges updatedOptions (Just optionValue)
                        , updateOptionsInWebWorker ()
                        , Task.perform
                            (\_ ->
                                UpdateOptionsWithSearchString
                                    |> provideInput
                                    |> MsgQuietUpdateOptionsWithSearchString
                            )
                            (Task.succeed
                                always
                            )
                        ]
                    )

                Err error ->
                    ( model, errorMessage (Json.Decode.errorToString error) )

        DeselectOptionInternal optionToDeselect ->
            deselectOption model optionToDeselect

        DeselectOption optionJson ->
            case Json.Decode.decodeValue (Option.decoder (SelectionMode.getOutputStyle model.selectionConfig)) optionJson of
                Ok option ->
                    deselectOption model option

                Err error ->
                    ( model, errorMessage (Json.Decode.errorToString error) )

        OptionSortingChanged sortingString ->
            case stringToOptionSort sortingString of
                Ok optionSorting ->
                    ( { model | optionSort = optionSorting }, Cmd.none )

                Err error ->
                    ( model, errorMessage error )

        PlaceholderAttributeChanged newPlaceholder ->
            ( { model | placeholder = newPlaceholder }, Cmd.none )

        LoadingAttributeChanged bool ->
            ( { model
                | rightSlot =
                    updateRightSlotLoading
                        bool
                        model.selectionConfig
                        (hasSelectedOption model.options)
              }
            , Cmd.none
            )

        MaxDropdownItemsChanged int ->
            let
                maxDropdownItems =
                    FixedMaxDropdownItems (PositiveInt.new int)
            in
            ( { model
                | selectionConfig = setMaxDropdownItems maxDropdownItems model.selectionConfig
              }
                |> updateModelWithChangesThatEffectTheOptionsWhenTheSearchStringChanges
            , Cmd.none
            )

        ShowDropdownFooterChanged bool ->
            let
                newDropdownStyle =
                    if bool then
                        ShowFooter

                    else
                        NoFooter
            in
            ( { model
                | selectionConfig = setDropdownStyle newDropdownStyle model.selectionConfig
              }
            , Cmd.none
            )

        AllowCustomOptionsChanged ( canAddCustomOptions, customOptionHint ) ->
            let
                maybeCustomOptionHint =
                    case customOptionHint of
                        "" ->
                            Nothing

                        _ ->
                            Just customOptionHint
            in
            ( { model
                | selectionConfig =
                    SelectionMode.setAllowCustomOptionsWithBool
                        canAddCustomOptions
                        maybeCustomOptionHint
                        model.selectionConfig
              }
            , Cmd.none
            )

        DisabledAttributeChanged bool ->
            ( { model | selectionConfig = setIsDisabled bool model.selectionConfig }, Cmd.none )

        SelectedItemStaysInPlaceChanged selectedItemStaysInPlace ->
            ( { model
                | selectionConfig =
                    setSelectedItemStaysInPlaceWithBool
                        selectedItemStaysInPlace
                        model.selectionConfig
              }
            , Cmd.none
            )

        OutputStyleChanged newOutputStyleString ->
            case SelectionMode.stringToOutputStyle newOutputStyleString of
                Ok outputStyle ->
                    ( { model
                        | selectionConfig =
                            SelectionMode.setOutputStyle
                                outputStyle
                                model.selectionConfig
                      }
                    , Cmd.none
                    )

                Err _ ->
                    -- TODO Report Error
                    ( model, Cmd.none )

        MultiSelectSingleItemRemovalAttributeChanged shouldEnableMultiSelectSingleItemRemoval ->
            let
                multiSelectSingleItemRemoval =
                    if shouldEnableMultiSelectSingleItemRemoval then
                        EnableSingleItemRemoval

                    else
                        DisableSingleItemRemoval
            in
            ( { model
                | selectionConfig = setSingleItemRemoval multiSelectSingleItemRemoval model.selectionConfig
              }
            , Cmd.batch [ muchSelectIsReady (), Cmd.none ]
            )

        MultiSelectAttributeChanged isInMultiSelectMode ->
            let
                updatedOptions =
                    if isInMultiSelectMode then
                        model.options

                    else
                        deselectAllButTheFirstSelectedOptionInList model.options

                cmd =
                    if isInMultiSelectMode then
                        Cmd.none

                    else
                        makeCommandMessagesWhenValuesChanges (selectedOptions updatedOptions) Nothing
            in
            ( { model
                | selectionConfig = SelectionMode.setMultiSelectModeWithBool isInMultiSelectMode model.selectionConfig
                , options = updatedOptions
              }
                |> updateModelWithChangesThatEffectTheOptionsWhenTheSearchStringChanges
            , Cmd.batch
                [ muchSelectIsReady ()
                , updateOptionsInWebWorker ()
                , cmd
                ]
            )

        SearchStringMinimumLengthAttributeChanged searchStringMinimumLength ->
            ( { model
                | selectionConfig =
                    setSearchStringMinimumLength
                        (FixedSearchStringMinimumLength (PositiveInt.new searchStringMinimumLength))
                        model.selectionConfig
              }
                |> updateModelWithChangesThatEffectTheOptionsWhenTheSearchStringChanges
            , Cmd.none
            )

        SelectHighlightedOption ->
            let
                maybeHighlightedOptionValue =
                    findHighlightedOption model.options |> Maybe.map Option.getOptionValue

                updatedOptions =
                    selectHighlightedOption model.selectionConfig model.options
            in
            case model.selectionConfig of
                SingleSelectConfig _ _ _ ->
                    ( { model
                        | options = updatedOptions
                        , searchString = SearchString.reset
                      }
                        |> updateModelWithChangesThatEffectTheOptionsWhenTheSearchStringChanges
                    , Cmd.batch
                        [ makeCommandMessagesWhenValuesChanges updatedOptions maybeHighlightedOptionValue
                        , updateOptionsInWebWorker ()
                        , blurInput ()
                        ]
                    )

                MultiSelectConfig _ _ _ ->
                    ( { model
                        | options = updatedOptions
                        , searchString = SearchString.reset
                      }
                        |> updateModelWithChangesThatEffectTheOptionsWhenTheSearchStringChanges
                    , Cmd.batch
                        [ makeCommandMessagesWhenValuesChanges updatedOptions maybeHighlightedOptionValue
                        , updateOptionsInWebWorker ()
                        , focusInput ()
                        ]
                    )

        DeleteInputForSingleSelect ->
            case model.selectionConfig of
                SingleSelectConfig _ _ _ ->
                    if hasSelectedOption model.options then
                        -- if there are ANY selected options, clear them all;
                        clearAllSelectedOption model

                    else
                        ( model, Cmd.none )

                MultiSelectConfig _ _ _ ->
                    ( model, Cmd.none )

        EscapeKeyInInputFilter ->
            ( { model
                | searchString = SearchString.reset
              }
                |> updateModelWithChangesThatEffectTheOptionsWhenTheSearchStringChanges
            , blurInput ()
            )

        MoveHighlightedOptionUp ->
            let
                updatedOptions =
                    moveHighlightedOptionUp model.options (figureOutWhichOptionsToShowInTheDropdown model.selectionConfig model.options)
            in
            ( { model
                | options = updatedOptions
              }
              -- TODO This should probably not be "something"
            , scrollDropdownToElement "something"
            )

        MoveHighlightedOptionDown ->
            let
                updatedOptions =
                    moveHighlightedOptionDown model.options (figureOutWhichOptionsToShowInTheDropdown model.selectionConfig model.options)
            in
            ( { model
                | options = updatedOptions
              }
              -- TODO This should probably not be "something"
            , scrollDropdownToElement "something"
            )

        ValueCasingWidthUpdate dims ->
            ( { model | valueCasing = ValueCasing dims.width dims.height }, Cmd.none )

        ClearAllSelectedOptions ->
            clearAllSelectedOption model

        ToggleSelectedValueHighlight optionValue ->
            let
                updatedOptions =
                    toggleSelectedHighlightByOptionValue model.options optionValue
            in
            ( { model
                | options = updatedOptions
              }
                |> updateModelWithChangesThatEffectTheOptionsWhenTheSearchStringChanges
            , Cmd.none
            )

        DeleteKeydownForMultiSelect ->
            if SearchString.length model.searchString > 0 then
                ( model, Cmd.none )

            else
                let
                    updatedOptions =
                        if hasSelectedHighlightedOptions model.options then
                            deselectAllSelectedHighlightedOptions model.options

                        else
                            deselectLastSelectedOption model.options
                in
                ( { model
                    | options = updatedOptions
                  }
                    |> updateModelWithChangesThatEffectTheOptionsWhenTheSearchStringChanges
                , Cmd.batch
                    [ valueChanged (selectedOptionsToTuple updatedOptions)
                    , focusInput ()
                    ]
                )

        AddMultiSelectValue indexWhereToAdd ->
            let
                updatedOptions =
                    OptionsUtilities.addNewEmptyOptionAtIndex (indexWhereToAdd + 1) model.options
            in
            ( { model
                | focusedIndex = indexWhereToAdd + 1
                , options = updatedOptions
                , rightSlot = updateRightSlot model.rightSlot model.selectionConfig True (updatedOptions |> selectedOptions)
              }
            , makeCommandMessagesWhenValuesChanges
                (updatedOptions |> selectedOptions |> OptionsUtilities.cleanupEmptySelectedOptions)
                Nothing
            )

        RemoveMultiSelectValue indexWhereToDelete ->
            let
                updatedOptions =
                    OptionsUtilities.removeOptionFromOptionListBySelectedIndex indexWhereToDelete model.options
            in
            ( { model
                | options = updatedOptions
                , rightSlot = updateRightSlot model.rightSlot model.selectionConfig True (updatedOptions |> selectedOptions)
              }
            , makeCommandMessagesWhenValuesChanges
                (updatedOptions |> selectedOptions |> OptionsUtilities.cleanupEmptySelectedOptions)
                Nothing
            )

        RequestAllOptions ->
            ( model
            , Cmd.batch
                [ allOptions (Json.Encode.list Option.encode model.options)
                , Task.perform
                    (\_ ->
                        UpdateOptionsWithSearchString
                            |> provideInput
                            |> MsgQuietUpdateOptionsWithSearchString
                    )
                    (Task.succeed
                        always
                    )
                ]
            )

        UpdateSearchResultsForOptions updatedSearchResultsJsonValue ->
            case Json.Decode.decodeValue Option.decodeSearchResults updatedSearchResultsJsonValue of
                Ok searchResults ->
                    let
                        updatedOptions =
                            model.options
                                |> OptionsUtilities.updateOptionsWithNewSearchResults searchResults
                    in
                    ( { model
                        | options =
                            adjustHighlightedOptionAfterSearch updatedOptions
                                (figureOutWhichOptionsToShowInTheDropdown model.selectionConfig updatedOptions)
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( model, errorMessage (Json.Decode.errorToString error) )


deselectOption : Model -> Option -> ( Model, Cmd Msg )
deselectOption model option =
    let
        optionValue =
            Option.getOptionValue option

        updatedOptions =
            deselectOptionInListByOptionValue optionValue model.options
    in
    ( { model
        | options = updatedOptions
      }
        |> updateModelWithChangesThatEffectTheOptionsWhenTheSearchStringChanges
    , Cmd.batch
        [ makeCommandMessagesWhenValuesChanges updatedOptions Nothing
        , updateOptionsInWebWorker ()
        ]
    )


clearAllSelectedOption : Model -> ( Model, Cmd Msg )
clearAllSelectedOption model =
    let
        deselectedItems =
            if List.isEmpty <| selectedOptionsToTuple model.options then
                -- no deselected options
                []

            else
                -- an option has been deselected. return the deselected value as a tuple.
                selectedOptionsToTuple model.options

        deselectEventCmdMsg =
            if List.isEmpty deselectedItems then
                Cmd.none

            else
                optionDeselected deselectedItems

        newOptions =
            deselectAllOptionsInOptionsList model.options

        focusCmdMsg =
            if isFocused model.selectionConfig then
                focusInput ()

            else
                Cmd.none
    in
    ( { model
        | options = deselectAllOptionsInOptionsList newOptions
        , rightSlot = updateRightSlot model.rightSlot model.selectionConfig False []
        , searchString = SearchString.reset
      }
    , Cmd.batch
        [ makeCommandMessagesWhenValuesChanges [] Nothing
        , deselectEventCmdMsg
        , focusCmdMsg
        ]
    )


updateModelWithChangesThatEffectTheOptionsWhenTheSearchStringChanges : Model -> Model
updateModelWithChangesThatEffectTheOptionsWhenTheSearchStringChanges model =
    updateModelWithChangesThatEffectTheOptionsWithSearchString
        model.rightSlot
        model.selectionConfig
        model.options
        model


updateModelWithChangesThatEffectTheOptionsWhenTheMouseMoves : Model -> Model
updateModelWithChangesThatEffectTheOptionsWhenTheMouseMoves model =
    updatePartOfTheModelWithChangesThatEffectTheOptionsWhenTheMouseMoves
        model.rightSlot
        model.selectionConfig
        model.options
        model


updateModelWithChangesThatEffectTheOptionsWithSearchString :
    RightSlot
    -> SelectionConfig
    -> List Option
    -> { a | options : List Option, rightSlot : RightSlot }
    -> { a | options : List Option, rightSlot : RightSlot }
updateModelWithChangesThatEffectTheOptionsWithSearchString rightSlot selectionMode options model =
    { model
        | rightSlot =
            updateRightSlot
                rightSlot
                selectionMode
                (hasSelectedOption options)
                (options |> selectedOptions)
    }


updatePartOfTheModelWithChangesThatEffectTheOptionsWhenTheMouseMoves :
    RightSlot
    -> SelectionConfig
    -> List Option
    -> { a | options : List Option, rightSlot : RightSlot }
    -> { a | options : List Option, rightSlot : RightSlot }
updatePartOfTheModelWithChangesThatEffectTheOptionsWhenTheMouseMoves rightSlot selectionMode options model =
    { model
        | rightSlot =
            updateRightSlot
                rightSlot
                selectionMode
                (hasSelectedOption options)
                (options |> selectedOptions)
    }


updateTheFullListOfOptions : SelectionConfig -> SearchString -> List Option -> List Option
updateTheFullListOfOptions selectionMode searchString options =
    options
        |> OptionSearcher.updateOptionsWithSearchStringAndCustomOption selectionMode searchString


updateTheOptionsForTheDropdown : SelectionConfig -> List Option -> List Option
updateTheOptionsForTheDropdown selectionMode options =
    options
        |> sortOptionsBySearchFilterTotalScore
        |> figureOutWhichOptionsToShowInTheDropdown selectionMode


figureOutWhichOptionsToShowInTheDropdown : SelectionConfig -> List Option -> List Option
figureOutWhichOptionsToShowInTheDropdown selectionMode options =
    let
        optionsThatCouldBeShown =
            filterOptionsToShowInDropdown selectionMode options

        lastIndexOfOptions =
            List.length optionsThatCouldBeShown - 1
    in
    case getMaxDropdownItems selectionMode of
        OutputStyle.FixedMaxDropdownItems maxDropdownItems ->
            let
                maxNumberOfDropdownItems =
                    PositiveInt.toInt maxDropdownItems
            in
            if List.length optionsThatCouldBeShown <= maxNumberOfDropdownItems then
                optionsThatCouldBeShown

            else
                case findHighlightedOrSelectedOptionIndex optionsThatCouldBeShown of
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

        OutputStyle.NoLimitToDropdownItems ->
            optionsThatCouldBeShown


updateRightSlot : RightSlot -> SelectionConfig -> Bool -> List Option -> RightSlot
updateRightSlot current selectionMode hasSelectedOption selectedOptions =
    case SelectionMode.getOutputStyle selectionMode of
        SelectionMode.CustomHtml ->
            case current of
                ShowNothing ->
                    case selectionMode of
                        SingleSelectConfig _ _ _ ->
                            ShowDropdownIndicator NotInFocusTransition

                        MultiSelectConfig _ _ _ ->
                            if hasSelectedOption then
                                ShowClearButton

                            else
                                ShowDropdownIndicator NotInFocusTransition

                ShowLoadingIndicator ->
                    ShowLoadingIndicator

                ShowDropdownIndicator transitioning ->
                    case selectionMode of
                        SingleSelectConfig _ _ _ ->
                            ShowDropdownIndicator transitioning

                        MultiSelectConfig _ _ _ ->
                            if hasSelectedOption then
                                ShowClearButton

                            else
                                ShowDropdownIndicator transitioning

                ShowClearButton ->
                    if hasSelectedOption then
                        ShowClearButton

                    else
                        ShowDropdownIndicator NotInFocusTransition

                _ ->
                    current

        SelectionMode.Datalist ->
            updateRightSlotForDatalist selectedOptions


updateRightSlotForDatalist : List Option -> RightSlot
updateRightSlotForDatalist selectedOptions =
    let
        showAddButtons =
            List.any (\option -> option |> Option.getOptionValue |> OptionValue.isEmpty |> not) selectedOptions

        showRemoveButtons =
            List.length selectedOptions > 1
    in
    if showAddButtons && not showRemoveButtons then
        ShowAddButton

    else if showAddButtons && showRemoveButtons then
        ShowAddAndRemoveButtons

    else
        ShowNothing


updateRightSlotLoading : Bool -> SelectionConfig -> Bool -> RightSlot
updateRightSlotLoading isLoading selectionMode hasSelectedOption =
    if isLoading then
        ShowLoadingIndicator

    else
        case selectionMode of
            SingleSelectConfig _ _ _ ->
                ShowDropdownIndicator NotInFocusTransition

            MultiSelectConfig _ _ _ ->
                if hasSelectedOption then
                    ShowClearButton

                else
                    ShowDropdownIndicator NotInFocusTransition


updateRightSlotTransitioning : FocusTransition -> RightSlot -> RightSlot
updateRightSlotTransitioning focusTransition rightSlot =
    case rightSlot of
        ShowDropdownIndicator _ ->
            ShowDropdownIndicator focusTransition

        _ ->
            rightSlot


isRightSlotTransitioning : RightSlot -> Bool
isRightSlotTransitioning rightSlot =
    case rightSlot of
        ShowNothing ->
            False

        ShowLoadingIndicator ->
            False

        ShowDropdownIndicator transitioning ->
            case transitioning of
                InFocusTransition ->
                    True

                NotInFocusTransition ->
                    False

        ShowClearButton ->
            False

        ShowAddButton ->
            False

        ShowAddAndRemoveButtons ->
            False


view : Model -> Html Msg
view model =
    if isSingleSelect model.selectionConfig then
        singleSelectView
            model.valueCasing
            model.selectionConfig
            model.options
            model.searchString
            model.rightSlot

    else
        multiSelectView model.valueCasing
            model.selectionConfig
            model.options
            model.searchString
            model.rightSlot


singleSelectView : ValueCasing -> SelectionConfig -> List Option -> SearchString -> RightSlot -> Html Msg
singleSelectView valueCasing selectionMode options searchString rightSlot =
    case getOutputStyle selectionMode of
        CustomHtml ->
            singleSelectViewCustomHtml
                valueCasing
                selectionMode
                options
                searchString
                rightSlot

        Datalist ->
            singleSelectViewDatalistHtml selectionMode options


multiSelectView : ValueCasing -> SelectionConfig -> List Option -> SearchString -> RightSlot -> Html Msg
multiSelectView valueCasing selectionMode options searchString rightSlot =
    case getOutputStyle selectionMode of
        CustomHtml ->
            multiSelectViewCustomHtml
                selectionMode
                options
                searchString
                rightSlot
                valueCasing

        Datalist ->
            multiSelectViewDataset
                selectionMode
                options
                rightSlot


singleSelectViewCustomHtml : ValueCasing -> SelectionConfig -> List Option -> SearchString -> RightSlot -> Html Msg
singleSelectViewCustomHtml valueCasing selectionConfig options searchString rightSlot =
    let
        hasOptionSelected =
            hasSelectedOption options

        valueStr =
            if hasOptionSelected then
                options
                    |> selectedOptionsToTuple
                    |> List.map Tuple.second
                    |> List.head
                    |> Maybe.withDefault ""

            else
                ""
    in
    div
        [ id "wrapper"
        , Html.Attributes.attribute "part" "wrapper"

        -- This stops the dropdown from flashes when the user clicks
        -- on an optgroup. And it kinda makes sense. we don't want
        --  mousedown events escaping and effecting the DOM.
        , onMouseDownStopPropagationAndPreventDefault NoOp
        ]
        [ div
            [ id "value-casing"
            , valueCasingPartsAttribute selectionConfig
            , attributeIf (not (isFocused selectionConfig)) (onMouseDown BringInputInFocus)
            , attributeIf (not (isFocused selectionConfig)) (onFocus BringInputInFocus)
            , tabIndexAttribute (isDisabled selectionConfig)
            , classList
                (valueCasingClassList selectionConfig hasOptionSelected)
            ]
            [ span
                [ id "selected-value" ]
                [ text valueStr ]
            , singleSelectCustomHtmlInputField
                searchString
                (isDisabled selectionConfig)
                (isFocused selectionConfig)
                (getPlaceholder selectionConfig)
                hasOptionSelected
            , case rightSlot of
                ShowNothing ->
                    text ""

                ShowLoadingIndicator ->
                    node "slot" [ name "loading-indicator" ] [ defaultLoadingIndicator ]

                ShowDropdownIndicator transitioning ->
                    dropdownIndicator (SelectionMode.getInteractionState selectionConfig) transitioning

                ShowClearButton ->
                    node "slot" [ name "clear-button" ] []

                ShowAddButton ->
                    text ""

                ShowAddAndRemoveButtons ->
                    text ""
            ]
        , dropdown
            selectionConfig
            options
            searchString
            valueCasing
        ]


multiSelectViewCustomHtml : SelectionConfig -> List Option -> SearchString -> RightSlot -> ValueCasing -> Html Msg
multiSelectViewCustomHtml selectionConfig options searchString rightSlot valueCasing =
    let
        hasOptionSelected =
            hasSelectedOption options

        showPlaceholder =
            not hasOptionSelected && not (isFocused selectionConfig)

        placeholderAttribute =
            if showPlaceholder then
                placeholder (getPlaceholder selectionConfig)

            else
                Html.Attributes.classList []

        inputFilter =
            input
                [ type_ "text"
                , onBlur InputBlur
                , onFocus InputFocus
                , onInput UpdateSearchString
                , onMouseDownStopPropagation NoOp
                , onMouseUpStopPropagation NoOp
                , value (SearchString.toString searchString)
                , placeholderAttribute
                , id "input-filter"
                , Html.Attributes.attribute "part" "input-filter"
                , disabled (isDisabled selectionConfig)
                , Keyboard.on Keyboard.Keydown
                    [ ( Enter, SelectHighlightedOption )
                    , ( Escape, EscapeKeyInInputFilter )
                    , ( ArrowUp, MoveHighlightedOptionUp )
                    , ( ArrowDown, MoveHighlightedOptionDown )
                    ]
                ]
                []
    in
    div
        [ id "wrapper"
        , Html.Attributes.attribute "part" "wrapper"

        -- This stops the dropdown from flashes when the user clicks
        -- on an optgroup. And it kinda makes sense. we don't want
        --  mousedown events escaping and effecting the DOM.
        , onMouseDownStopPropagationAndPreventDefault NoOp
        , classList [ ( "disabled", isDisabled selectionConfig ) ]
        ]
        [ div
            [ id "value-casing"
            , valueCasingPartsAttribute selectionConfig
            , onMouseDown BringInputInFocus
            , onFocus BringInputInFocus
            , Keyboard.on Keyboard.Keydown
                [ ( Delete, DeleteKeydownForMultiSelect )
                , ( Backspace, DeleteKeydownForMultiSelect )
                ]
            , tabIndexAttribute (isDisabled selectionConfig)
            , classList
                (valueCasingClassList selectionConfig hasOptionSelected)
            ]
            (optionsToValuesHtml options (getSingleItemRemoval selectionConfig)
                ++ [ inputFilter
                   , rightSlotHtml
                        rightSlot
                        (SelectionMode.getInteractionState selectionConfig)
                        0
                   ]
            )
        , dropdown
            selectionConfig
            options
            searchString
            valueCasing
        ]


multiSelectViewDataset : SelectionConfig -> List Option -> RightSlot -> Html Msg
multiSelectViewDataset selectionConfig options rightSlot =
    let
        hasOptionSelected =
            hasSelectedOption options

        selectedOptions =
            options |> OptionsUtilities.selectedOptions

        makeInputs : List Option -> List (Html Msg)
        makeInputs selectedOptions_ =
            case List.length selectedOptions_ of
                0 ->
                    [ multiSelectDatasetInputField
                        Nothing
                        selectionConfig
                        rightSlot
                        0
                    ]

                _ ->
                    List.map
                        (\selectedOption ->
                            multiSelectDatasetInputField
                                (Just selectedOption)
                                selectionConfig
                                rightSlot
                                (Option.getOptionSelectedIndex selectedOption)
                        )
                        selectedOptions_
    in
    div [ id "wrapper", Html.Attributes.attribute "part" "wrapper" ]
        [ div
            [ id "value-casing"
            , valueCasingPartsAttribute selectionConfig
            , classList
                (valueCasingClassList selectionConfig hasOptionSelected)
            ]
            (makeInputs selectedOptions)
        , datalist options
        ]


valueCasingClassList : SelectionConfig -> Bool -> List ( String, Bool )
valueCasingClassList selectionConfig hasOptionSelected =
    let
        isFocused_ =
            isFocused selectionConfig

        selectionModeClass =
            case SelectionMode.getSelectionMode selectionConfig of
                SelectionMode.SingleSelect ->
                    ( "single", True )

                SelectionMode.MultiSelect ->
                    ( "multi", True )

        outputStyleClass =
            case SelectionMode.getOutputStyle selectionConfig of
                SelectionMode.CustomHtml ->
                    ( "output-style-custom-html", True )

                Datalist ->
                    ( "output-style-datalist", True )

        showPlaceholder =
            case SelectionMode.getOutputStyle selectionConfig of
                CustomHtml ->
                    not hasOptionSelected && not isFocused_

                Datalist ->
                    False
    in
    [ ( "has-option-selected", hasOptionSelected )
    , ( "no-option-selected", not hasOptionSelected )
    , selectionModeClass
    , outputStyleClass
    , ( "disabled", isDisabled selectionConfig )
    , ( "focused", isFocused_ )
    , ( "not-focused", not isFocused_ )
    , ( "show-placeholder", showPlaceholder )
    ]


tabIndexAttribute disabled =
    if disabled then
        style "" ""

    else
        tabindex 0


singleSelectCustomHtmlInputField : SearchString -> Bool -> Bool -> String -> Bool -> Html Msg
singleSelectCustomHtmlInputField searchString isDisabled focused placeholder_ hasSelectedOption =
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

        partAttr =
            Html.Attributes.attribute "part" "input-filter"

        typeAttr =
            type_ "text"

        onBlurAttr =
            onBlur InputBlur

        onFocusAttr =
            onFocus InputFocus

        showPlaceholder =
            not hasSelectedOption && not focused

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
            , partAttr
            , placeholderAttribute
            ]
            []

    else if hasSelectedOption then
        input
            [ typeAttr
            , idAttr
            , partAttr
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
            , partAttr
            , onBlurAttr
            , onFocusAttr
            , onMouseDownStopPropagation NoOp
            , onMouseUpStopPropagation NoOp
            , onInput UpdateSearchString
            , value (SearchString.toString searchString)
            , placeholderAttribute
            , keyboardEvents
            ]
            []


singleSelectViewDatalistHtml : SelectionConfig -> List Option -> Html Msg
singleSelectViewDatalistHtml selectionConfig options =
    let
        maybeSelectedOption =
            OptionsUtilities.findSelectedOption options

        hasOptionSelected =
            hasSelectedOption options
    in
    div [ id "wrapper", Html.Attributes.attribute "part" "wrapper" ]
        [ div
            [ id "value-casing"
            , valueCasingPartsAttribute selectionConfig
            , tabIndexAttribute (isDisabled selectionConfig)
            , classList
                (valueCasingClassList selectionConfig hasOptionSelected)
            ]
            [ singleSelectDatasetInputField
                maybeSelectedOption
                selectionConfig
                hasOptionSelected
            ]
        , datalist options
        ]


multiSelectDatasetInputField : Maybe Option -> SelectionConfig -> RightSlot -> Int -> Html Msg
multiSelectDatasetInputField maybeOption selectionConfig rightSlot index =
    let
        idAttr =
            id ("input-value-" ++ String.fromInt index)

        classes =
            [ ( "input-value", True )
            ]

        typeAttr =
            type_ "text"

        placeholderAttribute =
            placeholder (getPlaceholder selectionConfig)

        valueString =
            case maybeOption of
                Just option ->
                    Option.getOptionValueAsString option

                Nothing ->
                    ""

        inputHtml =
            if isDisabled selectionConfig then
                input
                    [ disabled True
                    , idAttr
                    , Html.Attributes.attribute "part" "input-value"
                    , placeholderAttribute
                    , classList classes
                    ]
                    []

            else
                input
                    [ typeAttr
                    , idAttr
                    , Html.Attributes.attribute "part" "input-value"
                    , classList classes
                    , onInput (UpdateOptionValueValue index)
                    , value valueString
                    , placeholderAttribute
                    , Html.Attributes.list "datalist-options"
                    ]
                    []
    in
    div [ class "input-wrapper", Html.Attributes.attribute "part" "input-wrapper" ]
        [ inputHtml
        , rightSlotHtml rightSlot (SelectionMode.getInteractionState selectionConfig) index
        ]


singleSelectDatasetInputField : Maybe Option -> SelectionConfig -> Bool -> Html Msg
singleSelectDatasetInputField maybeOption selectionMode hasSelectedOption =
    let
        idAttr =
            id "input-value"

        partAttr =
            Html.Attributes.attribute "part" "input-value"

        typeAttr =
            type_ "text"

        onBlurAttr =
            onBlur InputBlur

        onFocusAttr =
            onFocus InputFocus

        showPlaceholder =
            not hasSelectedOption && not (isFocused selectionMode)

        placeholderAttribute =
            if showPlaceholder then
                placeholder (getPlaceholder selectionMode)

            else
                style "" ""

        valueString =
            case maybeOption of
                Just option ->
                    Option.getOptionValueAsString option

                Nothing ->
                    ""
    in
    if isDisabled selectionMode then
        input
            [ disabled True
            , idAttr
            , partAttr
            , placeholderAttribute
            ]
            []

    else
        input
            [ typeAttr
            , idAttr
            , partAttr
            , onBlurAttr
            , onFocusAttr
            , onInput (UpdateOptionValueValue 0)
            , value valueString
            , placeholderAttribute
            , Html.Attributes.list "datalist-options"
            ]
            []


dropdownIndicator : SelectionMode.InteractionState -> FocusTransition -> Html Msg
dropdownIndicator interactionState transitioning =
    case interactionState of
        SelectionMode.Disabled ->
            text ""

        _ ->
            let
                action =
                    case transitioning of
                        InFocusTransition ->
                            NoOp

                        NotInFocusTransition ->
                            if interactionState == SelectionMode.Focused then
                                BringInputOutOfFocus

                            else
                                BringInputInFocus

                classes =
                    case interactionState of
                        SelectionMode.Focused ->
                            [ ( "down", True ) ]

                        SelectionMode.Unfocused ->
                            [ ( "up", True ) ]

                        SelectionMode.Disabled ->
                            []

                partAttr =
                    case interactionState of
                        SelectionMode.Focused ->
                            Html.Attributes.attribute "part" "dropdown-indicator down"

                        SelectionMode.Unfocused ->
                            Html.Attributes.attribute "part" "dropdown-indicator up"

                        SelectionMode.Disabled ->
                            Html.Attributes.attribute "part" "dropdown-indicator"
            in
            div
                [ id "dropdown-indicator"
                , partAttr
                , classList classes
                , onMouseDownStopPropagationAndPreventDefault action
                , onMouseUpStopPropagationAndPreventDefault NoOp
                ]
                [ text "▾" ]


type alias DropdownItemEventListeners msg =
    { mouseOverMsgConstructor : OptionValue -> msg
    , mouseOutMsgConstructor : OptionValue -> msg
    , clickMsgConstructor : OptionValue -> msg
    , noOpMsgConstructor : msg
    }


dropdown : SelectionConfig -> List Option -> SearchString -> ValueCasing -> Html Msg
dropdown selectionMode options searchString (ValueCasing valueCasingWidth valueCasingHeight) =
    let
        optionsForTheDropdown =
            figureOutWhichOptionsToShowInTheDropdown selectionMode options

        optionsHtml =
            -- TODO We should probably do something different if we are in a loading state
            if List.isEmpty optionsForTheDropdown then
                [ div [ class "option disabled" ] [ node "slot" [ name "no-options" ] [ text "No available options" ] ] ]

            else if doesSearchStringFindNothing searchString (getSearchStringMinimumLength selectionMode) optionsForTheDropdown then
                [ div [ class "option disabled" ] [ node "slot" [ name "no-filtered-options" ] [ text "This filter returned no results." ] ] ]

            else
                optionsToDropdownOptions
                    { mouseOverMsgConstructor = DropdownMouseOverOption
                    , mouseOutMsgConstructor = DropdownMouseOutOption
                    , clickMsgConstructor = DropdownMouseClickOption
                    , noOpMsgConstructor = NoOp
                    }
                    selectionMode
                    optionsForTheDropdown

        dropdownFooterHtml =
            if showDropdownFooter selectionMode && List.length optionsForTheDropdown < List.length options then
                div
                    [ id "dropdown-footer"
                    , Html.Attributes.attribute "part" "dropdown-footer"
                    ]
                    [ text
                        ("showing "
                            ++ (optionsForTheDropdown |> List.length |> String.fromInt)
                            ++ " of "
                            ++ (options |> List.length |> String.fromInt)
                            ++ " options"
                        )
                    ]

            else
                text ""
    in
    if isDisabled selectionMode then
        text ""

    else
        div
            [ id "dropdown"
            , Html.Attributes.attribute "part" "dropdown"
            , classList [ ( "showing", showDropdown selectionMode ), ( "hiding", not (showDropdown selectionMode) ) ]
            , style "top"
                (String.fromFloat valueCasingHeight ++ "px")
            , style
                "width"
                (String.fromFloat valueCasingWidth ++ "px")
            ]
            (optionsHtml ++ [ dropdownFooterHtml ])


optionsToDropdownOptions :
    DropdownItemEventListeners Msg
    -> SelectionConfig
    -> List Option
    -> List (Html Msg)
optionsToDropdownOptions eventHandlers selectionMode options =
    List.concatMap (optionGroupToHtml eventHandlers selectionMode) (groupOptionsInOrder options)


optionGroupToHtml : DropdownItemEventListeners Msg -> SelectionConfig -> ( OptionGroup, List Option ) -> List (Html Msg)
optionGroupToHtml dropdownItemEventListeners selectionMode ( optionGroup, options ) =
    let
        optionGroupHtml =
            case List.head options |> Maybe.andThen Option.getMaybeOptionSearchFilter of
                Just optionSearchFilter ->
                    case Option.optionGroupToString optionGroup of
                        "" ->
                            text ""

                        _ ->
                            div
                                [ class "optgroup"
                                , Html.Attributes.attribute "part" "dropdown-optgroup"
                                ]
                                [ span [ class "optgroup-header" ]
                                    (tokensToHtml optionSearchFilter.groupTokens)
                                ]

                Nothing ->
                    case Option.optionGroupToString optionGroup of
                        "" ->
                            text ""

                        optionGroupAsString ->
                            div
                                [ class "optgroup"
                                , Html.Attributes.attribute "part" "dropdown-optgroup"
                                ]
                                [ span [ class "optgroup-header" ]
                                    [ text
                                        optionGroupAsString
                                    ]
                                ]
    in
    optionGroupHtml :: List.map (optionToDropdownOption dropdownItemEventListeners selectionMode) options


optionToDropdownOption :
    DropdownItemEventListeners Msg
    -> SelectionConfig
    -> Option
    -> Html Msg
optionToDropdownOption eventHandlers selectionConfig option =
    let
        descriptionHtml : Html Msg
        descriptionHtml =
            if option |> Option.getOptionDescription |> Option.optionDescriptionToBool then
                case Option.getMaybeOptionSearchFilter option of
                    Just optionSearchFilter ->
                        div
                            [ class "description"
                            , Html.Attributes.attribute "part" "dropdown-option-description"
                            ]
                            [ span [] (tokensToHtml optionSearchFilter.descriptionTokens)
                            ]

                    Nothing ->
                        div
                            [ class "description"
                            , Html.Attributes.attribute "part" "dropdown-option-description"
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
            div
                [ onMouseEnter (option |> Option.getOptionValue |> eventHandlers.mouseOverMsgConstructor)
                , onMouseLeave (option |> Option.getOptionValue |> eventHandlers.mouseOutMsgConstructor)
                , mousedownPreventDefault (option |> Option.getOptionValue |> eventHandlers.clickMsgConstructor)
                , onClickPreventDefault eventHandlers.noOpMsgConstructor
                , Html.Attributes.attribute "part" "dropdown-option"
                , class "option"
                , valueDataAttribute
                ]
                [ labelHtml, descriptionHtml ]

        OptionHidden ->
            text ""

        OptionSelected _ ->
            case SelectionMode.getSelectionMode selectionConfig of
                SelectionMode.SingleSelect ->
                    div
                        [ onMouseEnter (option |> Option.getOptionValue |> eventHandlers.mouseOverMsgConstructor)
                        , onMouseLeave (option |> Option.getOptionValue |> eventHandlers.mouseOutMsgConstructor)
                        , mousedownPreventDefault (option |> Option.getOptionValue |> eventHandlers.clickMsgConstructor)
                        , Html.Attributes.attribute "part" "dropdown-option selected"
                        , class "selected"
                        , class "option"
                        , valueDataAttribute
                        ]
                        [ labelHtml, descriptionHtml ]

                SelectionMode.MultiSelect ->
                    text ""

        OptionSelectedHighlighted _ ->
            case selectionConfig of
                SingleSelectConfig _ _ _ ->
                    div
                        [ onMouseEnter (option |> Option.getOptionValue |> eventHandlers.mouseOverMsgConstructor)
                        , onMouseLeave (option |> Option.getOptionValue |> eventHandlers.mouseOutMsgConstructor)
                        , mousedownPreventDefault (option |> Option.getOptionValue |> eventHandlers.clickMsgConstructor)
                        , Html.Attributes.attribute "part" "dropdown-option selected highlighted"
                        , class "selected"
                        , class "highlighted"
                        , class "option"
                        , valueDataAttribute
                        ]
                        [ labelHtml, descriptionHtml ]

                MultiSelectConfig _ _ _ ->
                    text ""

        OptionHighlighted ->
            div
                [ onMouseEnter (option |> Option.getOptionValue |> eventHandlers.mouseOverMsgConstructor)
                , onMouseLeave (option |> Option.getOptionValue |> eventHandlers.mouseOutMsgConstructor)
                , mousedownPreventDefault (option |> Option.getOptionValue |> eventHandlers.clickMsgConstructor)
                , Html.Attributes.attribute "part" "dropdown-option highlighted"
                , class "highlighted"
                , class "option"
                , valueDataAttribute
                ]
                [ labelHtml, descriptionHtml ]

        OptionDisabled ->
            div
                [ Html.Attributes.attribute "part" "dropdown-option disabled"
                , class "disabled"
                , class "option"
                , valueDataAttribute
                ]
                [ labelHtml, descriptionHtml ]


optionsToValuesHtml : List Option -> SingleItemRemoval -> List (Html Msg)
optionsToValuesHtml options enableSingleItemRemoval =
    options
        |> selectedOptions
        |> List.map (Html.Lazy.lazy2 optionToValueHtml enableSingleItemRemoval)


optionToValueHtml : SingleItemRemoval -> Option -> Html Msg
optionToValueHtml enableSingleItemRemoval option =
    let
        removalHtml =
            case enableSingleItemRemoval of
                EnableSingleItemRemoval ->
                    span [ mousedownPreventDefault <| DeselectOptionInternal option, class "remove-option" ] [ text "" ]

                DisableSingleItemRemoval ->
                    text ""

        partAttr =
            Html.Attributes.attribute "part" "value"

        highlightPartAttr =
            Html.Attributes.attribute "part" "value highlighted-value"
    in
    case option of
        Option display optionLabel optionValue _ _ _ ->
            case display of
                OptionShown ->
                    text ""

                OptionHidden ->
                    text ""

                OptionSelected _ ->
                    div
                        [ class "value"
                        , partAttr
                        ]
                        [ valueLabelHtml (OptionLabel.getLabelString optionLabel) optionValue, removalHtml ]

                OptionSelectedHighlighted _ ->
                    div
                        [ classList
                            [ ( "value", True )
                            , ( "highlighted-value", True )
                            ]
                        , highlightPartAttr
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
                        , partAttr
                        , mousedownPreventDefault
                            (ToggleSelectedValueHighlight optionValue)
                        ]
                        [ valueLabelHtml (OptionLabel.getLabelString optionLabel) optionValue, removalHtml ]

                OptionSelectedHighlighted _ ->
                    div
                        [ classList
                            [ ( "value", True )
                            , ( "highlighted-value", True )
                            ]
                        , highlightPartAttr
                        ]
                        [ valueLabelHtml (OptionLabel.getLabelString optionLabel) optionValue, removalHtml ]

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
                    div [ class "value", partAttr ] [ text (OptionLabel.getLabelString optionLabel) ]

                OptionSelectedHighlighted _ ->
                    text ""

                OptionHighlighted ->
                    text ""

                OptionDisabled ->
                    text ""

        DatalistOption _ _ ->
            text ""


valueLabelHtml : String -> OptionValue -> Html Msg
valueLabelHtml labelText optionValue =
    span
        [ class "value-label"
        , mousedownPreventDefault
            (ToggleSelectedValueHighlight optionValue)
        ]
        [ text labelText ]


datalist : List Option -> Html Msg
datalist options =
    Html.datalist
        [ Html.Attributes.id "datalist-options" ]
        (List.concatMap
            dataListOptionGroupToHtml
            (groupOptionsInOrder (options |> OptionsUtilities.unselectedOptions))
        )


dataListOptionGroupToHtml : ( OptionGroup, List Option ) -> List (Html Msg)
dataListOptionGroupToHtml ( optionGroup, options ) =
    case Option.optionGroupToString optionGroup of
        "" ->
            List.map optionToDatalistOption options

        optionGroupAsString ->
            [ optgroup
                [ Html.Attributes.attribute "label" optionGroupAsString ]
                (List.map optionToDatalistOption options)
            ]


optionToDatalistOption : Option -> Html msg
optionToDatalistOption option =
    Html.option [ Html.Attributes.value (Option.getOptionValueAsString option) ] []


rightSlotHtml : RightSlot -> SelectionMode.InteractionState -> Int -> Html Msg
rightSlotHtml rightSlot interactionState selectedIndex =
    case rightSlot of
        ShowNothing ->
            text ""

        ShowLoadingIndicator ->
            node "slot"
                [ name "loading-indicator" ]
                [ defaultLoadingIndicator ]

        ShowDropdownIndicator transitioning ->
            dropdownIndicator interactionState transitioning

        ShowClearButton ->
            div
                [ id "clear-button-wrapper"
                , Html.Attributes.attribute "part" "clear-button-wrapper"
                , onClickPreventDefaultAndStopPropagation ClearAllSelectedOptions
                ]
                [ node "slot"
                    [ name "clear-button"
                    ]
                    [ text "✕"
                    ]
                ]

        ShowAddButton ->
            div [ class "add-remove-buttons" ]
                [ div [ class "add-button-wrapper", onClick (AddMultiSelectValue selectedIndex) ]
                    [ addButtonSlot selectedIndex ]
                ]

        ShowAddAndRemoveButtons ->
            div [ class "add-remove-buttons" ]
                [ div [ class "add-button-wrapper", onClick (AddMultiSelectValue selectedIndex) ]
                    [ addButtonSlot selectedIndex ]
                , div [ class "remove-button-wrapper", onClick (RemoveMultiSelectValue selectedIndex) ]
                    [ remoteButtonSlot selectedIndex ]
                ]


defaultLoadingIndicator : Html msg
defaultLoadingIndicator =
    div [ class "default-loading-indicator" ] []


addButtonSlot : Int -> Html msg
addButtonSlot index =
    node "slot"
        [ name ("add-value-button-" ++ String.fromInt index)
        ]
        [ defaultAddButton
        ]


remoteButtonSlot : Int -> Html msg
remoteButtonSlot index =
    node "slot"
        [ name ("remove-value-button-" ++ String.fromInt index)
        ]
        [ defaultRemoveButton
        ]


defaultAddButton : Html msg
defaultAddButton =
    button [] [ text "+" ]


defaultRemoveButton : Html msg
defaultRemoveButton =
    button [] [ text "✘" ]


valueCasingPartsAttribute : SelectionMode.SelectionConfig -> Html.Attribute Msg
valueCasingPartsAttribute selectionConfig =
    let
        outputStyleStr =
            case SelectionMode.getOutputStyle selectionConfig of
                CustomHtml ->
                    "output-style-custom-html"

                Datalist ->
                    "output-style-datalist"

        selectionModeStr =
            case SelectionMode.getSelectionMode selectionConfig of
                SelectionMode.SingleSelect ->
                    "single"

                SelectionMode.MultiSelect ->
                    "multi"

        interactionStateStr =
            case SelectionMode.getInteractionState selectionConfig of
                SelectionMode.Focused ->
                    "focused"

                SelectionMode.Unfocused ->
                    "unfocused"

                SelectionMode.Disabled ->
                    "disabled"
    in
    Html.Attributes.attribute "part"
        (String.join " "
            [ "value-casing"
            , outputStyleStr
            , selectionModeStr
            , interactionStateStr
            ]
        )


makeCommandMessagesWhenValuesChanges : List Option -> Maybe OptionValue -> Cmd Msg
makeCommandMessagesWhenValuesChanges selectedOptions maybeSelectedValue =
    let
        selectedCustomOptions =
            customSelectedOptions selectedOptions

        clearCmd =
            if List.isEmpty selectedOptions then
                valueCleared ()

            else
                Cmd.none

        customOptionCmd =
            if List.isEmpty selectedCustomOptions then
                Cmd.none

            else
                customOptionSelected (optionsValues selectedCustomOptions)

        -- Any time we select a new value we need to emit an `optionSelected` event.
        optionSelectedCmd =
            case maybeSelectedValue of
                Just selectedValue ->
                    case findOptionByOptionValue selectedValue selectedOptions of
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
    , outputStyle : String
    , enableMultiSelectSingleItemRemoval : Bool
    , optionsJson : String
    , optionSort : String
    , loading : Bool
    , maxDropdownItems : Int
    , disabled : Bool
    , allowCustomOptions : Bool
    , selectedItemStaysInPlace : Bool
    , searchStringMinimumLength : Int
    , showDropdownFooter : Bool
    }


makeDynamicDebouncer : Int -> Debouncer msg
makeDynamicDebouncer numberOfOptions =
    if numberOfOptions < 100 then
        Debouncer.Messages.manual
            |> settleWhenQuietFor (Just <| fromSeconds 0.001)
            |> toDebouncer

    else if numberOfOptions < 1000 then
        Debouncer.Messages.manual
            |> settleWhenQuietFor (Just <| fromSeconds 0.1)
            |> toDebouncer

    else
        Debouncer.Messages.manual
            |> settleWhenQuietFor (Just <| fromSeconds 1)
            |> toDebouncer


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        selectionConfig =
            makeSelectionConfig flags.disabled flags.allowMultiSelect flags.allowCustomOptions flags.outputStyle flags.placeholder flags.customOptionHint flags.enableMultiSelectSingleItemRemoval flags.maxDropdownItems flags.selectedItemStaysInPlace flags.searchStringMinimumLength flags.showDropdownFooter
                |> Result.withDefault defaultSelectionConfig

        optionSort =
            stringToOptionSort flags.optionSort
                |> Result.withDefault NoSorting

        ( initialValues, initialValueErrCmd ) =
            case Json.Decode.decodeValue (Json.Decode.oneOf [ valuesDecoder, valueDecoder ]) flags.value of
                Ok values ->
                    ( values, Cmd.none )

                Err error ->
                    ( [], errorMessage (Json.Decode.errorToString error) )

        ( optionsWithInitialValueSelected, errorCmd ) =
            case Json.Decode.decodeString (Option.optionsDecoder (SelectionMode.getOutputStyle selectionConfig)) flags.optionsJson of
                Ok options ->
                    case selectionConfig of
                        SingleSelectConfig _ _ _ ->
                            case List.head initialValues of
                                Just initialValueStr_ ->
                                    if isOptionValueInListOfOptionsByValue (OptionValue.stringToOptionValue initialValueStr_) options then
                                        let
                                            optionsWithUniqueValues =
                                                options |> List.Extra.uniqueBy Option.getOptionValueAsString
                                        in
                                        ( selectOptionsInOptionsListByString
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

                        MultiSelectConfig _ _ _ ->
                            let
                                -- Don't include any empty options, that doesn't make sense.
                                optionsWithInitialValues =
                                    options
                                        |> List.filter (not << Option.isEmptyOption)
                                        |> addAndSelectOptionsInOptionsListByString initialValues
                            in
                            ( optionsWithInitialValues, Cmd.none )

                Err error ->
                    ( [], errorMessage (Json.Decode.errorToString error) )

        optionsWithInitialValueSelectedSorted =
            case SelectionMode.getOutputStyle selectionConfig of
                CustomHtml ->
                    sortOptions optionSort optionsWithInitialValueSelected

                Datalist ->
                    OptionsUtilities.organizeNewDatalistOptions optionsWithInitialValueSelected
    in
    ( { initialValue = initialValues
      , deleteKeyPressed = False
      , placeholder = flags.placeholder
      , selectionConfig = selectionConfig
      , options = optionsWithInitialValueSelectedSorted
      , optionSort = stringToOptionSort flags.optionSort |> Result.withDefault NoSorting
      , quietSearchForDynamicInterval =
            makeDynamicDebouncer (List.length optionsWithInitialValueSelectedSorted)
      , searchString = SearchString.reset
      , focusedIndex = 0
      , rightSlot =
            if flags.loading then
                ShowLoadingIndicator

            else
                case SelectionMode.getOutputStyle selectionConfig of
                    SelectionMode.CustomHtml ->
                        case SelectionMode.getSelectionMode selectionConfig of
                            SelectionMode.SingleSelect ->
                                ShowDropdownIndicator NotInFocusTransition

                            SelectionMode.MultiSelect ->
                                if hasSelectedOption optionsWithInitialValueSelected then
                                    ShowClearButton

                                else
                                    ShowDropdownIndicator NotInFocusTransition

                    Datalist ->
                        case SelectionMode.getSelectionMode selectionConfig of
                            SelectionMode.SingleSelect ->
                                ShowNothing

                            SelectionMode.MultiSelect ->
                                updateRightSlotForDatalist optionsWithInitialValueSelectedSorted

      -- TODO Should these be passed as flags?
      , valueCasing = ValueCasing 100 45
      }
    , Cmd.batch
        [ errorCmd
        , initialValueErrCmd
        , muchSelectIsReady ()
        , makeCommandMessageForInitialValue (selectedOptions optionsWithInitialValueSelected)
        , updateOptionsInWebWorker ()
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
        [ addOptionsReceiver AddOptions
        , allowCustomOptionsReceiver AllowCustomOptionsChanged
        , deselectOptionReceiver DeselectOption
        , disableChangedReceiver DisabledAttributeChanged
        , loadingChangedReceiver LoadingAttributeChanged
        , maxDropdownItemsChangedReceiver MaxDropdownItemsChanged
        , multiSelectChangedReceiver MultiSelectAttributeChanged
        , multiSelectSingleItemRemovalChangedReceiver MultiSelectSingleItemRemovalAttributeChanged
        , optionsReplacedReceiver OptionsReplaced
        , optionSortingChangedReceiver OptionSortingChanged
        , placeholderChangedReceiver PlaceholderAttributeChanged
        , removeOptionsReceiver RemoveOptions
        , requestAllOptionsReceiver (\() -> RequestAllOptions)
        , searchStringMinimumLengthChangedReceiver SearchStringMinimumLengthAttributeChanged
        , selectOptionReceiver SelectOption
        , selectedItemStaysInPlaceChangedReceiver SelectedItemStaysInPlaceChanged
        , showDropdownFooterChangedReceiver ShowDropdownFooterChanged
        , valueCasingDimensionsChangedReceiver ValueCasingWidthUpdate
        , valueChangedReceiver ValueChanged
        , outputStyleChangedReceiver OutputStyleChanged
        , updateSearchResultDataWithWebWorkerReceiver UpdateSearchResultsForOptions
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


onClickPreventDefaultAndStopPropagation : msg -> Html.Attribute msg
onClickPreventDefaultAndStopPropagation message =
    Html.Events.custom "click"
        (Json.Decode.succeed
            { message = message
            , stopPropagation = True
            , preventDefault = True
            }
        )


onMouseDownStopPropagationAndPreventDefault : msg -> Html.Attribute msg
onMouseDownStopPropagationAndPreventDefault message =
    Html.Events.custom "mousedown"
        (Json.Decode.succeed
            { message = message
            , stopPropagation = True
            , preventDefault = True
            }
        )


onMouseDownStopPropagation : msg -> Html.Attribute msg
onMouseDownStopPropagation message =
    Html.Events.custom "mousedown"
        (Json.Decode.succeed
            { message = message
            , stopPropagation = True
            , preventDefault = False
            }
        )


onMouseUpStopPropagationAndPreventDefault : msg -> Html.Attribute msg
onMouseUpStopPropagationAndPreventDefault message =
    Html.Events.custom "mouseup"
        (Json.Decode.succeed
            { message = message
            , stopPropagation = True
            , preventDefault = True
            }
        )


onMouseUpStopPropagation : msg -> Html.Attribute msg
onMouseUpStopPropagation message =
    Html.Events.custom "mouseup"
        (Json.Decode.succeed
            { message = message
            , stopPropagation = True
            , preventDefault = False
            }
        )
