module FilteringOptions.OptionSearcher exposing (suite)

import DropdownOptions exposing (figureOutWhichOptionsToShowInTheDropdown)
import Expect
import Json.Decode
import Option exposing (test_newFancyOption)
import OptionList exposing (OptionList(..), getOptions, sortOptionsByBestScore)
import OptionSearchFilter
import OptionSearcher exposing (doesSearchStringFindNothing)
import OptionSorting exposing (sortOptionsBySearchFilterTotalScore)
import OutputStyle exposing (MaxDropdownItems(..), SearchStringMinimumLength(..))
import PositiveInt
import SearchString
import SelectionMode
import Test exposing (Test, describe, test)


selectionConfig =
    SelectionMode.defaultSelectionConfig
        |> SelectionMode.setSearchStringMinimumLength searchStringMinLengthTwo
        |> SelectionMode.setAllowCustomOptionsWithBool False Nothing


minervaryaPentali =
    test_newFancyOption "Minervarya pentali" Nothing
        |> Option.setGroupWithString "Frog"


paedophryneAmauensis =
    test_newFancyOption "Paedophryne Amauensis" Nothing
        |> Option.setGroupWithString "Frog"


glassFrog =
    test_newFancyOption "Glass Frog" Nothing
        |> Option.setGroupWithString "Frog"


venezuelaPebbleToad =
    test_newFancyOption "Venezuela Pebble Toad" Nothing
        |> Option.setGroupWithString "Frog"


dinar =
    test_newFancyOption "Dinar" Nothing
        |> Option.setGroupWithString "Money"


ouguiya =
    test_newFancyOption "Ougyiya" Nothing
        |> Option.setGroupWithString "Money"


pound =
    test_newFancyOption "Pound" Nothing
        |> Option.setGroupWithString "Money"


frogs =
    [ minervaryaPentali, venezuelaPebbleToad, paedophryneAmauensis, glassFrog ]


monnies =
    [ dinar, ouguiya, pound ]


searchStringMinLengthTwo =
    FixedSearchStringMinimumLength (PositiveInt.new 2)


