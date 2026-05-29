module Examples.RemoteApiExample exposing (suite)

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
    , searchStringMinimumLength = Just "3"
    , showDropdownFooter = False
    , transformationAndValidationJson = ""
    }


simulateSubscriptions : MuchSelect.Model -> ProgramTest.SimulatedSub MuchSelect.Msg
simulateSubscriptions _ =
    SimulatedEffect.Sub.batch
        [ SimulatedEffect.Ports.subscribe "addOptions"
            Json.Decode.value
            MuchSelect.AddOptions
        , SimulatedEffect.Ports.subscribe "selectOptionReceiver"
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
    describe "Example: remote-api-example"
        [ test "remote options response updates list and supports selection" <|
            \_ ->
                start
                    |> ProgramTest.simulateIncomingPort
                        "addOptions"
                        (Json.Encode.list identity
                            [ Json.Encode.object
                                [ ( "value", Json.Encode.string "Rick Sanchez" )
                                , ( "label", Json.Encode.string "Rick Sanchez" )
                                , ( "labelClean", Json.Encode.string "Rick Sanchez" )
                                ]
                            , Json.Encode.object
                                [ ( "value", Json.Encode.string "Morty Smith" )
                                , ( "label", Json.Encode.string "Morty Smith" )
                                , ( "labelClean", Json.Encode.string "Morty Smith" )
                                ]
                            ]
                        )
                    |> ProgramTest.simulateIncomingPort
                        "selectOptionReceiver"
                        (Json.Encode.object
                            [ ( "value", Json.Encode.string "Rick Sanchez" )
                            , ( "label", Json.Encode.string "Rick Sanchez" )
                            , ( "labelClean", Json.Encode.string "Rick Sanchez" )
                            ]
                        )
                    |> ProgramTest.ensureViewHas
                        [ classes [ "selected", "option" ]
                        , attribute (Html.Attributes.attribute "data-value" "Rick Sanchez")
                        ]
                    |> ProgramTest.expectViewHas [ text "Morty Smith" ]
        ]
