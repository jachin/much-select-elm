module Examples.CustomElementOptions exposing (suite)

import Json.Decode
import Json.Encode
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import SimulatedEffect.Ports
import SimulatedEffect.Sub
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (text)


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


simulateSubscriptions : MuchSelect.Model -> ProgramTest.SimulatedSub MuchSelect.Msg
simulateSubscriptions _ =
    SimulatedEffect.Sub.batch
        [ SimulatedEffect.Ports.subscribe "optionsReplacedReceiver"
            Json.Decode.value
            MuchSelect.OptionsReplaced
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
    describe "Example: custom-element-options"
        [ test "custom element-provided options are decoded and displayed" <|
            \_ ->
                start
                    |> ProgramTest.simulateIncomingPort
                        "optionsReplacedReceiver"
                        (Json.Encode.list identity
                            [ Json.Encode.object
                                [ ( "value", Json.Encode.string "orange" )
                                , ( "label", Json.Encode.string "Orange" )
                                , ( "labelClean", Json.Encode.string "Orange" )
                                ]
                            , Json.Encode.object
                                [ ( "value", Json.Encode.string "Root Beer" )
                                , ( "label", Json.Encode.string "Root Beer" )
                                , ( "labelClean", Json.Encode.string "Root Beer" )
                                ]
                            , Json.Encode.object
                                [ ( "value", Json.Encode.string "Fudgesicles" )
                                , ( "label", Json.Encode.string "Fudgesicles" )
                                , ( "labelClean", Json.Encode.string "Fudgesicles" )
                                ]
                            ]
                        )
                    |> ProgramTest.ensureViewHas [ text "Orange" ]
                    |> ProgramTest.expectViewHas [ text "Fudgesicles" ]
        ]
