module Examples.ValidationAndTransformationSlotSingleDatalist exposing (suite)

import Html.Attributes
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (attribute, classes, id)


optionsJson : String
optionsJson =
    """
[
  { "value": "Achacha", "label": "Achacha", "labelClean": "Achacha" },
  { "value": "Ackee", "label": "Ackee", "labelClean": "Ackee" },
  { "value": "Bacuri", "label": "Bacuri", "labelClean": "Bacuri" }
]
"""


transformationAndValidationJson : String
transformationAndValidationJson =
    """
{
  "transformers": [
    { "name": "lowercase" }
  ],
  "validators": [
    {
      "name": "no-white-space",
      "level": "error",
      "message": "Spaces are not allow for custom fruit."
    },
    {
      "name": "minimum-length",
      "level": "silent",
      "minimum-length": 3,
      "message": "The minimum length is 3."
    }
  ]
}
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = ""
    , selectedValueEncoding = Nothing
    , placeholder = ( True, "" )
    , customOptionHint = Nothing
    , allowMultiSelect = False
    , outputStyle = "datalist"
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
    , transformationAndValidationJson = transformationAndValidationJson
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
    describe "Example: validation-and-transformation-slot-single-datalist"
        [ test "renders single datalist with allow-custom-options and configured options" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas
                        [ id "value-casing"
                        , classes [ "single", "output-style-datalist", "allows-custom-options" ]
                        ]
                    |> ProgramTest.expectViewHas [ attribute (Html.Attributes.value "Ackee") ]
        ]
