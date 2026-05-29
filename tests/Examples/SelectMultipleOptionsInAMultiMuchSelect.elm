module Examples.SelectMultipleOptionsInAMultiMuchSelect exposing (suite)

import Json.Decode
import Json.Encode
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import SimulatedEffect.Ports
import SimulatedEffect.Sub
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (classes, containing, text)


optionsJson : String
optionsJson =
    """
[
  { "value": "Basketball", "label": "Basketball", "labelClean": "Basketball" },
  { "value": "Baseball", "label": "Baseball", "labelClean": "Baseball" },
  { "value": "Football", "label": "Football", "labelClean": "Football" },
  { "value": "Hockey", "label": "Hockey", "labelClean": "Hockey" },
  { "value": "Soccer", "label": "Soccer", "labelClean": "Soccer" }
]
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = ""
    , selectedValueEncoding = Nothing
    , placeholder = ( True, "" )
    , customOptionHint = Nothing
    , allowMultiSelect = True
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


simulateSubscriptions : MuchSelect.Model -> ProgramTest.SimulatedSub MuchSelect.Msg
simulateSubscriptions _ =
    SimulatedEffect.Sub.batch
        [ SimulatedEffect.Ports.subscribe "selectOptionReceiver"
            Json.Decode.value
            MuchSelect.SelectOption
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
    describe "Example: select-multiple-options-in-a-multi-much-select"
        [ test "programmatic multi selection marks all requested values selected" <|
            \_ ->
                start
                    |> ProgramTest.simulateIncomingPort
                        "selectOptionReceiver"
                        (Json.Encode.object
                            [ ( "value", Json.Encode.string "Basketball" )
                            , ( "label", Json.Encode.string "Basketball" )
                            , ( "labelClean", Json.Encode.string "Basketball" )
                            ]
                        )
                    |> ProgramTest.simulateIncomingPort
                        "selectOptionReceiver"
                        (Json.Encode.object
                            [ ( "value", Json.Encode.string "Football" )
                            , ( "label", Json.Encode.string "Football" )
                            , ( "labelClean", Json.Encode.string "Football" )
                            ]
                        )
                    |> ProgramTest.ensureViewHas
                        [ classes [ "value", "selected-value" ]
                        , containing [ text "Basketball" ]
                        ]
                    |> ProgramTest.expectViewHas
                        [ classes [ "value", "selected-value" ]
                        , containing [ text "Football" ]
                        ]
        ]
