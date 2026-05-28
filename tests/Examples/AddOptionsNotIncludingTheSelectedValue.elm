module Examples.AddOptionsNotIncludingTheSelectedValue exposing (suite)

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
    , selectedValue = "Butter"
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
    describe "Example: add-options-not-including-the-selected-value"
        [ test "selected value remains synthetic/selected when options update excludes it" <|
            \_ ->
                start
                    |> ProgramTest.simulateIncomingPort
                        "optionsReplacedReceiver"
                        (Json.Encode.list identity
                            [ Json.Encode.object
                                [ ( "value", Json.Encode.string "Jam" )
                                , ( "label", Json.Encode.string "Jam" )
                                , ( "labelClean", Json.Encode.string "Jam" )
                                ]
                            , Json.Encode.object
                                [ ( "value", Json.Encode.string "Marmalade" )
                                , ( "label", Json.Encode.string "Marmalade" )
                                , ( "labelClean", Json.Encode.string "Marmalade" )
                                ]
                            ]
                        )
                    |> ProgramTest.ensureViewHas
                        [ classes [ "selected", "option" ]
                        , attribute (Html.Attributes.attribute "data-value" "Butter")
                        ]
                    |> ProgramTest.expectViewHas [ text "Jam" ]
        ]
