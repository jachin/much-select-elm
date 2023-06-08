module RightSlot exposing (..)

{-| A type for (helping) keeping track of the focus state. While we are losing focus or while we are gaining focus we'll
be in transition.
-}

import Option exposing (Option)
import OptionValue
import SelectionMode exposing (OutputStyle, SelectionConfig(..), SelectionMode(..))


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


updateRightSlot : RightSlot -> OutputStyle -> SelectionMode -> List Option -> RightSlot
updateRightSlot current outputStyle selectionMode selectedOptions =
    let
        hasSelectedOption =
            not (List.isEmpty selectedOptions)
    in
    case outputStyle of
        SelectionMode.CustomHtml ->
            case selectionMode of
                SingleSelect ->
                    case current of
                        ShowNothing ->
                            ShowDropdownIndicator NotInFocusTransition

                        ShowLoadingIndicator ->
                            ShowLoadingIndicator

                        ShowDropdownIndicator transitioning ->
                            ShowDropdownIndicator transitioning

                        ShowClearButton ->
                            ShowDropdownIndicator NotInFocusTransition

                        ShowAddButton ->
                            ShowDropdownIndicator NotInFocusTransition

                        ShowAddAndRemoveButtons ->
                            ShowDropdownIndicator NotInFocusTransition

                MultiSelect ->
                    case current of
                        ShowNothing ->
                            if hasSelectedOption then
                                ShowClearButton

                            else
                                ShowDropdownIndicator NotInFocusTransition

                        ShowLoadingIndicator ->
                            ShowLoadingIndicator

                        ShowDropdownIndicator focusTransition ->
                            if hasSelectedOption then
                                ShowClearButton

                            else
                                ShowDropdownIndicator focusTransition

                        ShowClearButton ->
                            if hasSelectedOption then
                                ShowClearButton

                            else
                                ShowDropdownIndicator NotInFocusTransition

                        ShowAddButton ->
                            ShowDropdownIndicator NotInFocusTransition

                        ShowAddAndRemoveButtons ->
                            ShowDropdownIndicator NotInFocusTransition

        SelectionMode.Datalist ->
            case selectionMode of
                SingleSelect ->
                    case current of
                        ShowNothing ->
                            ShowNothing

                        ShowLoadingIndicator ->
                            ShowLoadingIndicator

                        ShowDropdownIndicator _ ->
                            ShowNothing

                        ShowClearButton ->
                            ShowNothing

                        ShowAddButton ->
                            ShowNothing

                        ShowAddAndRemoveButtons ->
                            ShowNothing

                MultiSelect ->
                    let
                        showAddButtons =
                            List.any (\option -> option |> Option.getOptionValue |> OptionValue.isEmpty |> not) selectedOptions

                        showRemoveButtons =
                            List.length selectedOptions > 1

                        addAndRemoveButtonState =
                            if showAddButtons && not showRemoveButtons then
                                ShowAddButton

                            else if showAddButtons && showRemoveButtons then
                                ShowAddAndRemoveButtons

                            else
                                ShowNothing
                    in
                    case current of
                        ShowNothing ->
                            addAndRemoveButtonState

                        ShowLoadingIndicator ->
                            ShowLoadingIndicator

                        ShowDropdownIndicator _ ->
                            addAndRemoveButtonState

                        ShowClearButton ->
                            addAndRemoveButtonState

                        ShowAddButton ->
                            addAndRemoveButtonState

                        ShowAddAndRemoveButtons ->
                            addAndRemoveButtonState


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
