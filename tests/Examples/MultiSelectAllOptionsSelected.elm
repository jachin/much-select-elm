module Examples.MultiSelectAllOptionsSelected exposing (suite)

import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (classes, text)


optionsJson : String
optionsJson =
    """
[
  { "value": "Bob Belcher", "label": "Bob Belcher", "labelClean": "Bob Belcher" },
  { "value": "Linda Belcher", "label": "Linda Belcher", "labelClean": "Linda Belcher" },
  { "value": "Tina Belcher", "label": "Tina Belcher", "labelClean": "Tina Belcher" },
  { "value": "Gene Belcher", "label": "Gene Belcher", "labelClean": "Gene Belcher" },
  { "value": "Louise Belcher", "label": "Louise Belcher", "labelClean": "Louise Belcher" }
]
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = "Bob Belcher,Linda Belcher,Tina Belcher,Gene Belcher,Louise Belcher"
    , selectedValueEncoding = Nothing
    , placeholder = ( True, "" )
    , customOptionHint = Nothing
    , allowMultiSelect = True
    , outputStyle = "customHtml"
    , enableMultiSelectSingleItemRemoval = False
    , optionsJson = optionsJson
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


start : ProgramTest MuchSelect.Model MuchSelect.Msg MuchSelect.Effect
start =
    ProgramTest.createElement
        { init = MuchSelect.init
        , update = MuchSelect.update
        , view = MuchSelect.view
        }
        |> ProgramTest.start flags


suite : Test
suite =
    describe "Example: multi-select-all-options-selected"
        [ test "shows all-options-selected message when every option is selected" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas [ classes [ "multi" ] ]
                    |> ProgramTest.expectViewHas [ text "All options are selected" ]
        ]
