module SelectionMode exposing (CustomOptions(..), SelectionMode(..))


type CustomOptions
    = AllowCustomOptions
    | NoCustomOptions


type SelectionMode
    = SingleSelect CustomOptions
    | MultiSelect CustomOptions
