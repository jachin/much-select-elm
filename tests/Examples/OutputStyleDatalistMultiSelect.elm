module Examples.OutputStyleDatalistMultiSelect exposing (suite)

import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (all, classes, id)


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


start : Flags -> ProgramTest MuchSelect.Model MuchSelect.Msg MuchSelect.Effect
start flags_ =
    element
        |> ProgramTest.start flags_


suite : Test
suite =
    describe "Example: output-style-datalist-multi-select"
        [ test "renders datalist multi-select output with expected selected values" <|
            \_ ->
                start flags
                    |> ProgramTest.expectViewHas
                        [ all
                            [ id "value-casing"
                            , classes [ "multi", "output-style-datalist" ]
                            ]
                        ]
        ]
