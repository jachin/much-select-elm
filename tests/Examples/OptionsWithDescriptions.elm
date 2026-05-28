module Examples.OptionsWithDescriptions exposing (suite)

import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (text)


optionsJson : String
optionsJson =
    """
[
  { "value": "Red", "label": "Red", "labelClean": "Red", "description": "scarlet, vermilion, ruby", "descriptionClean": "scarlet, vermilion, ruby" },
  { "value": "Yellow", "label": "Yellow", "labelClean": "Yellow", "description": "yellowish, lemon", "descriptionClean": "yellowish, lemon" },
  { "value": "Blue", "label": "Blue", "labelClean": "Blue", "description": "azure, cobalt, navy", "descriptionClean": "azure, cobalt, navy" },
  { "value": "Orange", "label": "Orange", "labelClean": "Orange", "description": "A town in France", "descriptionClean": "A town in France" }
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
    describe "Example: options-with-descriptions"
        [ test "renders option descriptions in dropdown" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas [ text "Red" ]
                    |> ProgramTest.ensureViewHas [ text "scarlet, vermilion, ruby" ]
                    |> ProgramTest.expectViewHas [ text "A town in France" ]
        ]
