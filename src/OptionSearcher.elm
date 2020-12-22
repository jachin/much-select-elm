module OptionSearcher exposing (OptionSearchResult, bestMatch, search, simpleMatch)

import Fuzzy exposing (Result, match)
import Option exposing (Option)


type alias OptionSearchResult =
    { labelMatch : Result
    , descriptionMatch : Result
    }


simpleMatch : String -> String -> Result
simpleMatch needle hay =
    match [] [ " " ] needle hay


bestMatch : String -> List Option -> Maybe Option
bestMatch string options =
    options
        |> List.sortBy
            (\option ->
                let
                    searchResult =
                        search string option
                in
                searchResult.labelMatch.score + searchResult.descriptionMatch.score
            )
        |> List.head


search : String -> Option -> OptionSearchResult
search string option =
    { labelMatch =
        simpleMatch
            (string |> String.toLower)
            (option
                |> Option.getOptionLabel
                |> Option.optionLabelToString
                |> String.toLower
            )
    , descriptionMatch =
        simpleMatch
            (string |> String.toLower)
            (option
                |> Option.getOptionDescription
                |> Option.optionDescriptionToString
                |> String.toLower
            )
    }
