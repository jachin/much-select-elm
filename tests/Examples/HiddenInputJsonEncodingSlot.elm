module Examples.HiddenInputJsonEncodingSlot exposing (suite)

import Html.Attributes
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (attribute)


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = "%5B%22Victoria%22%2C%22Tasmania%22%5D"
    , selectedValueEncoding = Just "json"
    , placeholder = ( True, "" )
    , customOptionHint = Nothing
    , allowMultiSelect = True
    , outputStyle = "datalist"
    , enableMultiSelectSingleItemRemoval = False
    , optionsJson = "[]"
    , optionSort = ""
    , loading = False
    , maxDropdownItems = Just "10"
    , disabled = False
    , allowCustomOptions = False
    , selectedItemStaysInPlace = True
    , searchStringMinimumLength = Nothing
    , showDropdownFooter = False
    , transformationAndValidationJson = ""
    }


element =
    ProgramTest.createElement
        { init = MuchSelect.init
        , update = MuchSelect.update
        , view = MuchSelect.view
        }


start : ProgramTest MuchSelect.Model MuchSelect.Msg MuchSelect.Effect
start =
    element
        |> ProgramTest.start flags


suite : Test
suite =
    describe "Example: hidden-input-json-encoding-slot"
        [ test "writes JSON-encoded selected value to hidden input slot" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas
                        [ attribute (Html.Attributes.value "Victoria") ]
                    |> ProgramTest.expectViewHas
                        [ attribute (Html.Attributes.value "Tasmania") ]
        ]