suite : Test
suite =
    describe "Filtering Search Results"
        [ describe "by option group"
            [ test "if some of the search string matches the group" <|
                \_ ->
                    Expect.equal
                        (OptionSearcher.updateOptionsWithSearchStringAndCustomOption selectionConfig
                            (SearchString.update "frog")
                            (FancyOptionList (frogs ++ monnies))
                            |> figureOutWhichOptionsToShowInTheDropdown selectionConfig
                            |> DropdownOptions.length
                        )
                        4
            , test "if some of the search string matches the group we should make sure the dropdown contains just the options that should be there" <|
                \_ ->
                    Expect.equal
                        (OptionSearcher.updateOptionsWithSearchStringAndCustomOption selectionConfig
                            (SearchString.update "frog")
                            (FancyOptionList (frogs ++ monnies))
                            |> figureOutWhichOptionsToShowInTheDropdown selectionConfig
                            |> doesSearchStringFindNothing (SearchString.update "frog") searchStringMinLengthTwo
                        )
                        False
            , test "if some of the search string matches a group and a option the option should be first" <|
                \_ ->
                    Expect.equal
                        (OptionSearcher.updateOptionsWithSearchStringAndCustomOption selectionConfig
                            (SearchString.update "frog")
                            (FancyOptionList (frogs ++ monnies))
                            |> getOptions
                            |> sortOptionsBySearchFilterTotalScore
                            |> FancyOptionList
                            |> figureOutWhichOptionsToShowInTheDropdown selectionConfig
                            |> DropdownOptions.head
                            |> Maybe.map Option.getOptionValueAsString
                        )
                        (Just "Glass Frog")
            , test "if some of the search string matches a label that option should be first" <|
                \_ ->
                    Expect.equal
                        (OptionSearcher.updateOptionsWithSearchStringAndCustomOption selectionConfig
                            (SearchString.update "pent")
                            (FancyOptionList (frogs ++ monnies))
                            |> getOptions
                            |> sortOptionsBySearchFilterTotalScore
                            |> FancyOptionList
                            |> figureOutWhichOptionsToShowInTheDropdown selectionConfig
                            |> DropdownOptions.head
                            |> Maybe.map Option.getOptionValueAsString
                        )
                        (Just "Minervarya pentali")
            , test "if some of the search string matches a label that option should be first even if it's not the first option in the list" <|
                \_ ->
                    Expect.equal
                        (OptionSearcher.updateOptionsWithSearchStringAndCustomOption selectionConfig
                            (SearchString.update "yiya")
                            (FancyOptionList (frogs ++ monnies))
                            |> getOptions
                            |> sortOptionsBySearchFilterTotalScore
                            |> FancyOptionList
                            |> figureOutWhichOptionsToShowInTheDropdown selectionConfig
                            |> DropdownOptions.head
                            |> Maybe.map Option.getOptionValueAsString
                        )
                        (Just "Ougyiya")
            , test "if the search string is empty we should still have matches for the label" <|
                \_ ->
                    Expect.equal
                        (OptionSearcher.updateOptionsWithSearchStringAndCustomOption
                            (SelectionMode.setSearchStringMinimumLength NoMinimumToSearchStringLength selectionConfig)
                            SearchString.reset
                            (FancyOptionList [ pound |> Option.setDescriptionWithString "quid" ])
                            |> getOptions
                            |> List.head
                            |> Maybe.andThen Option.getMaybeOptionSearchFilter
                            |> Maybe.map .labelTokens
                            |> Maybe.map List.length
                        )
                        (Just 1)
            , test "if the search string is empty we should still have matches for the description" <|
                \_ ->
                    Expect.equal
                        (OptionSearcher.updateOptionsWithSearchStringAndCustomOption
                            (SelectionMode.setSearchStringMinimumLength NoMinimumToSearchStringLength selectionConfig)
                            SearchString.reset
                            (FancyOptionList [ pound |> Option.setDescriptionWithString "quid" ])
                            |> getOptions
                            |> List.head
                            |> Maybe.andThen Option.getMaybeOptionSearchFilter
                            |> Maybe.map .descriptionTokens
                            |> Maybe.map List.length
                        )
                        (Just 1)
            , test "if the search string is empty we should still have matches for the group" <|
                \_ ->
                    Expect.equal
                        (OptionSearcher.updateOptionsWithSearchStringAndCustomOption
                            (SelectionMode.setSearchStringMinimumLength NoMinimumToSearchStringLength selectionConfig)
                            SearchString.reset
                            (FancyOptionList [ pound |> Option.setDescriptionWithString "quid" ])
                            |> getOptions
                            |> List.head
                            |> Maybe.andThen Option.getMaybeOptionSearchFilter
                            |> Maybe.map .groupTokens
                            |> Maybe.map List.length
                        )
                        (Just 1)
            , test "if the search string is 'win' and there's an option with 'winners' and another with 'webinars' in the label the winners should win" <|
                \_ ->
                    Expect.equal
                        (OptionSearcher.updateOptionsWithSearchStringAndCustomOption
                            (SelectionMode.setSearchStringMinimumLength NoMinimumToSearchStringLength selectionConfig)
                            (SearchString.update "win")
                            (FancyOptionList
                                [ test_newFancyOption "LevelUp2021_SwagWinnersFinal" Nothing
                                , test_newFancyOption "Q2 2021 Webinar Registrants" Nothing
                                ]
                            )
                            |> sortOptionsByBestScore
                            |> getOptions
                            |> List.head
                            |> Maybe.map Option.getOptionValueAsString
                        )
                        (Just "LevelUp2021_SwagWinnersFinal")
            ]
        , describe "encoders and decoders"
            [ test "round trip for the search result encoders and decoders" <|
                \_ ->
                    Expect.ok
                        (OptionSearcher.updateOptionsWithSearchStringAndCustomOption
                            (SelectionMode.setSearchStringMinimumLength NoMinimumToSearchStringLength selectionConfig)
                            SearchString.reset
                            (FancyOptionList [ pound |> Option.setDescriptionWithString "quid" ])
                            |> getOptions
                            |> List.head
                            |> Maybe.andThen Option.getMaybeOptionSearchFilter
                            |> Maybe.map OptionSearchFilter.encode
                            |> Maybe.map (Json.Decode.decodeValue OptionSearchFilter.decode)
                            |> Maybe.map Result.toMaybe
                            |> Maybe.andThen identity
                            |> Result.fromMaybe ""
                        )
            ]
        ]
