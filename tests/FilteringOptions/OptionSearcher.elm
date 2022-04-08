module FilteringOptions.OptionSearcher exposing (suite)

import Expect
import Main exposing (figureOutWhichOptionsToShow)
import Option
import OptionSearcher
import PositiveInt
import SelectionMode
import Test exposing (Test, describe, test)


selectionMode =
    SelectionMode.SingleSelect SelectionMode.NoCustomOptions SelectionMode.SelectedItemStaysInPlace


minervaryaPentali =
    Option.newOption "Minervarya pentali" Nothing
        |> Option.setGroupWithString "Frog"


paedophryneAmauensis =
    Option.newOption "Paedophryne Amauensis" Nothing
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
    [ minervaryaPentali, venezuelaPebbleToad, paedophryneAmauensis ]


monnies =
    [ dinar, ouguiya, pound ]


suite : Test
suite =
    describe "Filtering Search Results"
        [ describe "by option group"
            [ test "if some of the search string matches the group" <|
                \_ ->
                    Expect.equal
                        (OptionSearcher.updateOptions selectionMode Nothing "frog" (frogs ++ monnies)
                            |> figureOutWhichOptionsToShow (PositiveInt.new 10)
                            |> List.length
                        )
                        3
            ]
        ]
