module Examples.ChangeTheOptionsWithTheDom exposing (suite)

import Json.Decode
import Json.Encode
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import SimulatedEffect.Ports
import SimulatedEffect.Sub
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (text)


initialOptionsJson : String
initialOptionsJson =
    """
[
  { "value": "1", "label": "These", "labelClean": "These" },
  { "value": "2", "label": "are", "labelClean": "are" },
  { "value": "3", "label": "the", "labelClean": "the" },
  { "value": "4", "label": "Replace", "labelClean": "Replace" }
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
    , optionsJson = initialOptionsJson
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
    describe "Example: change-the-options-with-the-dom"
        [ test "light DOM option changes are re-read and reflected in model" <|
            \_ ->
                start
                    |> ProgramTest.simulateIncomingPort
                        "optionsReplacedReceiver"
                        (Json.Encode.list identity
                            [ Json.Encode.object
                                [ ( "value", Json.Encode.string "100" )
                                , ( "label", Json.Encode.string "New" )
                                , ( "labelClean", Json.Encode.string "New" )
                                ]
                            , Json.Encode.object
                                [ ( "value", Json.Encode.string "200" )
                                , ( "label", Json.Encode.string "options" )
                                , ( "labelClean", Json.Encode.string "options" )
                                ]
                            , Json.Encode.object
                                [ ( "value", Json.Encode.string "3" )
                                , ( "label", Json.Encode.string "are" )
                                , ( "labelClean", Json.Encode.string "are" )
                                ]
                            ]
                        )
                    |> ProgramTest.ensureViewHas [ text "New" ]
                    |> ProgramTest.expectViewHasNot [ text "These" ]
        ]
