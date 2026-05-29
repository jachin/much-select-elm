module Examples.MaxNumberOfDropdownItems exposing (suite)

import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (text)


optionsJson : String
optionsJson =
    """
[
  { "value": "Hydrogen", "label": "Hydrogen", "labelClean": "Hydrogen" },
  { "value": "Lithium", "label": "Lithium", "labelClean": "Lithium" },
  { "value": "Sodium", "label": "Sodium", "labelClean": "Sodium" },
  { "value": "Potassium", "label": "Potassium", "labelClean": "Potassium" },
  { "value": "Rubidium", "label": "Rubidium", "labelClean": "Rubidium" },
  { "value": "Caesium", "label": "Caesium", "labelClean": "Caesium" }
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
    , maxDropdownItems = Just "5"
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
    describe "Example: max-number-of-dropdown-items"
        [ test "caps dropdown rendering using max-number-of-dropdown-items setting" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas [ text "Hydrogen" ]
                    |> ProgramTest.ensureViewHas [ text "Rubidium" ]
                    |> ProgramTest.expectViewHasNot [ text "Caesium" ]
        ]
