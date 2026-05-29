module Examples.MultiSelectValueCleared exposing (suite)

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
    "value": "Pineapple",
    "label": "Pineapple",
    "labelClean": "Pineapple"
  },
  {
    "value": "Pine cone",
    "label": "Pine cone",
    "labelClean": "Pine cone"
  },
  {
    "value": "Pine nut",
    "label": "Pine nut",
    "labelClean": "Pine nut"
  }
]
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = "Pineapple,Pine cone"
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

        MuchSelect.ValueCleared ->
            SimulatedEffect.Ports.send "valueCleared" (Json.Encode.object [])

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
        |> ProgramTest.withSimulatedEffects simulateEffects
        |> ProgramTest.withSimulatedSubscriptions simulateSubscriptions
        |> ProgramTest.start flags


suite : Test
suite =
    describe "Example: multi-select-value-cleared"
        [ test "clear action emits valueCleared and deselection events" <|
            \_ ->
                start
                    |> ProgramTest.simulateIncomingPort
                        "valueCleared"
                        (Json.Encode.object [])
                    |> ProgramTest.expectOutgoingPortValues
                        "optionDeselected"
                        Ports.optionsDecoder
                        (Expect.equal
                            [ [ { value = "Pineapple"
                                , label = "Pineapple"
                                , isValid = True
                                , selectedIndex = -1
                                }
                              , { value = "Pine cone"
                                , label = "Pine cone"
                                , isValid = True
                                , selectedIndex = -1
                                }
                              ]
                            ]
                        )
        ]
