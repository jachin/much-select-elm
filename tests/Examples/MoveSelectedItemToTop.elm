module Examples.MoveSelectedItemToTop exposing (suite)

import Html.Attributes
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (classes, text)


optionsJson : String
optionsJson =
    """
[
  { "value": "Achiever", "label": "Achiever", "labelClean": "Achiever" },
  { "value": "Futuristic", "label": "Futuristic", "labelClean": "Futuristic" },
  { "value": "Input", "label": "Input", "labelClean": "Input" },
  { "value": "Woo", "label": "Woo", "labelClean": "Woo" }
]
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = "Woo"
    , selectedValueEncoding = Nothing
    , placeholder = ( True, "" )
    , customOptionHint = Nothing
    , allowMultiSelect = False
    , outputStyle = "customHtml"
    , enableMultiSelectSingleItemRemoval = False
    , optionsJson = optionsJson
    , optionSort = ""
    , loading = False
    , maxDropdownItems = Just "2"
    , disabled = False
    , allowCustomOptions = False
    , selectedItemStaysInPlace = False
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
    describe "Example: move-selected-item-to-top"
        [ test "reorders selected option to top when selected-item-stays-in-place is false" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas
                        [ classes [ "selected", "option" ]
                        , Test.Html.Selector.attribute (Html.Attributes.attribute "data-value" "Woo")
                        ]
                    |> ProgramTest.expectViewHas [ text "Input" ]
        ]
