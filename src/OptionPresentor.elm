module OptionPresentor exposing
    ( OptionPresenter
    , hasDescription
    , prepareOptionsForPresentation
    )

import Fuzzy exposing (Result, match)
import Html exposing (Html, text)
import Option
    exposing
        ( Option
        , OptionDescription
        , OptionDisplay
        , OptionGroup
        , OptionLabel
        , OptionValue
        )


type alias OptionPresenter msg =
    { display : OptionDisplay
    , label : OptionLabel
    , value : OptionValue
    , group : OptionGroup
    , description : OptionDescription
    , searchResult : Maybe OptionSearchResult
    , totalScore : Int
    , labelMarkup : Html msg
    , descriptionMarkup : Html msg
    }


hasDescription : OptionPresenter msg -> Bool
hasDescription optionPresenter =
    Option.optionDescriptionToBool optionPresenter.description


type alias OptionSearchResult =
    { labelMatch : Result
    , descriptionMatch : Result
    }


prepareOptionsForPresentation : String -> List Option -> List (OptionPresenter msg)
prepareOptionsForPresentation searchString options =
    if String.length searchString < 3 then
        options
            |> List.map
                (\option ->
                    { display = Option.getOptionDisplay option
                    , label = Option.getOptionLabel option
                    , value = Option.getOptionValue option
                    , group = Option.getOptionGroup option
                    , description = Option.getOptionDescription option
                    , searchResult = Nothing
                    , totalScore = 0
                    , labelMarkup = text (Option.getOptionLabel option |> Option.optionLabelToString)
                    , descriptionMarkup = text (Option.getOptionDescription option |> Option.optionDescriptionToString)
                    }
                )

    else
        options
            |> List.map
                (\option ->
                    let
                        searchResult =
                            search searchString option

                        totalScore =
                            searchResult.labelMatch.score + searchResult.descriptionMatch.score
                    in
                    { display = Option.getOptionDisplay option
                    , label = Option.getOptionLabel option
                    , value = Option.getOptionValue option
                    , group = Option.getOptionGroup option
                    , description = Option.getOptionDescription option
                    , searchResult = Just searchResult
                    , totalScore = totalScore
                    , labelMarkup = text (Option.getOptionLabel option |> Option.optionLabelToString)
                    , descriptionMarkup = text (Option.getOptionDescription option |> Option.optionDescriptionToString)
                    }
                )
            |> List.sortBy .totalScore
            |> Debug.log "searching results"


search : String -> Option -> OptionSearchResult
search string option =
    let
        simpleMatch needle hay =
            match [] [] needle hay
    in
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
