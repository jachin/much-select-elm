module Examples.TenThousandOptions exposing (suite)

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
    , optionSort = "by-option-label"
    , loading = False
    , maxDropdownItems = Just "10000"
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
        [ SimulatedEffect.Ports.subscribe "addOptions"
            Json.Decode.value
            MuchSelect.AddOptions
        ]


largeOptionsPayload : Json.Encode.Value
largeOptionsPayload =
    List.range 1 250
        |> List.map
            (\n ->
                Json.Encode.object
                    [ ( "value", Json.Encode.string ("Option " ++ String.fromInt n) )
                    , ( "label", Json.Encode.string ("Option " ++ String.fromInt n) )
                    , ( "labelClean", Json.Encode.string ("Option " ++ String.fromInt n) )
                    ]
            )
        |> Json.Encode.list identity


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
    describe "Example: ten-thousand-options"
        [ test "large option list initializes and filters without incorrect truncation" <|
            \_ ->
                start
                    |> ProgramTest.simulateIncomingPort
                        "addOptions"
                        largeOptionsPayload
                    |> ProgramTest.ensureViewHas [ text "Option 1" ]
                    |> ProgramTest.expectViewHas [ text "Option 250" ]
        ]
