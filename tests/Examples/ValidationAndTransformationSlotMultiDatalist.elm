module Examples.ValidationAndTransformationSlotMultiDatalist exposing (suite)

import Html.Attributes
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (attribute, classes, id)


optionsJson : String
optionsJson =
    """
[
  { "value": "African locust bean", "label": "African locust bean", "labelClean": "African locust bean" },
  { "value": "Bilimbi", "label": "Bilimbi", "labelClean": "Bilimbi" },
  { "value": "Carob", "label": "Carob", "labelClean": "Carob" }
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
      "level": "error",
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
    describe "Example: validation-and-transformation-slot-multi-datalist"
        [ test "renders multi datalist with configured options" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas
                        [ id "value-casing"
                        , classes [ "multi", "output-style-datalist" ]
                        ]
                    |> ProgramTest.expectViewHas [ attribute (Html.Attributes.value "Carob") ]
        ]
