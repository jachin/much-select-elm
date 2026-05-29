module Examples.OutputStyleDatalistMultiSelectWithSelectedValuesJsonValueSelected exposing (suite)

import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (all, classes, id)


optionsJson : String
optionsJson =
    """
[
  { "value": "Bionicle", "label": "Bionicle", "labelClean": "Bionicle" },
  { "value": "Pirates", "label": "Pirates", "labelClean": "Pirates" },
  { "value": "Ultra Agents", "label": "Ultra Agents", "labelClean": "Ultra Agents" },
  { "value": "Elves", "label": "Elves", "labelClean": "Elves" }
]
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = "%5B%22Pirates%22%2C%22Ultra%20Agents%22%5D"
    , selectedValueEncoding = Just "json"
    , placeholder = ( True, "" )
    , customOptionHint = Nothing
    , allowMultiSelect = True
    , outputStyle = "datalist"
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
    describe "Example: output-style-datalist-multi-select-with-selected-values-json-value-selected"
        [ test "decodes JSON selected-value and marks options selected in datalist mode" <|
            \_ ->
                start
                    |> ProgramTest.expectViewHas
                        [ all
                            [ id "value-casing"
                            , classes [ "multi", "output-style-datalist", "has-option-selected" ]
                            ]
                        ]
        ]
