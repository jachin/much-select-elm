module Examples.ChangeSelectAttributeChangesSelectedValueInMuchSelect exposing (suite)

import Expect
import Json.Decode
import Json.Encode
import MuchSelect exposing (Flags)
import Ports
import ProgramTest exposing (ProgramTest)
import SelectionMode
import SimulatedEffect.Cmd
import SimulatedEffect.Ports
import Test exposing (Test, describe, test)


optionsJson : String
optionsJson =
    """
[
  { "value": "Larry", "label": "Larry", "labelClean": "Larry" },
  { "value": "Moe", "label": "Moe", "labelClean": "Moe" },
  { "value": "Curly Joe", "label": "Curly Joe", "labelClean": "Curly Joe" }
]
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = "Larry"
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
    SimulatedEffect.Ports.subscribe "attributeChanged"
        (Json.Decode.map2
            Tuple.pair
            (Json.Decode.index 0 Json.Decode.string)
            (Json.Decode.index 1 Json.Decode.string)
        )
        MuchSelect.AttributeChanged


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
    describe "Example: change-select-attribute-changes-selected-value-in-much-select"
        [ test "attributeChanged selected-value updates selection and reports value change" <|
            \_ ->
                start
                    |> ProgramTest.simulateIncomingPort
                        "attributeChanged"
                        (Json.Encode.list Json.Encode.string [ "selected-value", "Moe" ])
                    |> ProgramTest.expectOutgoingPortValues
                        "valueChangedSingleSelect"
                        Ports.optionsDecoder
                        (Expect.equal
                            [ [ { value = "Moe"
                                , label = "Moe"
                                , isValid = True
                                , selectedIndex = 0
                                }
                              ]
                            ]
                        )
        ]
