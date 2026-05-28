module Examples.EmptySelectedValueEmptySelectInput exposing (suite)

import Html.Attributes
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (attribute, classes, id)


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
    describe "Example: empty-selected-value-empty-select-input"
        [ test "clears selected state when selected-value becomes empty string" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas
                        [ id "value-casing"
                        , classes [ "no-option-selected" ]
                        ]
                    |> ProgramTest.expectViewHas
                        [ attribute (Html.Attributes.value "") ]
        ]
