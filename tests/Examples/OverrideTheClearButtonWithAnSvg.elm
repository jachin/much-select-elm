module Examples.OverrideTheClearButtonWithAnSvg exposing (suite)

import Json.Decode
import Json.Encode
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import SimulatedEffect.Ports
import SimulatedEffect.Sub
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (classes, id)


optionsJson : String
optionsJson =
    """
[
  { "value": "Red", "label": "Red", "labelClean": "Red" },
  { "value": "Yellow", "label": "Yellow", "labelClean": "Yellow" },
  { "value": "Blue", "label": "Blue", "labelClean": "Blue" },
  { "value": "Orange", "label": "Orange", "labelClean": "Orange" },
  { "value": "Green", "label": "Green", "labelClean": "Green" },
  { "value": "Purple", "label": "Purple", "labelClean": "Purple" }
]
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = "Blue,Yellow,Purple,Green,Orange,Red"
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
    , allowCustomOptions = False
    , selectedItemStaysInPlace = True
    , searchStringMinimumLength = Nothing
    , showDropdownFooter = False
    , transformationAndValidationJson = ""
    }


simulateSubscriptions : MuchSelect.Model -> ProgramTest.SimulatedSub MuchSelect.Msg
simulateSubscriptions _ =
    SimulatedEffect.Sub.batch
        [ SimulatedEffect.Ports.subscribe "valueCleared"
            Json.Decode.value
            (\_ -> MuchSelect.ClearAllSelectedOptions)
        ]


start : ProgramTest MuchSelect.Model MuchSelect.Msg MuchSelect.Effect
start =
    ProgramTest.createElement
        { init = MuchSelect.init
        , update = MuchSelect.update
        , view = MuchSelect.view
        }
        |> ProgramTest.withSimulatedSubscriptions simulateSubscriptions
        |> ProgramTest.start flags


suite : Test
suite =
    describe "Example: override-the-clear-button-with-an-svg"
        [ test "SVG clear button slot renders and clears selection" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas [ id "clear-button-wrapper" ]
                    |> ProgramTest.simulateIncomingPort
                        "valueCleared"
                        (Json.Encode.object [])
                    |> ProgramTest.expectViewHas [ classes [ "no-option-selected" ] ]
        ]
