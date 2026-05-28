module Examples.AddPossibleDuplicateOptionToAMuchSelect exposing (suite)

import Expect
import Json.Decode
import Json.Encode
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import SimulatedEffect.Cmd
import SimulatedEffect.Ports
import SimulatedEffect.Sub
import Test exposing (Test, describe, test)


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
    , optionsJson = "[]"
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
        MuchSelect.ReportAllOptions value ->
            SimulatedEffect.Ports.send "allOptions" value

        MuchSelect.Batch effects ->
            effects
                |> List.map simulateEffects
                |> SimulatedEffect.Cmd.batch

        _ ->
            SimulatedEffect.Cmd.none


simulateSubscriptions : MuchSelect.Model -> ProgramTest.SimulatedSub MuchSelect.Msg
simulateSubscriptions _ =
    SimulatedEffect.Sub.batch
        [ SimulatedEffect.Ports.subscribe "addOptions"
            Json.Decode.value
            MuchSelect.AddOptions
        , SimulatedEffect.Ports.subscribe "requestAllOptionsReceiver"
            (Json.Decode.succeed ())
            (\_ -> MuchSelect.RequestAllOptions)
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
    describe "Example: add-possible-duplicate-option-to-a-much-select"
        [ test "duplicate option value is not added twice" <|
            \_ ->
                start
                    |> ProgramTest.simulateIncomingPort
                        "addOptions"
                        (Json.Encode.list identity
                            [ Json.Encode.object
                                [ ( "value", Json.Encode.string "ranch" )
                                , ( "label", Json.Encode.string "ranch" )
                                , ( "labelClean", Json.Encode.string "ranch" )
                                ]
                            ]
                        )
                    |> ProgramTest.simulateIncomingPort
                        "addOptions"
                        (Json.Encode.list identity
                            [ Json.Encode.object
                                [ ( "value", Json.Encode.string "ranch" )
                                , ( "label", Json.Encode.string "ranch" )
                                , ( "labelClean", Json.Encode.string "ranch" )
                                ]
                            ]
                        )
                    |> ProgramTest.simulateIncomingPort
                        "requestAllOptionsReceiver"
                        Json.Encode.null
                    |> ProgramTest.expectOutgoingPortValues
                        "allOptions"
                        (Json.Decode.list (Json.Decode.field "value" Json.Decode.string))
                        (Expect.equal
                            [ [ "ranch" ]
                            ]
                        )
        ]
