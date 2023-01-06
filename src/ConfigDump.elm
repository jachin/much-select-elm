module ConfigDump exposing (..)

import Json.Encode
import OptionSorting exposing (OptionSort)
import OutputStyle exposing (CustomOptions(..))
import RightSlot exposing (RightSlot)
import SelectedValueEncoding exposing (SelectedValueEncoding)
import SelectionMode exposing (SelectionConfig, getCustomOptions)


encodeConfig : SelectionConfig -> OptionSort -> SelectedValueEncoding -> RightSlot -> Json.Encode.Value
encodeConfig selectionConfig optionSort selectedValueEncoding rightSlot =
    Json.Encode.object
        [ ( "allows-custom-options"
          , Json.Encode.bool
                (case getCustomOptions selectionConfig of
                    AllowCustomOptions _ _ ->
                        True

                    NoCustomOptions ->
                        False
                )
          )
        , ( "disabled", Json.Encode.bool (SelectionMode.isDisabled selectionConfig) )
        , ( "events-only", Json.Encode.bool (SelectionMode.isEventsOnly selectionConfig) )
        , ( "loading", Json.Encode.bool (RightSlot.isLoading rightSlot) )
        , ( "multi-select"
          , Json.Encode.bool
                (case SelectionMode.getSelectionMode selectionConfig of
                    SelectionMode.MultiSelect ->
                        True

                    SelectionMode.SingleSelect ->
                        False
                )
          )
        , ( "option-sort"
          , Json.Encode.string (OptionSorting.toString optionSort)
          )
        , ( "selected-value-encoding"
          , Json.Encode.string (SelectedValueEncoding.toString selectedValueEncoding)
          )
        , ( "show-dropdown-footer"
          , Json.Encode.bool (SelectionMode.showDropdownFooter selectionConfig)
          )
        ]
