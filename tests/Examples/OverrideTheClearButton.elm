module Examples.OverrideTheClearButton exposing (suite)

import Html.Attributes
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (attribute, id, tag)


optionsJson : String
optionsJson =
    """
[
  { "value": "Red", "label": "Red", "labelClean": "Red" },
  { "value": "Yellow", "label": "Yellow", "labelClean": "Yellow" },
  { "value": "Blue", "label": "Blue", "labelClean": "Blue" },
  { "value": "Orange", "label": "Orange", "labelClean": "Orange" },
  { "value": "Green", "label": "Green", "labelClean": "Green" },
  { "value": "Purple", "label": "Purple", "labelClean": "Purple" }
]
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = "Blue"
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
    describe "Example: override-the-clear-button"
        [ test "custom clear button slot replaces default clear control" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas [ id "clear-button-wrapper" ]
                    |> ProgramTest.expectViewHas
                        [ tag "slot"
                        , attribute (Html.Attributes.attribute "name" "clear-button")
                        ]
        ]
