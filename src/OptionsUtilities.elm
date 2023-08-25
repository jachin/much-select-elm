module OptionsUtilities exposing (..)

import List.Extra
import Maybe.Extra
import Option
    exposing
        ( Option(..)
        , getOptionValue
        , getOptionValueAsString
        , isOptionValueInListOfStrings
        , newSelectedOption
        , optionToValueLabelTuple
        )
import OptionDisplay exposing (OptionDisplay(..))
import OptionSearchFilter exposing (OptionSearchFilterWithValue, OptionSearchResult)
import OptionValue
    exposing
        ( OptionValue(..)
        )
import OutputStyle exposing (SelectedItemPlacementMode(..))
import PositiveInt
import SearchString exposing (SearchString)
import SelectionMode exposing (SelectionConfig(..), SelectionMode, getSelectedItemPlacementMode)



--
--optionsValues : List Option -> List String
--optionsValues options =
--    List.map getOptionValueAsString options
--selectedOptionValuesAreEqual : List String -> List Option -> Bool
--selectedOptionValuesAreEqual valuesAsStrings options =
--    (options |> selectedOptions |> optionsValues) == valuesAsStrings
--equal : List Option -> List Option -> Bool
--equal optionsA optionsB =
--    if List.length optionsA == List.length optionsB then
--        List.map2
--            (\optionA optionB ->
--                Option.equal optionA optionB
--            )
--            optionsA
--            optionsB
--            |> List.all identity
--
--    else
--        False
