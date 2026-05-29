module Examples.SelectAndDeselectOptionFromAMuchSelect exposing (suite)

import Expect
import Json.Decode
import Json.Encode
import MuchSelect exposing (Flags)
import Ports
import ProgramTest exposing (ProgramTest)
import SimulatedEffect.Cmd
import SimulatedEffect.Ports
import SimulatedEffect.Sub
import Test exposing (Test, describe, test)


optionsJson : String
optionsJson =
    """
[
  { "value": "Metal", "label": "Metal", "labelClean": "Metal" },
  { "value": "Rock", "label": "Rock", "labelClean": "Rock" },
  { "value": "Rap", "label": "Rap", "labelClean": "Rap" },
  { "value": "Country", "label": "Country", "labelClean": "Country" },
  { "value": "Folk", "label": "Folk", "labelClean": "Folk" }
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


simulateEffects : MuchSelect.Effect -> ProgramTest.SimulatedEffect MuchSelect.Msg
simulateEffects effect =
    case effect of
        MuchSelect.Batch effects ->
            effects
                |> List.map simulateEffects
                |> SimulatedEffect.Cmd.batch

        MuchSelect.ReportOptionSelected value ->
            SimulatedEffect.Ports.send "optionSelected" value

        MuchSelect.ReportOptionDeselected value ->
            SimulatedEffect.Ports.send "optionDeselected" value

        _ ->
            SimulatedEffect.Cmd.none


simulateSubscriptions : MuchSelect.Model -> ProgramTest.SimulatedSub MuchSelect.Msg
simulateSubscriptions _ =
    SimulatedEffect.Sub.batch
        [ SimulatedEffect.Ports.subscribe "selectOptionReceiver"
            Json.Decode.value
            MuchSelect.SelectOption
        , SimulatedEffect.Ports.subscribe "deselectOptionReceiver"
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
    describe "Example: select-and-deselect-option-from-a-much-select"
        [ test "programmatic select then deselect updates value and emits events" <|
            \_ ->
                start
                    |> ProgramTest.simulateIncomingPort
                        "selectOptionReceiver"
                        (Json.Encode.object
                            [ ( "value", Json.Encode.string "Rock" )
                            , ( "label", Json.Encode.string "Rock" )
                            , ( "labelClean", Json.Encode.string "Rock" )
                            ]
                        )
                    |> ProgramTest.simulateIncomingPort
                        "deselectOptionReceiver"
                        (Json.Encode.object
                            [ ( "value", Json.Encode.string "Rock" )
                            , ( "label", Json.Encode.string "Rock" )
                            , ( "labelClean", Json.Encode.string "Rock" )
                            ]
                        )
                    |> ProgramTest.ensureOutgoingPortValues
                        "optionSelected"
                        Ports.optionDecoder
                        (Expect.equal
                            [ { value = "Rock"
                              , label = "Rock"
                              , isValid = True
                              , selectedIndex = -1
                              }
                            ]
                        )
                    |> ProgramTest.expectOutgoingPortValues
                        "optionDeselected"
                        Ports.optionDecoder
                        (Expect.equal
                            [ { value = "Rock"
                              , label = "Rock"
                              , isValid = True
                              , selectedIndex = -1
                              }
                            ]
                        )
        ]
