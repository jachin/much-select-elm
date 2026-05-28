module Examples.FocusOnDemand exposing (suite)

import Expect
import Json.Decode
import Json.Encode
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import SimulatedEffect.Cmd
import SimulatedEffect.Ports
import SimulatedEffect.Sub
import Test exposing (Test, describe, test)


optionsJson : String
optionsJson =
    """
[
  { "value": "111", "label": "Grass Pea", "labelClean": "Grass Pea" },
  { "value": "222", "label": "Velvet Bean", "labelClean": "Velvet Bean" },
  { "value": "333", "label": "Sword Bean", "labelClean": "Sword Bean" },
  { "value": "444", "label": "Soybean", "labelClean": "Soybean" }
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
        MuchSelect.FocusInput ->
            SimulatedEffect.Ports.send "focusInput" (Json.Encode.object [])

        MuchSelect.Batch effects ->
            effects
                |> List.map simulateEffects
                |> SimulatedEffect.Cmd.batch

        _ ->
            SimulatedEffect.Cmd.none


simulateSubscriptions : MuchSelect.Model -> ProgramTest.SimulatedSub MuchSelect.Msg
simulateSubscriptions _ =
    SimulatedEffect.Sub.batch
        [ SimulatedEffect.Ports.subscribe "focusInputReceiver"
            Json.Decode.value
            (\_ -> MuchSelect.BringInputInFocus)
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
    describe "Example: focus-on-demand"
        [ test "focusInput effect/port focuses component on demand" <|
            \_ ->
                start
                    |> ProgramTest.simulateIncomingPort
                        "focusInputReceiver"
                        (Json.Encode.object [])
                    |> ProgramTest.expectOutgoingPortValues
                        "focusInput"
                        Json.Decode.value
                        (\values ->
                            case values of
                                [ _ ] ->
                                    Expect.pass

                                _ ->
                                    Expect.fail "Expected one focusInput port emission"
                        )
        ]
