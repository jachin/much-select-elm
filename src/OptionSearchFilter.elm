module OptionSearchFilter exposing (OptionSearchFilter, OptionSearchResult, new)

import Fuzzy exposing (Result)


type alias OptionSearchFilter =
    { totalScore : Int
    , searchResult : Maybe OptionSearchResult
    }


type alias OptionSearchResult =
    { labelMatch : Result
    , descriptionMatch : Result
    }


new : OptionSearchFilter
new =
    { totalScore = 0
    , searchResult = Nothing
    }
