module OptionSearcher exposing (OptionSearchResult, bestMatch, replaceFancyCharacters, search, simpleMatch)

import Fuzzy exposing (Result, match)
import Option exposing (Option)
import String.Deburr exposing (deburr)
import String.Extra exposing (fromCodePoints, toCodePoints)


type alias OptionSearchResult =
    { labelMatch : Result
    , descriptionMatch : Result
    }


replaceFancyCharacters : String -> String
replaceFancyCharacters str =
    str
        |> toCodePoints
        |> List.map
            (\int ->
                if int > 127 then
                    127

                else
                    int
            )
        |> fromCodePoints
        |> Debug.log "replaceFancyCharacters"


simpleMatch : String -> String -> Result
simpleMatch needle hay =
    -- match [] [ " " ] (needle |> deburr |> replaceFancyCharacters) (hay |> deburr |> replaceFancyCharacters)
    -- match [] [ " " ] (needle |> replaceFancyCharacters) (hay |> replaceFancyCharacters)
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
