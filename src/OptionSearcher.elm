module OptionSearcher exposing (doesSearchStringFindNothing, simpleMatch, updateOptionsWithSearchStringAndCustomOption, updateSearchResultInOption)

import Fuzzy exposing (Result, match)
import Option exposing (Option(..), OptionDisplay(..))
import OptionLabel exposing (optionLabelToSearchString, optionLabelToString)
import OptionPresentor exposing (tokenize)
import OptionSearchFilter exposing (OptionSearchFilter, OptionSearchResult, descriptionHandicap, groupHandicap)
import OptionsUtilities exposing (prependCustomOption, removeUnselectedCustomOptions)
import PositiveInt exposing (PositiveInt)
import SelectionMode exposing (CustomOptions(..), SelectionMode)


updateOptionsWithSearchStringAndCustomOption : SelectionMode -> Maybe String -> String -> PositiveInt -> List Option -> List Option
updateOptionsWithSearchStringAndCustomOption selectionMode maybeCustomOptionHint searchString searchStringMinimumLength options =
    options
        |> updateOrAddCustomOption maybeCustomOptionHint searchString selectionMode
        |> updateOptionsWithSearchString searchString searchStringMinimumLength


simpleMatch : String -> String -> Result
simpleMatch needle hay =
    match [] [ " " ] needle hay



{- This matcher is for the option groups. We add a penalty of 50 points because we want matches on the label and
   description to show up first.
-}


groupMatch : String -> String -> Result
groupMatch needle hay =
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
        groupMatch
            (string |> String.toLower)
            (option
                |> Option.getOptionGroup
                |> Option.optionGroupToSearchString
            )
    }


updateSearchResultInOption : String -> Option -> Option
updateSearchResultInOption searchString option =
    let
        searchResult : OptionSearchResult
        searchResult =
            search searchString option

        labelTokens =
            tokenize (option |> Option.getOptionLabel |> optionLabelToString) searchResult.labelMatch

        descriptionTokens =
            tokenize (option |> Option.getOptionDescription |> Option.optionDescriptionToString) searchResult.descriptionMatch

        groupTokens =
            tokenize (option |> Option.getOptionGroup |> Option.optionGroupToString) searchResult.groupMatch

        bestScore =
            Maybe.withDefault OptionSearchFilter.impossiblyLowScore
                (List.minimum
                    [ searchResult.labelMatch.score
                    , descriptionHandicap searchResult.descriptionMatch.score
                    , groupHandicap searchResult.groupMatch.score
                    ]
                )

        totalScore =
            List.sum
                [ searchResult.labelMatch.score
                , descriptionHandicap searchResult.descriptionMatch.score
                , groupHandicap searchResult.groupMatch.score
                ]
    in
    Option.setOptionSearchFilter
        (Just
            (OptionSearchFilter.new
                totalScore
                bestScore
                searchResult
                labelTokens
                descriptionTokens
                groupTokens
            )
        )
        option


updateOrAddCustomOption : Maybe String -> String -> SelectionMode -> List Option -> List Option
updateOrAddCustomOption maybeCustomOptionHint searchString selectionMode options =
    let
        showCustomOption =
            if String.length searchString > 0 then
                case SelectionMode.getCustomOptions selectionMode of
                    AllowCustomOptions ->
                        True

                    NoCustomOptions ->
                        False

            else
                False

        -- If we have an exact match with an existing option don't show the custom
        --  option.
        noExactOptionLabelMatch =
            options
                |> List.any
                    (\option_ ->
                        (option_
                            |> Option.getOptionLabel
                            |> optionLabelToSearchString
                        )
                            == String.toLower searchString
                            && not (Option.isCustomOption option_)
                    )
                |> not
    in
    if showCustomOption && noExactOptionLabelMatch then
        prependCustomOption
            maybeCustomOptionHint
            searchString
            (removeUnselectedCustomOptions options)

    else
        removeUnselectedCustomOptions options


updateOptionsWithSearchString : String -> PositiveInt -> List Option -> List Option
updateOptionsWithSearchString searchString searchStringMinimumLength options =
    let
        doOptionFiltering =
            PositiveInt.lessThanOrEqualTo searchStringMinimumLength (String.length searchString)
    in
    if doOptionFiltering then
        options
            |> List.map
                (updateSearchResultInOption searchString)

    else
        options
            |> List.map
                (\option ->
                    Option.setOptionSearchFilter
                        Nothing
                        option
                )


doesSearchStringFindNothing : String -> PositiveInt -> List Option -> Bool
doesSearchStringFindNothing searchString searchStringMinimumLength options =
    if String.length searchString <= PositiveInt.toInt searchStringMinimumLength then
        False

    else
        List.all
            (\option ->
                case Option.getMaybeOptionSearchFilter option of
                    Just optionSearchFilter ->
                        optionSearchFilter.bestScore > 1000

                    Nothing ->
                        False
            )
            options
