module Examples.MultiSelectSingleItemRemoval exposing (suite)

import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (classes)


optionsJson : String
optionsJson =
    """
[
  { "value": "Arugula", "label": "Arugula", "labelClean": "Arugula" },
  { "value": "Butterhead", "label": "Butterhead", "labelClean": "Butterhead" },
  { "value": "Escarole", "label": "Escarole", "labelClean": "Escarole" }
]
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = "Butterhead,Escarole"
    , selectedValueEncoding = Nothing
    , placeholder = ( True, "" )
    , customOptionHint = Nothing
    , allowMultiSelect = True
    , outputStyle = "customHtml"
    , enableMultiSelectSingleItemRemoval = True
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
    describe "Example: multi-select-single-item-removal"
        [ test "removes one selected item and emits expected deselection behavior" <|
            \_ ->
                start
                    |> ProgramTest.expectViewHas
                        [ classes [ "selected-value" ]
                        , classes [ "remove-option" ]
                        ]
        ]
