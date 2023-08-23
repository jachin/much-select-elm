module DatalistOption exposing (DatalistOption, decoder, deselect, getOptionDisplay, getOptionLabel, getOptionSelectedIndex, getOptionValue, getOptionValueAsString, hasSelectedIndex, isSelected, merge, new, newSelectedDatalistOption, newSelectedDatalistOptionPendingValidation, newSelectedDatalistOptionWithErrors, select, setOptionDisplay, setOptionDisplayAge, setOptionSelectedIndex, setOptionValue)

import Json.Decode
import OptionDisplay exposing (OptionDisplay)
import OptionLabel exposing (OptionLabel)
import OptionValue exposing (OptionValue)
import TransformAndValidate exposing (ValidationFailureMessage)


type DatalistOption
    = DatalistOption OptionDisplay OptionValue


newSelectedDatalistOption : OptionValue -> Int -> DatalistOption
newSelectedDatalistOption optionValue selectedIndex =
    DatalistOption
        (OptionDisplay.selected selectedIndex)
        optionValue


newSelectedDatalistOptionWithErrors : List ValidationFailureMessage -> OptionValue -> Int -> DatalistOption
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


getOptionDisplay : DatalistOption -> OptionDisplay
getOptionDisplay datalistOption =
    case datalistOption of
        DatalistOption optionDisplay _ ->
            optionDisplay


setOptionDisplay : OptionDisplay -> DatalistOption -> DatalistOption
setOptionDisplay optionDisplay datalistOption =
    case datalistOption of
        DatalistOption _ optionValue ->
            DatalistOption optionDisplay optionValue


isSelected : DatalistOption -> Bool
isSelected datalistOption =
    datalistOption |> getOptionDisplay |> OptionDisplay.isSelected


getOptionSelectedIndex : DatalistOption -> Int
getOptionSelectedIndex datalistOption =
    datalistOption |> getOptionDisplay |> OptionDisplay.getSelectedIndex


hasSelectedIndex : Int -> DatalistOption -> Bool
hasSelectedIndex selectedItemIndex datalistOption =
    getOptionSelectedIndex datalistOption == selectedItemIndex


setOptionSelectedIndex : Int -> DatalistOption -> DatalistOption
setOptionSelectedIndex selectedItemIndex option =
    setOptionDisplay (option |> getOptionDisplay |> OptionDisplay.setSelectedIndex selectedItemIndex) option


setOptionDisplayAge : OptionDisplay.OptionAge -> DatalistOption -> DatalistOption
setOptionDisplayAge optionAge option =
    setOptionDisplay (option |> getOptionDisplay |> OptionDisplay.setAge optionAge) option


getOptionLabel : DatalistOption -> OptionLabel
getOptionLabel datalistOption =
    case datalistOption of
        DatalistOption _ optionValue ->
            optionValue |> OptionValue.optionValueToString |> OptionLabel.new


getOptionValue : DatalistOption -> OptionValue
getOptionValue datalistOption =
    case datalistOption of
        DatalistOption _ optionValue ->
            optionValue


getOptionValueAsString : DatalistOption -> String
getOptionValueAsString datalistOption =
    datalistOption |> getOptionValue |> OptionValue.optionValueToString


setOptionValue : OptionValue -> DatalistOption -> DatalistOption
setOptionValue optionValue datalistOption =
    case datalistOption of
        DatalistOption optionDisplay _ ->
            DatalistOption optionDisplay optionValue


merge : DatalistOption -> DatalistOption -> DatalistOption
merge optionA _ =
    -- TODO Seems like we should be doing more here.
    optionA


select : Int -> DatalistOption -> DatalistOption
select selectionIndex option =
    setOptionDisplay (OptionDisplay.select selectionIndex (getOptionDisplay option)) option


deselect : DatalistOption -> DatalistOption
deselect option =
    setOptionDisplay (OptionDisplay.deselect (getOptionDisplay option)) option


decoder : OptionDisplay.OptionAge -> Json.Decode.Decoder DatalistOption
decoder age =
    Json.Decode.map2 DatalistOption
        (OptionDisplay.decoder OptionDisplay.MatureOption)
        (Json.Decode.field
            "value"
            OptionValue.decoder
        )
