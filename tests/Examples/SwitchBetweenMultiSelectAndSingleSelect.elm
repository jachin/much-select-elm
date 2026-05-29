module Examples.SwitchBetweenMultiSelectAndSingleSelect exposing (suite)

import Html.Attributes
import Json.Decode
import Json.Encode
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import SimulatedEffect.Ports
import SimulatedEffect.Sub
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (attribute, classes)


optionsJson : String
optionsJson =
    """
[
  { "value": "Firefox", "label": "Firefox", "labelClean": "Firefox" },
  { "value": "Chrome", "label": "Chrome", "labelClean": "Chrome" },
  { "value": "Safari", "label": "Safari", "labelClean": "Safari" },
  { "value": "Edge", "label": "Edge", "labelClean": "Edge" }
]
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = "Safari,Firefox"
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
        [ SimulatedEffect.Ports.subscribe "multiSelectChangedReceiver"
            Json.Decode.bool
            MuchSelect.MultiSelectAttributeChanged
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
    describe "Example: switch-between-multi-select-and-single-select"
        [ test "switching selection mode recalculates selected values correctly" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas [ classes [ "multi" ] ]
                    |> ProgramTest.simulateIncomingPort
                        "multiSelectChangedReceiver"
                        (Json.Encode.bool False)
                    |> ProgramTest.ensureViewHasNot [ classes [ "multi" ] ]
                    |> ProgramTest.ensureViewHas
                        [ classes [ "selected", "option" ]
                        , attribute (Html.Attributes.attribute "data-value" "Safari")
                        ]
                    |> ProgramTest.expectViewHasNot
                        [ classes [ "selected", "option" ]
                        , attribute (Html.Attributes.attribute "data-value" "Firefox")
                        ]
        ]
