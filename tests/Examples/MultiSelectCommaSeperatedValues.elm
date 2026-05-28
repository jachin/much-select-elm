module Examples.MultiSelectCommaSeperatedValues exposing (suite)

import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (classes, containing, text)


optionsJson : String
optionsJson =
    """
[
  { "value": "Angelfish", "label": "Angelfish", "labelClean": "Angelfish" },
  { "value": "Betta", "label": "Betta", "labelClean": "Betta" },
  { "value": "Cod", "label": "Cod", "labelClean": "Cod" },
  { "value": "Dory", "label": "Dory", "labelClean": "Dory" },
  { "value": "Eulachon", "label": "Eulachon", "labelClean": "Eulachon" },
  { "value": "Fangtooth", "label": "Fangtooth", "labelClean": "Fangtooth" }
]
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = "Dory,Betta"
    , selectedValueEncoding = Just "comma"
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
    describe "Example: multi-select-comma-seperated-values"
        [ test "multi-select parses comma-separated selected-value" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas
                        [ classes [ "value", "selected-value" ]
                        , containing [ text "Dory" ]
                        ]
                    |> ProgramTest.expectViewHas
                        [ classes [ "value", "selected-value" ]
                        , containing [ text "Betta" ]
                        ]
        ]
