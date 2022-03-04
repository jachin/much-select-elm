module OptionSearchFilter exposing (OptionSearchFilter, OptionSearchResult, getLowScore, impossiblyLowScore, lowScoreCutOff, new)

import Fuzzy exposing (Result)


type alias OptionSearchFilter =
    { totalScore : Int
    , searchResult : OptionSearchResult
    , labelTokens : List ( Bool, String )
    , descriptionTokens : List ( Bool, String )
    }


type alias OptionSearchResult =
    { labelMatch : Result
    , descriptionMatch : Result
    }


impossiblyLowScore : number
impossiblyLowScore =
    1000000


new : Int -> OptionSearchResult -> List ( Bool, String ) -> List ( Bool, String ) -> OptionSearchFilter
new totalScore searchResult labelTokens descriptionTokens =
    { totalScore = totalScore
    , searchResult = searchResult
    , labelTokens = labelTokens
    , descriptionTokens = descriptionTokens
    }


getLowScore : OptionSearchResult -> Int
getLowScore optionSearchResult =
    if optionSearchResult.labelMatch.score < optionSearchResult.descriptionMatch.score then
        optionSearchResult.labelMatch.score

    else
        optionSearchResult.descriptionMatch.score


lowScoreCutOff : Int -> Int
lowScoreCutOff score =
    if score == 0 then
        0

    else if score <= 10 then
        10

    else if score <= 100 then
        100

    else if score <= 1000 then
        1000

    else
        impossiblyLowScore
