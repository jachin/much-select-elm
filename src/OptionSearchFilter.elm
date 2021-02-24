module OptionSearchFilter exposing (OptionSearchFilter, OptionSearchResult, new)

import Fuzzy exposing (Result)


type alias OptionSearchFilter =
    { totalScore : Int
    , searchResult : OptionSearchResult
    }


type alias OptionSearchResult =
    { labelMatch : Result
    , descriptionMatch : Result
    }


new : Int -> OptionSearchResult -> OptionSearchFilter
new totalScore searchResult =
    { totalScore = totalScore
    , searchResult = searchResult
    }
