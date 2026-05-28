module Examples.MultiSelectBlurOrUnfocusedValueChange exposing (suite)

import Json.Decode
import Json.Encode
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import SimulatedEffect.Ports
import SimulatedEffect.Sub
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (classes, containing, text)


optionsJson : String
optionsJson =
    """
[
  { "value": "Garbanzo", "label": "Garbanzo Beans", "labelClean": "Garbanzo Beans" },
  { "value": "Runner", "label": "Runner Beans", "labelClean": "Runner Beans" },
  { "value": "Guar", "label": "Guar Beans", "labelClean": "Guar Beans" },
  { "value": "Jack", "label": "Jack Beans", "labelClean": "Jack Beans" }
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
    , enableMultiSelectSingleItemRemoval = True
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


simulateSubscriptions : MuchSelect.Model -> ProgramTest.SimulatedSub MuchSelect.Msg
simulateSubscriptions _ =
    SimulatedEffect.Sub.batch
        [ SimulatedEffect.Ports.subscribe "valueChangedReceiver"
            Json.Decode.value
            MuchSelect.ValueChanged
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
    describe "Example: multi-select-blur-or-unfocused-value-change"
        [ test "value change while blurred updates selection without focus-only assumptions" <|
            \_ ->
                start
                    |> ProgramTest.simulateIncomingPort
                        "valueChangedReceiver"
                        (Json.Encode.list Json.Encode.string [ "Runner", "Guar" ])
                    |> ProgramTest.ensureViewHas
                        [ classes [ "value", "selected-value" ]
                        , containing [ text "Runner Beans" ]
                        ]
                    |> ProgramTest.expectViewHas
                        [ classes [ "value", "selected-value" ]
                        , containing [ text "Guar Beans" ]
                        ]
        ]
