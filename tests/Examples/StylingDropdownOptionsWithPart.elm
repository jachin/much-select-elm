module Examples.StylingDropdownOptionsWithPart exposing (suite)

import Html.Attributes
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (attribute, classes)


optionsJson : String
optionsJson =
    """
[
  { "value": "Spades", "label": "Spades", "labelClean": "Spades" },
  { "value": "Hearts", "label": "Hearts", "labelClean": "Hearts" },
  { "value": "Diamonds", "label": "Diamonds", "labelClean": "Diamonds" },
  { "value": "Clubs", "label": "Clubs", "labelClean": "Clubs" }
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
    describe "Example: styling-dropdown-options-with-part"
        [ test "dropdown options expose expected part hooks/class markers for styling" <|
            \_ ->
                start
                    |> ProgramTest.expectViewHas
                        [ classes [ "option" ]
                        , attribute (Html.Attributes.attribute "part" "dropdown-option Spades")
                        ]
        ]
