module Examples.SwitchBetweenDatalistAndCustomHtml exposing (suite)

import Expect
import Json.Decode
import Json.Encode
import MuchSelect exposing (Flags)
import ProgramTest exposing (expectLastEffect, expectView, start)
import SimulatedEffect.Cmd
import SimulatedEffect.Ports
import Test exposing (Test, describe, test)
import Test.Html.Query
import Test.Html.Selector exposing (classes, id, tag)


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = "Safari,Firefox"
    , selectedValueEncoding = Nothing
    , placeholder = ( True, "" )
    , customOptionHint = Nothing
    , allowMultiSelect = True
    , outputStyle = "datalist"
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


element =
    ProgramTest.createElement
        { init = MuchSelect.init
        , update = MuchSelect.update
        , view = MuchSelect.view
        }


simulateEffects : MuchSelect.Effect -> ProgramTest.SimulatedEffect MuchSelect.Msg
simulateEffects effect =
    case effect of
        MuchSelect.Batch effects ->
            effects
                |> List.map simulateEffects
                |> SimulatedEffect.Cmd.batch

        _ ->
            SimulatedEffect.Cmd.none


simulateSubOutputStyleChanged : MuchSelect.Model -> ProgramTest.SimulatedSub MuchSelect.Msg
simulateSubOutputStyleChanged _ =
    SimulatedEffect.Ports.subscribe "outputStyleChangedReceiver"
        Json.Decode.string
        MuchSelect.OutputStyleChanged


simulateSubAttributeChanged : MuchSelect.Model -> ProgramTest.SimulatedSub MuchSelect.Msg
simulateSubAttributeChanged _ =
    SimulatedEffect.Ports.subscribe "attributeChanged"
        (Json.Decode.map2 Tuple.pair
            (Json.Decode.index 0 Json.Decode.string)
            (Json.Decode.index 1 Json.Decode.string)
        )
        MuchSelect.AttributeChanged


suite : Test
suite =
    describe "Example: switch-between-datalist-and-custom-html"
        [ test "switching output-style triggers option refresh effect and new output-style class" <|
            \_ ->
                element
                    |> ProgramTest.withSimulatedEffects simulateEffects
                    |> ProgramTest.withSimulatedSubscriptions simulateSubOutputStyleChanged
                    |> start flags
                    |> ProgramTest.simulateIncomingPort
                        "outputStyleChangedReceiver"
                        (Json.Encode.string "custom-html")
                    |> expectLastEffect
                        (\effect ->
                            case effect of
                                MuchSelect.Batch batchEffects ->
                                    if List.member MuchSelect.FetchOptionsFromDom batchEffects then
                                        Expect.pass

                                    else
                                        Expect.fail "Expected FetchOptionsFromDom when switching output style"

                                _ ->
                                    Expect.fail "Expected batch effect when switching output style"
                        )
        , test "switching output style changes rendered output style class" <|
            \_ ->
                element
                    |> ProgramTest.withSimulatedEffects simulateEffects
                    |> ProgramTest.withSimulatedSubscriptions simulateSubAttributeChanged
                    |> start flags
                    |> ProgramTest.simulateIncomingPort
                        "attributeChanged"
                        (Json.Encode.list Json.Encode.string [ "output-style", "custom-html" ])
                    |> expectView
                        (Test.Html.Query.has
                            [ tag "div"
                            , id "value-casing"
                            , classes [ "output-style-custom-html" ]
                            ]
                        )
        ]
