module SelectionMode exposing (CustomOptions(..), SelectedItemPlacementMode(..), SelectionMode(..), getCustomOptions, getSelectedItemPlacementMode, setAllowCustomOptionsWithBool, setMultiSelectModeWithBool, setSelectedItemStaysInPlace)


type CustomOptions
    = AllowCustomOptions
    | NoCustomOptions


type SelectionMode
    = SingleSelect CustomOptions SelectedItemPlacementMode
    | MultiSelect CustomOptions


type SelectedItemPlacementMode
    = SelectedItemStaysInPlace
    | SelectedItemMovesToTheTop


getCustomOptions : SelectionMode -> CustomOptions
getCustomOptions selectionMode =
    case selectionMode of
        SingleSelect customOptions _ ->
            customOptions

        MultiSelect customOptions ->
            customOptions


setAllowCustomOptionsWithBool : Bool -> SelectionMode -> SelectionMode
setAllowCustomOptionsWithBool bool mode =
    case mode of
        SingleSelect _ selectedItemPlacementMode ->
            if bool then
                SingleSelect AllowCustomOptions selectedItemPlacementMode

            else
                SingleSelect NoCustomOptions selectedItemPlacementMode

        MultiSelect _ ->
            if bool then
                MultiSelect AllowCustomOptions

            else
                MultiSelect NoCustomOptions


getSelectedItemPlacementMode : SelectionMode -> SelectedItemPlacementMode
getSelectedItemPlacementMode selectionMode =
    case selectionMode of
        SingleSelect _ selectedItemPlacementMode ->
            selectedItemPlacementMode

        MultiSelect _ ->
            SelectedItemStaysInPlace


setSelectedItemStaysInPlace : Bool -> SelectionMode -> SelectionMode
setSelectedItemStaysInPlace selectedItemStaysInPlace selectionMode =
    case selectionMode of
        SingleSelect customOptions _ ->
            if selectedItemStaysInPlace then
                SingleSelect customOptions SelectedItemStaysInPlace

            else
                SingleSelect customOptions SelectedItemMovesToTheTop

        MultiSelect _ ->
            selectionMode


setMultiSelectModeWithBool : Bool -> SelectionMode -> SelectionMode
setMultiSelectModeWithBool isInMultiSelectMode selectionMode =
    case selectionMode of
        SingleSelect customOptions _ ->
            if isInMultiSelectMode then
                MultiSelect customOptions

            else
                selectionMode

        MultiSelect customOptions ->
            if isInMultiSelectMode then
                selectionMode

            else
                SingleSelect customOptions SelectedItemStaysInPlace
