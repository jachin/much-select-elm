module Examples.DefaultOptionGroupOrdering exposing (suite)

import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (text)


optionsJson : String
optionsJson =
    """
[
  { "value": "Minneapolis", "label": "Minneapolis", "labelClean": "Minneapolis", "group": "Minnesota" },
  { "value": "St Paul", "label": "St Paul", "labelClean": "St Paul", "group": "Minnesota" },
  { "value": "Duluth", "label": "Duluth", "labelClean": "Duluth", "group": "Minnesota" },
  { "value": "Des Moines", "label": "Des Moines", "labelClean": "Des Moines", "group": "Iowa" },
  { "value": "Cedar Rapids", "label": "Cedar Rapids", "labelClean": "Cedar Rapids", "group": "Iowa" },
  { "value": "Iowa City", "label": "Iowa City", "labelClean": "Iowa City", "group": "Iowa" }
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
    , optionSort = "by-option-label"
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
    describe "Example: default-option-group-ordering"
        [ test "option groups render in default ordering" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas [ text "Minnesota" ]
                    |> ProgramTest.ensureViewHas [ text "Minneapolis" ]
                    |> ProgramTest.ensureViewHas [ text "Iowa" ]
                    |> ProgramTest.expectViewHas [ text "Des Moines" ]
        ]
