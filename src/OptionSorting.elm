module OptionSorting exposing (OptionSort(..), stringToOptionSort)


type OptionSort
    = NoSorting
    | SortByOptionLabel


stringToOptionSort : String -> Result String OptionSort
stringToOptionSort string =
    case string of
        "no-sorting" ->
            Ok NoSorting

        "by-option-label" ->
            Ok SortByOptionLabel

        _ ->
            Err ("Sorting the options by \"" ++ string ++ "\" is not supported")
