module Attributes.OutputStyle exposing (suite)

import Expect
import Json.Decode
import Json.Encode
import Main exposing (Flags)
import ProgramTest exposing (expectLastEffect, start)
import SimulatedEffect.Cmd
import SimulatedEffect.Ports
import Test exposing (Test, describe, test)


element =
    ProgramTest.createElement
        { init = Main.init
        , update = Main.update
        , view = Main.view
        }


simulateEffects : Main.Effect -> ProgramTest.SimulatedEffect Main.Msg
simulateEffects effect =
    case effect of
        Main.Batch effects ->
            effects
                |> List.map simulateEffects
                |> SimulatedEffect.Cmd.batch

        _ ->
            SimulatedEffect.Cmd.none


simulateSub : Main.Model -> ProgramTest.SimulatedSub Main.Msg
simulateSub _ =
    SimulatedEffect.Ports.subscribe "outputStyleChangedReceiver"
        Json.Decode.string
        Main.OutputStyleChanged


flagsDatalistSingle : Flags
flagsDatalistSingle =
    { value = Json.Encode.object []
    , placeholder = ( True, "" )
    , customOptionHint = Nothing
    , allowMultiSelect = False
    , outputStyle = "datalist"
    , enableMultiSelectSingleItemRemoval = False
    , optionsJson = ""
    , optionSort = ""
    , loading = False
    , maxDropdownItems = 2
    , disabled = False
    , allowCustomOptions = False
    , selectedItemStaysInPlace = True
    , searchStringMinimumLength = 2
    , showDropdownFooter = False
    , transformationAndValidationJson = ""
    }


flagsCustomHtmlSingle : Flags
flagsCustomHtmlSingle =
    { value = Json.Encode.object []
    , placeholder = ( True, "" )
    , customOptionHint = Nothing
    , allowMultiSelect = False
    , outputStyle = "custom-html"
    , enableMultiSelectSingleItemRemoval = False
    , optionsJson = ""
    , optionSort = ""
    , loading = False
    , maxDropdownItems = 2
    , disabled = False
    , allowCustomOptions = False
    , selectedItemStaysInPlace = True
    , searchStringMinimumLength = 2
    , showDropdownFooter = False
    , transformationAndValidationJson = ""
    }


suite : Test
suite =
    describe "Changing the output style"
        [ test "to custom-html should work" <|
            \() ->
                element
                    |> ProgramTest.withSimulatedEffects simulateEffects
                    |> ProgramTest.withSimulatedSubscriptions simulateSub
                    |> start flagsDatalistSingle
                    |> ProgramTest.simulateIncomingPort
                        "outputStyleChangedReceiver"
                        (Json.Encode.string "custom-html")
                    |> expectLastEffect
                        (\effect ->
                            case effect of
                                Main.FetchOptionsFromDom ->
                                    Expect.pass

                                _ ->
                                    Expect.fail "We should be fetching options from the DOM."
                        )
        , test "to datalist should work" <|
            \() ->
                element
                    |> ProgramTest.withSimulatedEffects simulateEffects
                    |> ProgramTest.withSimulatedSubscriptions simulateSub
                    |> start flagsCustomHtmlSingle
                    |> ProgramTest.simulateIncomingPort
                        "outputStyleChangedReceiver"
                        (Json.Encode.string "datalist")
                    |> expectLastEffect
                        (\effect ->
                            case effect of
                                Main.FetchOptionsFromDom ->
                                    Expect.pass

                                _ ->
                                    Expect.fail "We should be fetching options from the DOM."
                        )
        , test "an invalid value should result in an error" <|
            \() ->
                element
                    |> ProgramTest.withSimulatedEffects simulateEffects
                    |> ProgramTest.withSimulatedSubscriptions simulateSub
                    |> start flagsDatalistSingle
                    |> ProgramTest.simulateIncomingPort
                        "outputStyleChangedReceiver"
                        (Json.Encode.string "bogus")
                    |> expectLastEffect
                        (\effect ->
                            case effect of
                                Main.ReportErrorMessage _ ->
                                    Expect.pass

                                _ ->
                                    Expect.fail "We should be fetching options from the DOM."
                        )
        ]
