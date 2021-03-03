module OptionSearchFilter exposing (OptionSearchFilter, OptionSearchResult, new)

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


new : Int -> OptionSearchResult -> List ( Bool, String ) -> List ( Bool, String ) -> OptionSearchFilter
new totalScore searchResult labelTokens descriptionTokens =
    { totalScore = totalScore
    , searchResult = searchResult
    , labelTokens = labelTokens
    , descriptionTokens = descriptionTokens
    }
