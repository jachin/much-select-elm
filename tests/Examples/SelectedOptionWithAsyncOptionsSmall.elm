module Examples.SelectedOptionWithAsyncOptionsSmall exposing (suite)

import Html.Attributes
import Json.Decode
import Json.Encode
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import SimulatedEffect.Ports
import SimulatedEffect.Sub
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (attribute, classes, text)


initialOptionsJson : String
initialOptionsJson =
    """
[
  { "value": "les Escaldes", "label": "les Escaldes", "labelClean": "les Escaldes" }
]
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = "les Escaldes"
    , selectedValueEncoding = Nothing
    , placeholder = ( True, "" )
    , customOptionHint = Nothing
    , allowMultiSelect = False
    , outputStyle = "customHtml"
    , enableMultiSelectSingleItemRemoval = False
    , optionsJson = initialOptionsJson
    , optionSort = ""
    , loading = False
    , maxDropdownItems = Just "30"
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
    describe "Example: selected-option-with-async-options-small"
        [ test "small async option payload still preserves selected option" <|
            \_ ->
                start
                    |> ProgramTest.simulateIncomingPort
                        "addOptions"
                        (Json.Encode.list identity
                            [ Json.Encode.object
                                [ ( "value", Json.Encode.string "Andorra la Vella" )
                                , ( "label", Json.Encode.string "Andorra la Vella" )
                                , ( "labelClean", Json.Encode.string "Andorra la Vella" )
                                ]
                            ]
                        )
                    |> ProgramTest.ensureViewHas
                        [ classes [ "selected", "option" ]
                        , attribute (Html.Attributes.attribute "data-value" "les Escaldes")
                        ]
                    |> ProgramTest.expectViewHas [ text "Andorra la Vella" ]
        ]
