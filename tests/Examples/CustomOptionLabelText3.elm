module Examples.CustomOptionLabelText3 exposing (suite)

import Json.Decode
import Json.Encode
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import SimulatedEffect.Ports
import SimulatedEffect.Sub
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (text)


optionsJson : String
optionsJson =
    """
[
  { "value": "Back Rubs", "label": "Back Rubs", "labelClean": "Back Rubs" },
  { "value": "Baby Sitting", "label": "Baby Sitting", "labelClean": "Baby Sitting" },
  { "value": "Pies", "label": "Pies", "labelClean": "Pies" }
]
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = ""
    , selectedValueEncoding = Nothing
    , placeholder = ( True, "" )
    , customOptionHint = Just "{{}}"
    , allowMultiSelect = False
    , outputStyle = "customHtml"
    , enableMultiSelectSingleItemRemoval = False
    , optionsJson = optionsJson
    , optionSort = ""
    , loading = False
    , maxDropdownItems = Just "10"
    , disabled = False
    , allowCustomOptions = True
    , selectedItemStaysInPlace = True
    , searchStringMinimumLength = Nothing
    , showDropdownFooter = False
    , transformationAndValidationJson = ""
    }


simulateSubscriptions : MuchSelect.Model -> ProgramTest.SimulatedSub MuchSelect.Msg
simulateSubscriptions _ =
    SimulatedEffect.Sub.batch
        [ SimulatedEffect.Ports.subscribe "searchStringReceiver"
            Json.Decode.string
            MuchSelect.UpdateSearchString
        , SimulatedEffect.Ports.subscribe "searchStringSteadyReceiver"
            Json.Decode.value
            (\_ -> MuchSelect.SearchStringSteady)
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
    describe "Example: custom-option-label-text-3"
        [ test "placeholder-only custom-option template renders just the typed value" <|
            \_ ->
                start
                    |> ProgramTest.simulateIncomingPort
                        "searchStringReceiver"
                        (Json.Encode.string "Gift Card")
                    |> ProgramTest.simulateIncomingPort
                        "searchStringSteadyReceiver"
                        Json.Encode.null
                    |> ProgramTest.ensureViewHas [ text "Gift Card" ]
                    |> ProgramTest.expectViewHasNot [ text "Add Gift Card…" ]
        ]
