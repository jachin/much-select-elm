module Examples.SingleSelectJsonSeperatedValues exposing (suite)

import Html.Attributes
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (attribute, classes)


optionsJson : String
optionsJson =
    """
[
  { "value": "Koi", "label": "Koi", "labelClean": "Koi" },
  { "value": "Loach", "label": "Loach", "labelClean": "Loach" },
  { "value": "Marlin", "label": "Marlin", "labelClean": "Marlin" },
  { "value": "Notothen", "label": "Notothen", "labelClean": "Notothen" }
]
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = "%22Loach%22"
    , selectedValueEncoding = Just "json"
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
    describe "Example: single-select-json-seperated-values"
        [ test "single-select parses JSON encoded selected-value" <|
            \_ ->
                start
                    |> ProgramTest.expectViewHas
                        [ classes [ "selected", "option" ]
                        , attribute (Html.Attributes.attribute "data-value" "Loach")
                        ]
        ]
