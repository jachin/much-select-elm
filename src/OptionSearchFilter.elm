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
    , groupMatch : Result
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
    List.minimum
        [ optionSearchResult.labelMatch.score
        , optionSearchResult.descriptionMatch.score
        , optionSearchResult.groupMatch.score
        ]
        |> Maybe.withDefault
            impossiblyLowScore


lowScoreCutOff : Int -> Int
lowScoreCutOff score =
    if score == 0 then
        10

    else if score <= 10 then
        100

    else if score <= 100 then
        1000

    else if score <= 1000 then
        10000

    else
        impossiblyLowScore
