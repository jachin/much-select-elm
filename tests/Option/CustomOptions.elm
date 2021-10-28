module Option.CustomOptions exposing (suite)

import Expect
import Option exposing (newCustomOption, newOption, removeUnselectedCustomOptions, selectOption, selectOptionInListByOptionValue, stringToOptionValue)
import Test exposing (Test, describe, test)


birchWood =
    newOption "Birch Wood" Nothing


cutCopper =
    newOption "Cut Copper" Nothing


mossyCobblestone =
    newOption "Mossy Cobblestone" Nothing


torch =
    newCustomOption "Torch" Nothing


tuff =
    newCustomOption "Tuff" Nothing


vines =
    newCustomOption "Vines" Nothing


blocks =
    [ birchWood, cutCopper, mossyCobblestone, torch, tuff, vines ]


suite : Test
suite =
    describe "Custom options"
        [ test "should be able to remove all the unselected custom options" <|
            \_ ->
                Expect.equalLists
                    (blocks
                        |> selectOptionInListByOptionValue (stringToOptionValue "Cut Copper")
                        |> selectOptionInListByOptionValue (stringToOptionValue "Tuff")
                        |> removeUnselectedCustomOptions
                    )
                    [ birchWood
                    , selectOption 0 cutCopper
                    , mossyCobblestone
                    , selectOption 1 tuff
                    ]
        ]
