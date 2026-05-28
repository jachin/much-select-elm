module Examples.AnInitialValue exposing (suite)

import Html.Attributes
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (attribute, classes)


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
    describe "Example: an-initial-value"
        [ test "initial value with populated options is selected at startup" <|
            \_ ->
                start
                    |> ProgramTest.expectViewHas
                        [ classes [ "selected", "option" ]
                        , attribute (Html.Attributes.attribute "data-value" "Blue")
                        ]
        ]
