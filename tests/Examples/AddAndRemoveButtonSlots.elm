module Examples.AddAndRemoveButtonSlots exposing (suite)

import Html.Attributes
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (attribute, tag)


optionsJson : String
optionsJson =
    """
[
  { "value": "Monday", "label": "Monday", "labelClean": "Monday" },
  { "value": "Tuesday", "label": "Tuesday", "labelClean": "Tuesday" },
  { "value": "Wednesday", "label": "Wednesday", "labelClean": "Wednesday" },
  { "value": "Thursday", "label": "Thursday", "labelClean": "Thursday" },
  { "value": "Friday", "label": "Friday", "labelClean": "Friday" },
  { "value": "Saturday", "label": "Saturday", "labelClean": "Saturday" },
  { "value": "Sunday", "label": "Sunday", "labelClean": "Sunday" }
]
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = "Tuesday,Friday"
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
    describe "Example: add-and-remove-button-slots"
        [ test "custom add/remove button slots render and trigger expected actions" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas
                        [ tag "slot"
                        , attribute (Html.Attributes.attribute "name" "add-value-button-0")
                        ]
                    |> ProgramTest.ensureViewHas
                        [ tag "slot"
                        , attribute (Html.Attributes.attribute "name" "remove-value-button-0")
                        ]
                    |> ProgramTest.ensureViewHas
                        [ tag "slot"
                        , attribute (Html.Attributes.attribute "name" "add-value-button-1")
                        ]
                    |> ProgramTest.expectViewHas
                        [ tag "slot"
                        , attribute (Html.Attributes.attribute "name" "remove-value-button-1")
                        ]
        ]
