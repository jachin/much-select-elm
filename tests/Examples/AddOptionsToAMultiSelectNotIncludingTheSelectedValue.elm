module Examples.AddOptionsToAMultiSelectNotIncludingTheSelectedValue exposing (suite)

import Json.Decode
import Json.Encode
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import SimulatedEffect.Ports
import SimulatedEffect.Sub
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (classes, containing, text)


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = "Carrots,Peas"
    , selectedValueEncoding = Nothing
    , placeholder = ( True, "" )
    , customOptionHint = Nothing
    , allowMultiSelect = True
    , outputStyle = "customHtml"
    , enableMultiSelectSingleItemRemoval = True
    , optionsJson = "[]"
    , optionSort = ""
    , loading = False
    , maxDropdownItems = Just "10"
    , disabled = False
    , allowCustomOptions = True
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
    describe "Example: add-options-to-a-multi-select-not-including-the-selected-value"
        [ test "multi selected values stay selected when update payload omits selected entries" <|
            \_ ->
                start
                    |> ProgramTest.simulateIncomingPort
                        "optionsReplacedReceiver"
                        (Json.Encode.list identity
                            [ Json.Encode.object
                                [ ( "value", Json.Encode.string "Zucchini" )
                                , ( "label", Json.Encode.string "Zucchini" )
                                , ( "labelClean", Json.Encode.string "Zucchini" )
                                ]
                            , Json.Encode.object
                                [ ( "value", Json.Encode.string "Lettuce" )
                                , ( "label", Json.Encode.string "Lettuce" )
                                , ( "labelClean", Json.Encode.string "Lettuce" )
                                ]
                            ]
                        )
                    |> ProgramTest.ensureViewHas
                        [ classes [ "value", "selected-value" ]
                        , containing [ text "Carrots" ]
                        ]
                    |> ProgramTest.ensureViewHas
                        [ classes [ "value", "selected-value" ]
                        , containing [ text "Peas" ]
                        ]
                    |> ProgramTest.expectViewHas [ text "Zucchini" ]
        ]
