module OptionSearcher exposing (search, simpleMatch, updateOptions)

import Fuzzy exposing (Result, match)
import Option exposing (Option)
import OptionLabel exposing (optionLabelToSearchString, optionLabelToString)
import OptionPresentor exposing (tokenize)
import OptionSearchFilter exposing (OptionSearchResult)
import SelectionMode exposing (CustomOptions(..), SelectionMode)


simpleMatch : String -> String -> Result
simpleMatch needle hay =
    match [] [ " " ] needle hay


search : String -> Option -> OptionSearchResult
search string option =
    { labelMatch =
        simpleMatch
            (string |> String.toLower)
            (option
                |> Option.getOptionLabel
                |> optionLabelToSearchString
            )
    , descriptionMatch =
        simpleMatch
            (string |> String.toLower)
            (option
                |> Option.getOptionDescription
                |> Option.optionDescriptionToSearchString
            )
    }


updateOptions : SelectionMode -> String -> List Option -> List Option
updateOptions selectionMode searchString options =
    options
        |> updateOrAddCustomOption searchString selectionMode
        |> updateOptionsWithSearchString searchString


updateOrAddCustomOption : String -> SelectionMode -> List Option -> List Option
updateOrAddCustomOption searchString selectionMode options =
    case searchString of
        "" ->
            options

        _ ->
            case SelectionMode.getCustomOptions selectionMode of
                AllowCustomOptions ->
                    Option.updateOrAddCustomOption searchString options

                NoCustomOptions ->
                    options


updateOptionsWithSearchString : String -> List Option -> List Option
updateOptionsWithSearchString searchString options =
    case searchString of
        "" ->
            options
                |> List.map
                    (\option ->
                        Option.setOptionSearchFilter
                            Nothing
                            option
                    )

        _ ->
            options
                |> List.map
                    (\option ->
                        let
                            searchResult : OptionSearchResult
                            searchResult =
                                search searchString option

                            labelTokens =
                                tokenize (option |> Option.getOptionLabel |> optionLabelToString) searchResult.labelMatch

                            descriptionTokens =
                                tokenize (option |> Option.getOptionDescription |> Option.optionDescriptionToString) searchResult.descriptionMatch
                        in
                        Option.setOptionSearchFilter
                            (Just
                                (OptionSearchFilter.new
                                    (searchResult.labelMatch.score + searchResult.descriptionMatch.score)
                                    searchResult
                                    labelTokens
                                    descriptionTokens
                                )
                            )
                            option
                    )
