module Examples.MultiSelectJsonSeperatedValues exposing (suite)

import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (classes, containing, text)


optionsJson : String
optionsJson =
    """
[
  { "value": "Gibberfish", "label": "Gibberfish", "labelClean": "Gibberfish" },
  { "value": "Hoki", "label": "Hoki", "labelClean": "Hoki" },
  { "value": "Ide", "label": "Ide", "labelClean": "Ide" },
  { "value": "Jawfish", "label": "Jawfish", "labelClean": "Jawfish" }
]
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = "%5B%22Hoki%22%2C%22Gibberfish%22%5D"
    , selectedValueEncoding = Just "json"
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
    , allowCustomOptions = True
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
    describe "Example: multi-select-json-seperated-values"
        [ test "multi-select parses JSON encoded selected-value" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas
                        [ classes [ "value", "selected-value" ]
                        , containing [ text "Hoki" ]
                        ]
                    |> ProgramTest.expectViewHas
                        [ classes [ "value", "selected-value" ]
                        , containing [ text "Gibberfish" ]
                        ]
        ]
