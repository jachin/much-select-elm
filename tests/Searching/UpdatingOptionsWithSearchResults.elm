module Searching.UpdatingOptionsWithSearchResults exposing (suite)

import DropdownOptions
import Expect
import Json.Decode
import Maybe.Extra
import Option exposing (test_newFancyOption)
import OptionDisplay
import OptionList exposing (test_newFancyOptionList)
import OptionSearchFilter exposing (OptionSearchFilterWithValue)
import OptionSearcher
import OptionValue
import OutputStyle
import SearchString
import Test exposing (Test, describe, test)


options =
    test_newFancyOptionList
        [ test_newFancyOption "C++"
        , test_newFancyOption "Objective-C"
        , test_newFancyOption "C"
        ]


results : List OptionSearchFilterWithValue
results =
    [ { value = OptionValue.stringToOptionValue "Nam Commodi Tempore Fuga Eos Impedit Qui"
      , maybeSearchFilter =
            Just
                (OptionSearchFilter.new 10 23 [] [] [])
      }
    , { value = OptionValue.stringToOptionValue "Et Reprehenderit Optio Et"
      , maybeSearchFilter = Nothing
      }
    , { value = OptionValue.stringToOptionValue "Magni Omnis Et"
      , maybeSearchFilter = Nothing
      }
    ]


suite : Test
suite =
    describe "Searching through lots of options"
        [ test "The labels tokens should have the right highlights" <|
            \_ ->
                let
                    searchString =
                        SearchString.new "ob" False

                    newOptions =
                        OptionSearcher.updateOptionsWithSearchString searchString
                            OutputStyle.NoMinimumToSearchStringLength
                            options

                    optionsToSend =
                        DropdownOptions.filterOptionsToShowInDropdownBySearchScore newOptions

                    searchResultsJson =
                        OptionList.encodeSearchResults optionsToSend
                            0
                            False

                    searchResults =
                        Json.Decode.decodeValue Option.decodeSearchResults
                            searchResultsJson
                            |> Result.withDefault
                                (Option.SearchResults [] 0 False)
                in
                Expect.equal
                    (options
                        |> OptionList.updateOptionsWithNewSearchResults searchResults.optionSearchFilters
                        |> OptionList.setAge OptionDisplay.MatureOption
                    )
                    options
        ]
