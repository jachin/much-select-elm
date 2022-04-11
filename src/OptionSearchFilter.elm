module OptionSearchFilter exposing (OptionSearchFilter, OptionSearchResult, impossiblyLowScore, new)

import Fuzzy exposing (Result)


type alias OptionSearchFilter =
    { totalScore : Int
    , bestScore : Int
    , searchResult : OptionSearchResult
    , labelTokens : List ( Bool, String )
    , descriptionTokens : List ( Bool, String )
    , groupTokens : List ( Bool, String )
    }


type alias OptionSearchResult =
    { labelMatch : Result
    , descriptionMatch : Result
    , groupMatch : Result
    }


impossiblyLowScore : number
impossiblyLowScore =
    1000000


new : Int -> Int -> OptionSearchResult -> List ( Bool, String ) -> List ( Bool, String ) -> List ( Bool, String ) -> OptionSearchFilter
new totalScore bestScore searchResult labelTokens descriptionTokens groupTokens =
    { totalScore = totalScore
    , bestScore = bestScore
    , searchResult = searchResult
    , labelTokens = labelTokens
    , descriptionTokens = descriptionTokens
    , groupTokens = groupTokens
    }
