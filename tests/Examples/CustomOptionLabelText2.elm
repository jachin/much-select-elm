module Examples.CustomOptionLabelText2 exposing (suite)

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
  { "value": "Itchy and Scrachy Money", "label": "Itchy and Scrachy Money", "labelClean": "Itchy and Scrachy Money" },
  { "value": "Merits", "label": "Merits", "labelClean": "Merits" },
  { "value": "Diamonds", "label": "Diamonds", "labelClean": "Diamonds" }
]
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = ""
    , selectedValueEncoding = Nothing
    , placeholder = ( True, "" )
    , customOptionHint = Just "Create currency {{}}..."
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
    describe "Example: custom-option-label-text-2"
        [ test "second label-text variant applies configured custom label" <|
            \_ ->
                start
                    |> ProgramTest.simulateIncomingPort
                        "searchStringReceiver"
                        (Json.Encode.string "Dollars")
                    |> ProgramTest.simulateIncomingPort
                        "searchStringSteadyReceiver"
                        Json.Encode.null
                    |> ProgramTest.expectViewHas [ text "Create currency Dollars..." ]
        ]
