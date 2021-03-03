module SelectionMode exposing (CustomOptions(..), SelectionMode(..), getCustomOptions, setAllowCustomOptionsWithBool)


type CustomOptions
    = AllowCustomOptions
    | NoCustomOptions


type SelectionMode
    = SingleSelect CustomOptions
    | MultiSelect CustomOptions


getCustomOptions : SelectionMode -> CustomOptions
getCustomOptions selectionMode =
    case selectionMode of
        SingleSelect customOptions ->
            customOptions

        MultiSelect customOptions ->
            customOptions


setAllowCustomOptionsWithBool : Bool -> SelectionMode -> SelectionMode
setAllowCustomOptionsWithBool bool mode =
    case mode of
        SingleSelect _ ->
            if bool then
                SingleSelect AllowCustomOptions

            else
                SingleSelect NoCustomOptions

        MultiSelect _ ->
            if bool then
                MultiSelect AllowCustomOptions

            else
                MultiSelect NoCustomOptions
