module RightSlot exposing (..)

{-| A type for (helping) keeping track of the focus state. While we are losing focus or while we are gaining focus we'll
be in transition.
-}

import Option exposing (Option)
import OptionValue
import SelectionMode exposing (SelectionConfig(..))


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
                    ShowDropdownIndicator NotInFocusTransition

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
updateRightSlotLoading isLoading_ selectionMode hasSelectedOption =
    if isLoading_ then
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


isLoading : RightSlot -> Bool
isLoading rightSlot =
    case rightSlot of
        ShowNothing ->
            False

        ShowLoadingIndicator ->
            True

        ShowDropdownIndicator _ ->
            False

        ShowClearButton ->
            False

        ShowAddButton ->
            False

        ShowAddAndRemoveButtons ->
            False
