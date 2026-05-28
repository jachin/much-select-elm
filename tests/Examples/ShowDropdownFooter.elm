module Examples.ShowDropdownFooter exposing (suite)

import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (id, text)


optionsJson : String
optionsJson =
    """
[
  { "value": "A", "label": "A", "labelClean": "A" },
  { "value": "B", "label": "B", "labelClean": "B" },
  { "value": "C", "label": "C", "labelClean": "C" },
  { "value": "D", "label": "D", "labelClean": "D" }
]
"""


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
    , optionsJson = optionsJson
    , optionSort = ""
    , loading = False
    , maxDropdownItems = Just "2"
    , disabled = False
    , allowCustomOptions = False
    , selectedItemStaysInPlace = True
    , searchStringMinimumLength = Nothing
    , showDropdownFooter = True
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
    describe "Example: show-dropdown-footer"
        [ test "renders dropdown footer when show-dropdown-footer is true" <|
            \_ ->
                start flags
                    |> ProgramTest.ensureViewHas [ id "dropdown-footer" ]
                    |> ProgramTest.expectViewHas [ text "showing 2 of 4 options" ]
        ]
