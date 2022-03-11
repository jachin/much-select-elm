module OptionSearcher exposing (simpleMatch, updateOptions)

import Fuzzy exposing (Result, match)
import Option exposing (Option)
import OptionLabel exposing (optionLabelToSearchString, optionLabelToString)
import OptionPresentor exposing (tokenize)
import OptionSearchFilter exposing (OptionSearchResult)
import SelectionMode exposing (CustomOptions(..), SelectionMode)


updateOptions : SelectionMode -> Maybe String -> String -> List Option -> List Option
updateOptions selectionMode maybeCustomOptionHint searchString options =
    options
        |> updateOrAddCustomOption maybeCustomOptionHint searchString selectionMode
        |> updateOptionsWithSearchString searchString


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
    , groupMatch =
        simpleMatch
            (string |> String.toLower)
            (option
                |> Option.getOptionGroup
                |> Option.optionGroupToSearchString
            )
    }


updateOrAddCustomOption : Maybe String -> String -> SelectionMode -> List Option -> List Option
updateOrAddCustomOption maybeCustomOptionHint searchString selectionMode options =
    case searchString of
        "" ->
            options

        _ ->
            case SelectionMode.getCustomOptions selectionMode of
                AllowCustomOptions ->
                    Option.updateOrAddCustomOption maybeCustomOptionHint searchString options

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

                            score =
                                if searchResult.labelMatch.score < searchResult.descriptionMatch.score then
                                    searchResult.labelMatch.score

                                else
                                    searchResult.descriptionMatch.score
                        in
                        Option.setOptionSearchFilter
                            (Just
                                (OptionSearchFilter.new
                                    score
                                    searchResult
                                    labelTokens
                                    descriptionTokens
                                )
                            )
                            option
                    )
