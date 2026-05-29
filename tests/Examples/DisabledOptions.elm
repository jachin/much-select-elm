module Examples.DisabledOptions exposing (suite)

import Html.Attributes
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (classes)


optionsJson : String
optionsJson =
    """
[
  {
    "value": "Red",
    "label": "Red",
    "labelClean": "Red"
  },
  {
    "value": "Yellow",
    "label": "Yellow",
    "labelClean": "Yellow",
    "disabled": true
  },
  {
    "value": "Blue",
    "label": "Blue",
    "labelClean": "Blue"
  }
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
    describe "Example: disabled-options"
        [ test "prevents selecting disabled options" <|
            \_ ->
                start flags
                    |> ProgramTest.expectViewHas
                        [ classes [ "option", "disabled" ]
                        , Test.Html.Selector.attribute (Html.Attributes.attribute "data-value" "Yellow")
                        ]
        ]
