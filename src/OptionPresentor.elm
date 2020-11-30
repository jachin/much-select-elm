module OptionPresentor exposing
    ( OptionPresenter
    , hasDescription
    , highlightMarkup
    , indexInsideMatch
    , prepareOptionsForPresentation
    , simpleMatch
    )

import Fuzzy exposing (Result, match)
import Html exposing (Html, span, text)
import Html.Attributes exposing (class, style)
import List.Extra
import Option
    exposing
        ( Option
        , OptionDescription
        , OptionDisplay
        , OptionGroup
        , OptionLabel
        , OptionValue
        )
import Stack


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


type alias HighlightResult msg =
    { stack : Stack.Stack Char
    , result : Result
    , htmlNodes : List (Html msg)
    }


indexInsideMatch : Result -> Int -> Bool
indexInsideMatch result index =
    result.matches
        |> List.filter
            (\match ->
                match.offset
                    <= index
                    && match.offset
                    + List.length match.keys
                    > index
            )
        |> List.isEmpty
        |> not


highlightHelper : Int -> Char -> HighlightResult msg -> HighlightResult msg
highlightHelper index char highlightResult =
    let
        _ =
            Debug.log "highlightResult" highlightResult
    in
    if indexInsideMatch highlightResult.result index then
        { highlightResult | stack = Stack.push char highlightResult.stack }

    else
        let
            prevHighlight =
                if (highlightResult.stack |> Stack.toList |> List.length) > 0 then
                    span [ class "highlight" ] [ highlightResult.stack |> Stack.toList |> String.fromList |> text ]

                else
                    text ""
        in
        { highlightResult | htmlNodes = List.append highlightResult.htmlNodes [ prevHighlight, char |> String.fromChar |> text ] }


highlightMarkup : String -> Result -> Html msg
highlightMarkup hay result =
    let
        highlightResult =
            List.Extra.indexedFoldl
                highlightHelper
                { stack = Stack.initialise
                , result = result
                , htmlNodes = []
                }
                (String.toList hay)
    in
    span [] highlightResult.htmlNodes


prepareOptionsForPresentation : String -> List Option -> List (OptionPresenter msg)
prepareOptionsForPresentation searchString options =
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
                , labelMarkup = highlightMarkup (Option.getOptionLabel option |> Option.optionLabelToString) searchResult.labelMatch
                , descriptionMarkup = highlightMarkup (Option.getOptionDescription option |> Option.optionDescriptionToString) searchResult.descriptionMatch
                }
            )
        |> List.sortBy .totalScore
        |> Debug.log "searching results"


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
