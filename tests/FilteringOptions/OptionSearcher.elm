module FilteringOptions.OptionSearcher exposing (suite)

import Expect
import Json.Decode
import Main exposing (figureOutWhichOptionsToShowInTheDropdown)
import Option
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
    Option.newOption "Minervarya pentali" Nothing
        |> Option.setGroupWithString "Frog"


paedophryneAmauensis =
    Option.newOption "Paedophryne Amauensis" Nothing
        |> Option.setGroupWithString "Frog"


glassFrog =
    Option.newOption "Glass Frog" Nothing
        |> Option.setGroupWithString "Frog"


venezuelaPebbleToad =
    Option.newOption "Venezuela Pebble Toad" Nothing
        |> Option.setGroupWithString "Frog"


dinar =
    Option.newOption "Dinar" Nothing
        |> Option.setGroupWithString "Money"


ouguiya =
    Option.newOption "Ougyiya" Nothing
        |> Option.setGroupWithString "Money"


pound =
    Option.newOption "Pound" Nothing
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
                            (SearchString.new "frog")
                            (frogs ++ monnies)
                            |> figureOutWhichOptionsToShowInTheDropdown selectionConfig
                            |> List.length
                        )
                        4
            , test "if some of the search string matches the group we should make sure the dropdown contains just the options that should be there" <|
                \_ ->
                    Expect.equal
                        (OptionSearcher.updateOptionsWithSearchStringAndCustomOption selectionConfig
                            (SearchString.new "frog")
                            (frogs ++ monnies)
                            |> figureOutWhichOptionsToShowInTheDropdown selectionConfig
                            |> doesSearchStringFindNothing (SearchString.new "frog") searchStringMinLengthTwo
                        )
                        False
            , test "if some of the search string matches a group and a option the option should be first" <|
                \_ ->
                    Expect.equal
                        (OptionSearcher.updateOptionsWithSearchStringAndCustomOption selectionConfig
                            (SearchString.new "frog")
                            (frogs ++ monnies)
                            |> sortOptionsBySearchFilterTotalScore
                            |> figureOutWhichOptionsToShowInTheDropdown selectionConfig
                            |> List.head
                            |> Maybe.map Option.getOptionValueAsString
                        )
                        (Just "Glass Frog")
            , test "if some of the search string matches a label that option should be first" <|
                \_ ->
                    Expect.equal
                        (OptionSearcher.updateOptionsWithSearchStringAndCustomOption selectionConfig
                            (SearchString.new "pent")
                            (frogs ++ monnies)
                            |> sortOptionsBySearchFilterTotalScore
                            |> figureOutWhichOptionsToShowInTheDropdown selectionConfig
                            |> List.head
                            |> Maybe.map Option.getOptionValueAsString
                        )
                        (Just "Minervarya pentali")
            , test "if some of the search string matches a label that option should be first even if it's not the first option in the list" <|
                \_ ->
                    Expect.equal
                        (OptionSearcher.updateOptionsWithSearchStringAndCustomOption selectionConfig
                            (SearchString.new "yiya")
                            (frogs ++ monnies)
                            |> sortOptionsBySearchFilterTotalScore
                            |> figureOutWhichOptionsToShowInTheDropdown selectionConfig
                            |> List.head
                            |> Maybe.map Option.getOptionValueAsString
                        )
                        (Just "Ougyiya")
            , test "if the search string is empty we should still have matches for the label" <|
                \_ ->
                    Expect.equal
                        (OptionSearcher.updateOptionsWithSearchStringAndCustomOption
                            (SelectionMode.setSearchStringMinimumLength NoMinimumToSearchStringLength selectionConfig)
                            SearchString.reset
                            [ pound |> Option.setDescriptionWithString "quid" ]
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
                            [ pound |> Option.setDescriptionWithString "quid" ]
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
                            [ pound |> Option.setDescriptionWithString "quid" ]
                            |> List.head
                            |> Maybe.andThen Option.getMaybeOptionSearchFilter
                            |> Maybe.map .groupTokens
                            |> Maybe.map List.length
                        )
                        (Just 1)
            ]
        , describe "encoders and decoders"
            [ test "round trip for the serach result encoders and decoders" <|
                \_ ->
                    Expect.ok
                        (OptionSearcher.updateOptionsWithSearchStringAndCustomOption
                            (SelectionMode.setSearchStringMinimumLength NoMinimumToSearchStringLength selectionConfig)
                            SearchString.reset
                            [ pound |> Option.setDescriptionWithString "quid" ]
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
