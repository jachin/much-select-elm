module Examples.OverrideNoFilteredOptionsSlot exposing (suite)

import Html.Attributes
import Json.Decode
import Json.Encode
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import SimulatedEffect.Ports
import SimulatedEffect.Sub
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (attribute, text)


optionsJson : String
optionsJson =
    """
[
  { "value": "Black Tea", "label": "Black Tea", "labelClean": "Black Tea" },
  { "value": "Green Tea", "label": "Green Tea", "labelClean": "Green Tea" },
  { "value": "Red Tea", "label": "Red Tea", "labelClean": "Red Tea" }
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


simulateSubscriptions : MuchSelect.Model -> ProgramTest.SimulatedSub MuchSelect.Msg
simulateSubscriptions _ =
    SimulatedEffect.Sub.batch
        [ SimulatedEffect.Ports.subscribe "searchStringReceiver"
            Json.Decode.string
            MuchSelect.UpdateSearchString
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
    describe "Example: override-no-filtered-options-slot"
        [ test "search input updates while no-filtered-options slot is configured" <|
            \_ ->
                start
                    |> ProgramTest.simulateIncomingPort
                        "searchStringReceiver"
                        (Json.Encode.string "coffee")
                    |> ProgramTest.expectViewHas
                        [ attribute (Html.Attributes.value "coffee")
                        , text "Black Tea"
                        ]
        ]
