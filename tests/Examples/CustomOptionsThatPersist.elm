module Examples.CustomOptionsThatPersist exposing (suite)

import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (classes, id, text)


optionsJson : String
optionsJson =
    """
[
  { "value": "Bánh mì", "label": "Bánh mì", "labelClean": "Bánh mì" },
  { "value": "Cheese steak", "label": "Cheese steak", "labelClean": "Cheese steak" },
  { "value": "Po' boy", "label": "Po' boy", "labelClean": "Po' boy" }
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
    describe "Example: custom-options-that-persist"
        [ test "renders configured options and custom-options mode" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas
                        [ id "value-casing"
                        , classes [ "allows-custom-options" ]
                        ]
                    |> ProgramTest.ensureViewHas [ text "Bánh mì" ]
                    |> ProgramTest.expectViewHas [ text "Po' boy" ]
        ]
