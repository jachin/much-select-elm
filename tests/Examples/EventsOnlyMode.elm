module Examples.EventsOnlyMode exposing (suite)

import Expect
import Json.Decode
import Json.Encode
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import SimulatedEffect.Ports
import Test exposing (Test, describe, test)


flags : Flags
flags =
    { isEventsOnly = True
    , selectedValue = "%5B%22central%22%5D"
    , selectedValueEncoding = Just "json"
    , placeholder = ( True, "" )
    , customOptionHint = Nothing
    , allowMultiSelect = True
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


simulateSubscriptions : MuchSelect.Model -> ProgramTest.SimulatedSub MuchSelect.Msg
simulateSubscriptions _ =
    SimulatedEffect.Ports.subscribe "attributeChanged"
        (Json.Decode.map2
            Tuple.pair
            (Json.Decode.index 0 Json.Decode.string)
            (Json.Decode.index 1 Json.Decode.string)
        )
        MuchSelect.AttributeChanged


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
    describe "Example: events-only-mode"
        [ test "suppresses internal light DOM changes while still reporting changed value" <|
            \_ ->
                start
                    |> ProgramTest.simulateIncomingPort
                        "attributeChanged"
                        (Json.Encode.list Json.Encode.string [ "selected-value", "%5B%22mountain%22%5D" ])
                    |> ProgramTest.expectLastEffect
                        (\lastEffect ->
                            case lastEffect of
                                MuchSelect.Batch effects ->
                                    let
                                        hasValueChangedEffect =
                                            List.any
                                                (\effect ->
                                                    case effect of
                                                        MuchSelect.ReportValueChanged _ _ ->
                                                            True

                                                        _ ->
                                                            False
                                                )
                                                effects

                                        hasLightDomChange =
                                            List.any
                                                (\effect ->
                                                    case effect of
                                                        MuchSelect.ChangeTheLightDom _ ->
                                                            True

                                                        _ ->
                                                            False
                                                )
                                                effects
                                    in
                                    if hasValueChangedEffect && not hasLightDomChange then
                                        Expect.pass

                                    else
                                        Expect.fail "Expected value changed effect without light DOM mutation in events-only mode"

                                _ ->
                                    Expect.fail "Expected batch effect"
                        )
        ]
