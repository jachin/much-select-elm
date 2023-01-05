module SelectedValueEncoding exposing (..)


type SelectedValueEncoding
    = CommaSeperated
    | JsonEncoded


defaultSelectedValueEncoding =
    CommaSeperated


fromString : String -> Result String SelectedValueEncoding
fromString string =
    case string of
        "json" ->
            Ok JsonEncoded

        "comma" ->
            Ok CommaSeperated

        _ ->
            Err ("Invalid selected value encoding: " ++ string)
