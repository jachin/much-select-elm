module OptionPresentor exposing
    ( OptionPresenter
    , hasDescription
    , highlightMarkup
    , prepareOptionsForPresentation
    , simpleMatch
    )

import Fuzzy exposing (Result, match)
import Html exposing (Html, span, text)
import Html.Attributes exposing (style)
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


highlightMarkup : String -> Result -> Html msg
highlightMarkup item result =
    let
        isKey index =
            List.foldl
                (\e sum ->
                    if not sum then
                        List.member (index - e.offset) e.keys

                    else
                        sum
                )
                False
                result.matches

        isMatch index =
            List.foldl
                (\e sum ->
                    if not sum then
                        e.offset <= index && (e.offset + e.length) > index

                    else
                        sum
                )
                False
                result.matches

        color index =
            if isKey index then
                Just ( "color", "red" )

            else
                Nothing

        bgColor index =
            if isMatch index then
                Just ( "background-color", "yellow" )

            else
                Nothing

        hStyle index =
            [ color index, bgColor index ]
                |> List.filterMap identity
                |> List.map (\( styleName, styleValue ) -> style styleName styleValue)

        accumulateChar c ( sum, index ) =
            ( sum ++ [ span (hStyle index) [ c |> String.fromChar |> text ] ], index + 1 )

        highlight =
            String.foldl accumulateChar ( [], 0 ) item
    in
    span [] (Tuple.first highlight)


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
