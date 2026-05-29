module Examples.OptionGroups exposing (suite)

import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (text)


optionsJson : String
optionsJson =
    """
[
  { "value": "Red", "label": "Red", "labelClean": "Red", "group": "Primary" },
  { "value": "Yellow", "label": "Yellow", "labelClean": "Yellow", "group": "Primary" },
  { "value": "Blue", "label": "Blue", "labelClean": "Blue", "group": "Primary" },
  { "value": "Orange", "label": "Orange", "labelClean": "Orange", "group": "Secondary" },
  { "value": "Green", "label": "Green", "labelClean": "Green", "group": "Secondary" },
  { "value": "Purple", "label": "Purple", "labelClean": "Purple", "group": "Secondary" }
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
    describe "Example: option-groups"
        [ test "renders grouped options with group labels" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas [ text "Primary" ]
                    |> ProgramTest.ensureViewHas [ text "Secondary" ]
                    |> ProgramTest.expectViewHas [ text "Purple" ]
        ]
