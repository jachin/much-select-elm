module OptionsUtilities.SelectingOptions exposing (suite)

import Expect
import Option exposing (newCustomOption, newOption, selectOption)
import OptionsUtilities exposing (selectSingleOptionInListByStringOrSelectCustomValue)
import Test exposing (Test, describe, test)


slaveShip =
    newOption "Slave Ship" Nothing


desertIsland =
    newOption "Desert Island" Nothing


bootHill =
    newOption "Boot Hill" Nothing


options =
    [ slaveShip, desertIsland, bootHill ]


suite : Test
suite =
    describe "Selecting"
        [ describe "a single option or adding a custom value"
            [ test "should do nothing on an empty list of options and an empty string" <|
                \_ ->
                    Expect.equalLists
                        (selectSingleOptionInListByStringOrSelectCustomValue "" [])
                        []
            , test "should select nothing on an empty string" <|
                \_ ->
                    Expect.equalLists
                        (selectSingleOptionInListByStringOrSelectCustomValue "" [ desertIsland ])
                        [ desertIsland ]
            , test "should create a new custom option when the list of option is empty" <|
                \_ ->
                    Expect.equalLists
                        (selectSingleOptionInListByStringOrSelectCustomValue "Moon Lit Street" [])
                        [ newCustomOption "Moon Lit Street" Nothing |> selectOption 0 ]
            , test "should selected an existion option if it matches" <|
                \_ ->
                    Expect.equalLists
                        (selectSingleOptionInListByStringOrSelectCustomValue "Boot Hill" options)
                        [ slaveShip, desertIsland, bootHill |> selectOption 0 ]
            ]
        ]
