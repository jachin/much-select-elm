module Examples.SelectedValue exposing (suite)

import Html.Attributes
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (classes)


booksJson : String
booksJson =
    """
[
  {
    "value": "The Enormous Crocodile",
    "label": "The Enormous Crocodile",
    "labelClean": "The Enormous Crocodile"
  },
  {
    "value": "James and the Giant Peach",
    "label": "James and the Giant Peach",
    "labelClean": "James and the Giant Peach"
  },
  {
    "value": "Matilda",
    "label": "Matilda",
    "labelClean": "Matilda"
  }
]
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = "Matilda"
    , selectedValueEncoding = Nothing
    , placeholder = ( True, "A book" )
    , customOptionHint = Nothing
    , allowMultiSelect = False
    , outputStyle = "customHtml"
    , enableMultiSelectSingleItemRemoval = False
    , optionsJson = booksJson
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
    describe "Example: selected-value"
        [ test "applies selected-value flag and renders selected option" <|
            \_ ->
                start flags
                    |> ProgramTest.expectViewHas
                        [ classes [ "selected", "option" ]
                        , Test.Html.Selector.attribute (Html.Attributes.attribute "data-value" "Matilda")
                        ]
        ]
