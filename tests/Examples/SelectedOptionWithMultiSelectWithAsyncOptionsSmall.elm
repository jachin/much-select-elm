module Examples.SelectedOptionWithMultiSelectWithAsyncOptionsSmall exposing (suite)

import Json.Decode
import Json.Encode
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import SimulatedEffect.Ports
import SimulatedEffect.Sub
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (classes, containing, text)


initialOptionsJson : String
initialOptionsJson =
    """
[
  { "value": "les Escaldes", "label": "les Escaldes", "labelClean": "les Escaldes" },
  { "value": "Andorra la Vella", "label": "Andorra la Vella", "labelClean": "Andorra la Vella" }
]
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = "les Escaldes,Andorra la Vella"
    , selectedValueEncoding = Nothing
    , placeholder = ( True, "" )
    , customOptionHint = Nothing
    , allowMultiSelect = True
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
        [ SimulatedEffect.Ports.subscribe "addOptions"
            Json.Decode.value
            MuchSelect.AddOptions
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
    describe "Example: selected-option-with-multi-select-with-async-options-small"
        [ test "multi-select selected values are preserved after async hydration" <|
            \_ ->
                start
                    |> ProgramTest.simulateIncomingPort
                        "addOptions"
                        (Json.Encode.list identity
                            [ Json.Encode.object
                                [ ( "value", Json.Encode.string "Umm al Qaywayn" )
                                , ( "label", Json.Encode.string "Umm al Qaywayn" )
                                , ( "labelClean", Json.Encode.string "Umm al Qaywayn" )
                                ]
                            ]
                        )
                    |> ProgramTest.ensureViewHas
                        [ classes [ "value", "selected-value" ]
                        , containing [ text "les Escaldes" ]
                        ]
                    |> ProgramTest.ensureViewHas
                        [ classes [ "value", "selected-value" ]
                        , containing [ text "Andorra la Vella" ]
                        ]
                    |> ProgramTest.expectViewHas [ text "Umm al Qaywayn" ]
        ]
