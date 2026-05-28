module Examples.DisabledMuchSelect exposing (suite)

import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (classes, id)


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = "Red,Yellow"
    , selectedValueEncoding = Nothing
    , placeholder = ( True, "" )
    , customOptionHint = Nothing
    , allowMultiSelect = True
    , outputStyle = "datalist"
    , enableMultiSelectSingleItemRemoval = False
    , optionsJson = "[]"
    , optionSort = ""
    , loading = False
    , maxDropdownItems = Just "10"
    , disabled = True
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


start : Flags -> ProgramTest MuchSelect.Model MuchSelect.Msg MuchSelect.Effect
start flags_ =
    element
        |> ProgramTest.start flags_


suite : Test
suite =
    describe "Example: disabled-much-select"
        [ test "prevents interaction when component is disabled" <|
            \_ ->
                start flags
                    |> ProgramTest.ensureViewHas
                        [ id "value-casing"
                        , classes [ "disabled" ]
                        ]
                    |> ProgramTest.expectViewHasNot [ id "clear-button-wrapper" ]
        ]
