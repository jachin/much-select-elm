module Examples.LabelsAndValues exposing (suite)

import Expect
import Json.Decode
import Json.Encode
import MuchSelect exposing (Flags)
import Ports
import ProgramTest exposing (ProgramTest)
import SelectionMode
import SimulatedEffect.Cmd
import SimulatedEffect.Ports
import SimulatedEffect.Sub
import Test exposing (Test, describe, test)
import Test.Html.Selector


optionsJson : String
optionsJson =
    """
[
  { "value": "monkey", "label": "🐒", "labelClean": "🐒" },
  { "value": "tree", "label": "🌳", "labelClean": "🌳" },
  { "value": "panda", "label": "🐼", "labelClean": "🐼" },
  { "value": "ladybug", "label": "🐞", "labelClean": "🐞" },
  { "value": "butterfly", "label": "🦋", "labelClean": "🦋" },
  { "value": "rabbit", "label": "🐇", "labelClean": "🐇" }
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


simulateEffects : MuchSelect.Effect -> ProgramTest.SimulatedEffect MuchSelect.Msg
simulateEffects effect =
    case effect of
        MuchSelect.Batch effects ->
            effects
                |> List.map simulateEffects
                |> SimulatedEffect.Cmd.batch

        MuchSelect.ReportOptionSelected value ->
            SimulatedEffect.Ports.send "optionSelected" value

        MuchSelect.ReportValueChanged value selectionMode ->
            case selectionMode of
                SelectionMode.SingleSelect ->
                    SimulatedEffect.Ports.send "valueChangedSingleSelect" value

                SelectionMode.MultiSelect ->
                    SimulatedEffect.Ports.send "valueChangedMultiSelect" value

        _ ->
            SimulatedEffect.Cmd.none


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
        |> ProgramTest.withSimulatedEffects simulateEffects
        |> ProgramTest.withSimulatedSubscriptions simulateSubscriptions
        |> ProgramTest.start flags


suite : Test
suite =
    describe "Example: labels-and-values"
        [ test "uses label for display and value for emitted payload" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas [ Test.Html.Selector.text "🐒" ]
                    |> ProgramTest.simulateIncomingPort
                        "selectOptionReceiver"
                        (Json.Encode.object
                            [ ( "value", Json.Encode.string "monkey" )
                            , ( "label", Json.Encode.string "monkey" )
                            , ( "labelClean", Json.Encode.string "monkey" )
                            ]
                        )
                    |> ProgramTest.expectOutgoingPortValues
                        "optionSelected"
                        Ports.optionDecoder
                        (Expect.equal
                            [ { value = "monkey"
                              , label = "monkey"
                              , isValid = True
                              , selectedIndex = -1
                              }
                            ]
                        )
        ]
