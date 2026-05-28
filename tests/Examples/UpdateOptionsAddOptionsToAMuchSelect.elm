module Examples.UpdateOptionsAddOptionsToAMuchSelect exposing (suite)

import Html.Attributes
import Json.Decode
import Json.Encode
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import SimulatedEffect.Ports
import SimulatedEffect.Sub
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (attribute, classes, text)


optionsJson : String
optionsJson =
    """
[
  { "value": "Metal", "label": "Metal", "labelClean": "Metal" },
  { "value": "Rock", "label": "Rock", "labelClean": "Rock" }
]
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = "Metal"
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
    describe "Example: update-options-add-options-to-a-much-select"
        [ test "update-options merges added options into existing list" <|
            \_ ->
                start
                    |> ProgramTest.simulateIncomingPort
                        "optionsReplacedReceiver"
                        (Json.Encode.list identity
                            [ Json.Encode.object
                                [ ( "value", Json.Encode.string "Jazz" )
                                , ( "label", Json.Encode.string "Jazz" )
                                , ( "labelClean", Json.Encode.string "Jazz" )
                                ]
                            , Json.Encode.object
                                [ ( "value", Json.Encode.string "Blues" )
                                , ( "label", Json.Encode.string "Blues" )
                                , ( "labelClean", Json.Encode.string "Blues" )
                                ]
                            ]
                        )
                    |> ProgramTest.ensureViewHas [ text "Jazz" ]
                    |> ProgramTest.ensureViewHas
                        [ classes [ "selected", "option" ]
                        , attribute (Html.Attributes.attribute "data-value" "Metal")
                        ]
                    |> ProgramTest.expectViewHas [ text "Blues" ]
        ]
