module Examples.AddOptionsIncludingTheSelectedValue exposing (suite)

import Html.Attributes
import Json.Decode
import Json.Encode
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import SimulatedEffect.Ports
import SimulatedEffect.Sub
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (attribute, classes, text)


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = "Coffee"
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
    describe "Example: add-options-including-the-selected-value"
        [ test "newly added option matching selected-value is marked selected" <|
            \_ ->
                start
                    |> ProgramTest.simulateIncomingPort
                        "optionsReplacedReceiver"
                        (Json.Encode.list identity
                            [ Json.Encode.object
                                [ ( "value", Json.Encode.string "Coffee" )
                                , ( "label", Json.Encode.string "Coffee" )
                                , ( "labelClean", Json.Encode.string "Coffee" )
                                ]
                            , Json.Encode.object
                                [ ( "value", Json.Encode.string "Tea" )
                                , ( "label", Json.Encode.string "Tea" )
                                , ( "labelClean", Json.Encode.string "Tea" )
                                ]
                            ]
                        )
                    |> ProgramTest.ensureViewHas
                        [ classes [ "selected", "option" ]
                        , attribute (Html.Attributes.attribute "data-value" "Coffee")
                        ]
                    |> ProgramTest.expectViewHas [ text "Tea" ]
        ]
