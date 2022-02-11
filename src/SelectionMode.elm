module SelectionMode exposing (CustomOptions(..), SelectedItemPlacementMode(..), SelectionMode(..), SingleItemRemoval(..), getCustomOptions, getSelectedItemPlacementMode, setAllowCustomOptionsWithBool, setMultiSelectModeWithBool, setSelectedItemStaysInPlace)


type CustomOptions
    = AllowCustomOptions
    | NoCustomOptions


type SingleItemRemoval
    = EnableSingleItemRemoval
    | DisableSingleItemRemoval


type SelectionMode
    = SingleSelect CustomOptions SelectedItemPlacementMode
    | MultiSelect CustomOptions SingleItemRemoval


type SelectedItemPlacementMode
    = SelectedItemStaysInPlace
    | SelectedItemMovesToTheTop


getCustomOptions : SelectionMode -> CustomOptions
getCustomOptions selectionMode =
    case selectionMode of
        SingleSelect customOptions _ ->
            customOptions

        MultiSelect customOptions _ ->
            customOptions


setAllowCustomOptionsWithBool : Bool -> SelectionMode -> SelectionMode
setAllowCustomOptionsWithBool bool mode =
    case mode of
        SingleSelect _ selectedItemPlacementMode ->
            if bool then
                SingleSelect AllowCustomOptions selectedItemPlacementMode

            else
                SingleSelect NoCustomOptions selectedItemPlacementMode

        MultiSelect _ singleItemRemoval ->
            if bool then
                MultiSelect AllowCustomOptions singleItemRemoval

            else
                MultiSelect NoCustomOptions singleItemRemoval


getSelectedItemPlacementMode : SelectionMode -> SelectedItemPlacementMode
getSelectedItemPlacementMode selectionMode =
    case selectionMode of
        SingleSelect _ selectedItemPlacementMode ->
            selectedItemPlacementMode

        MultiSelect _ _ ->
            SelectedItemStaysInPlace


setSelectedItemStaysInPlace : Bool -> SelectionMode -> SelectionMode
setSelectedItemStaysInPlace selectedItemStaysInPlace selectionMode =
    case selectionMode of
        SingleSelect customOptions _ ->
            if selectedItemStaysInPlace then
                SingleSelect customOptions SelectedItemStaysInPlace

            else
                SingleSelect customOptions SelectedItemMovesToTheTop

        MultiSelect _ _ ->
            selectionMode


setMultiSelectModeWithBool : Bool -> SelectionMode -> SelectionMode
setMultiSelectModeWithBool isInMultiSelectMode selectionMode =
    case selectionMode of
        SingleSelect customOptions _ ->
            if isInMultiSelectMode then
                MultiSelect customOptions DisableSingleItemRemoval

            else
                selectionMode

        MultiSelect customOptions _ ->
            if isInMultiSelectMode then
                selectionMode

            else
                SingleSelect customOptions SelectedItemStaysInPlace
