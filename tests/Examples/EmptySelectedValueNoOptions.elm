module Examples.EmptySelectedValueNoOptions exposing (suite)

import Html.Attributes
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (attribute, classes, id, text)


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = ""
    , selectedValueEncoding = Nothing
    , placeholder = ( True, "" )
    , customOptionHint = Nothing
    , allowMultiSelect = False
    , outputStyle = "customHtml"
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
    describe "Example: empty-selected-value-no-options"
        [ test "does not crash and keeps no selection when selected-value is empty with no options" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas
                        [ id "value-casing"
                        , classes [ "no-option-selected" ]
                        ]
                    |> ProgramTest.ensureViewHas
                        [ attribute (Html.Attributes.value "") ]
                    |> ProgramTest.expectViewHas [ text "No available options" ]
        ]
