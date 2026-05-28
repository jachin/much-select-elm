module Examples.AllowCustomOptionsWithMinimumSearchStringLength exposing (suite)

import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (classes, id)


optionsJson : String
optionsJson =
    """
[
  { "value": "Caveman", "label": "Caveman", "labelClean": "Caveman" },
  { "value": "Bees", "label": "Bees", "labelClean": "Bees" },
  { "value": "Cow", "label": "Cow", "labelClean": "Cow" }
]
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = ""
    , selectedValueEncoding = Nothing
    , placeholder = ( True, "" )
    , customOptionHint = Nothing
    , allowMultiSelect = True
    , outputStyle = "customHtml"
    , enableMultiSelectSingleItemRemoval = False
    , optionsJson = optionsJson
    , optionSort = ""
    , loading = False
    , maxDropdownItems = Just "10"
    , disabled = False
    , allowCustomOptions = True
    , selectedItemStaysInPlace = True
    , searchStringMinimumLength = Just "5"
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
    describe "Example: allow-custom-options-with-minimum-search-string-length"
        [ test "blocks custom option creation until minimum search length is reached" <|
            \_ ->
                start
                    |> ProgramTest.expectViewHas
                        [ id "value-casing"
                        , classes [ "multi", "allows-custom-options" ]
                        ]
        ]
