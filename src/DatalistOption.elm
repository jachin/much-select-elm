module DatalistOption exposing (DatalistOption, new, newSelectedDatalistOption, newSelectedDatalistOptionPendingValidation, newSelectedDatalistOptionWithErrors)

import OptionDisplay exposing (OptionDisplay)
import OptionValue exposing (OptionValue)
import TransformAndValidate exposing (ValidationFailureMessage)


type DatalistOption
    = DatalistOption OptionDisplay OptionValue


newSelectedDatalistOption : OptionValue -> Int -> DatalistOption
newSelectedDatalistOption optionValue selectedIndex =
    DatalistOption
        (OptionDisplay.selected selectedIndex)
        optionValue


newSelectedDatalistOptionWithErrors : List ValidationFailureMessage -> OptionValue -> Int -> Option
newSelectedDatalistOptionWithErrors errors optionValue selectedIndex =
    DatalistOption
        (OptionDisplay.selectedAndInvalid selectedIndex errors)
        optionValue


newSelectedDatalistOptionPendingValidation : OptionValue -> Int -> DatalistOption
newSelectedDatalistOptionPendingValidation optionValue selectedIndex =
    DatalistOption
        (OptionDisplay.selectedAndPendingValidation selectedIndex)
        optionValue


new : OptionValue -> DatalistOption
new optionValue =
    DatalistOption
        OptionDisplay.default
        optionValue
