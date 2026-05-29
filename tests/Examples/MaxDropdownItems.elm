module Examples.MaxDropdownItems exposing (suite)

import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (text)


optionsJson : String
optionsJson =
    """
[
  { "value": "The Enormous Crocodile", "label": "The Enormous Crocodile", "labelClean": "The Enormous Crocodile" },
  { "value": "James and the Giant Peach", "label": "James and the Giant Peach", "labelClean": "James and the Giant Peach" },
  { "value": "Matilda", "label": "Matilda", "labelClean": "Matilda" },
  { "value": "The BFG", "label": "The BFG", "labelClean": "The BFG" }
]
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = ""
    , selectedValueEncoding = Nothing
    , placeholder = ( True, "A book" )
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
    describe "Example: max-dropdown-items"
        [ test "limits visible dropdown options to max-dropdown-items" <|
            \_ ->
                start flags
                    |> ProgramTest.ensureViewHas [ text "The Enormous Crocodile" ]
                    |> ProgramTest.ensureViewHas [ text "James and the Giant Peach" ]
                    |> ProgramTest.ensureViewHasNot [ text "Matilda" ]
                    |> ProgramTest.expectViewHasNot [ text "The BFG" ]
        ]
