module Examples.MultiSelect exposing (suite)

import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (classes, containing, text)


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
    , selectedValue = "The Enormous Crocodile,Matilda"
    , selectedValueEncoding = Nothing
    , placeholder = ( True, "A book" )
    , customOptionHint = Nothing
    , allowMultiSelect = True
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
    describe "Example: multi-select"
        [ test "renders multi-select mode with selected-value container" <|
            \_ ->
                start flags
                    |> ProgramTest.ensureViewHas [ classes [ "multi" ] ]
                    |> ProgramTest.ensureViewHas
                        [ classes [ "value", "selected-value" ]
                        , containing [ text "The Enormous Crocodile" ]
                        ]
                    |> ProgramTest.expectViewHas
                        [ classes [ "value", "selected-value" ]
                        , containing [ text "Matilda" ]
                        ]
        ]
