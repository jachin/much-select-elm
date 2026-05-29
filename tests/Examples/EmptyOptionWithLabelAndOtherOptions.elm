module Examples.EmptyOptionWithLabelAndOtherOptions exposing (suite)

import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (text)


optionsJson : String
optionsJson =
    """
[
  { "value": "", "label": "[SELECT SPICE LEVEL]", "labelClean": "[SELECT SPICE LEVEL]" },
  { "value": "1", "label": "🌶", "labelClean": "🌶" },
  { "value": "2", "label": "🌶🌶", "labelClean": "🌶🌶" },
  { "value": "3", "label": "🌶🌶🌶", "labelClean": "🌶🌶🌶" },
  { "value": "4", "label": "🌶🌶🌶🌶", "labelClean": "🌶🌶🌶🌶" },
  { "value": "5", "label": "🌶🌶🌶🌶🌶", "labelClean": "🌶🌶🌶🌶🌶" }
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
    describe "Example: empty-option-with-label-and-other-options"
        [ test "empty option with label coexists with standard options" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas [ text "[SELECT SPICE LEVEL]" ]
                    |> ProgramTest.expectViewHas [ text "🌶🌶🌶" ]
        ]
