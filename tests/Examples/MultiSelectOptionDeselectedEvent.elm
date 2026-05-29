module Examples.MultiSelectOptionDeselectedEvent exposing (suite)

import Expect
import Json.Decode
import Json.Encode
import MuchSelect exposing (Flags)
import Ports
import ProgramTest exposing (ProgramTest)
import SelectionMode
import SimulatedEffect.Cmd
import SimulatedEffect.Ports
import SimulatedEffect.Sub
import Test exposing (Test, describe, test)


optionsJson : String
optionsJson =
    """
[
  {
    "value": "FRGMNT",
    "label": "FRGMNT",
    "labelClean": "FRGMNT"
  },
  {
    "value": "Spy House",
    "label": "Spy House",
    "labelClean": "Spy House"
  }
]
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = "FRGMNT"
    , selectedValueEncoding = Nothing
    , placeholder = ( True, "" )
    , customOptionHint = Nothing
    , allowMultiSelect = True
    , outputStyle = "datalist"
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


simulateEffects : MuchSelect.Effect -> ProgramTest.SimulatedEffect MuchSelect.Msg
simulateEffects effect =
    case effect of
        MuchSelect.Batch effects ->
            effects
                |> List.map simulateEffects
                |> SimulatedEffect.Cmd.batch

        MuchSelect.ReportOptionDeselected value ->
            SimulatedEffect.Ports.send "optionDeselected" value

        MuchSelect.ReportValueChanged value selectionMode ->
            case selectionMode of
                SelectionMode.SingleSelect ->
                    SimulatedEffect.Ports.send "valueChangedSingleSelect" value

                SelectionMode.MultiSelect ->
                    SimulatedEffect.Ports.send "valueChangedMultiSelect" value

        _ ->
            SimulatedEffect.Cmd.none


simulateSubscriptions : MuchSelect.Model -> ProgramTest.SimulatedSub MuchSelect.Msg
simulateSubscriptions _ =
    SimulatedEffect.Sub.batch
        [ SimulatedEffect.Ports.subscribe "deselectOptionReceiver"
            Json.Decode.value
            MuchSelect.DeselectOption
        ]


start : ProgramTest MuchSelect.Model MuchSelect.Msg MuchSelect.Effect
start =
    ProgramTest.createElement
        { init = MuchSelect.init
        , update = MuchSelect.update
        , view = MuchSelect.view
        }
        |> ProgramTest.withSimulatedEffects simulateEffects
        |> ProgramTest.withSimulatedSubscriptions simulateSubscriptions
        |> ProgramTest.start flags


suite : Test
suite =
    describe "Example: multi-select-option-deselected-event"
        [ test "deselecting one selected option emits optionDeselected payload" <|
            \_ ->
                start
                    |> ProgramTest.simulateIncomingPort
                        "deselectOptionReceiver"
                        (Json.Encode.object
                            [ ( "value", Json.Encode.string "FRGMNT" ) ]
                        )
                    |> ProgramTest.expectOutgoingPortValues
                        "optionDeselected"
                        Ports.optionDecoder
                        (Expect.equal
                            [ { value = "FRGMNT"
                              , label = "FRGMNT"
                              , isValid = True
                              , selectedIndex = -1
                              }
                            ]
                        )
        ]
