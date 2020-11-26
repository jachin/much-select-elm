module OptionPresentor exposing (OptionPresenter, search)

import Fuzzy exposing (Result, match)
import Option exposing (Option)


type alias OptionPresenter =
    { option : Option
    , labelMatch : Result
    , descriptionMatch : Result
    }


search : String -> List Option -> List OptionPresenter
search string options =
    let
        simpleMatch needle hay =
            match [] [] needle hay
    in
    options
        |> List.map
            (\option ->
                { option = option
                , labelMatch =
                    simpleMatch
                        (string |> String.toLower)
                        (option |> Option.getOptionLabelString |> String.toLower)
                , descriptionMatch =
                    simpleMatch
                        (string |> String.toLower)
                        (option |> Option.getOptionDescriptionString |> String.toLower)
                }
            )
