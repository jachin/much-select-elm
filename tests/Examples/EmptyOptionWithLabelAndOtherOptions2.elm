module Examples.EmptyOptionWithLabelAndOtherOptions2 exposing (suite)

import Html.Attributes
import Json.Decode
import Json.Encode
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import SimulatedEffect.Ports
import SimulatedEffect.Sub
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (attribute, classes, text)


optionsJson : String
optionsJson =
    """
[
  { "value": "", "label": "", "labelClean": "" },
  { "value": "car", "label": "Car", "labelClean": "Car" },
  { "value": "truck", "label": "Truck", "labelClean": "Truck" },
  { "value": "plane", "label": "Plane", "labelClean": "Plane" },
  { "value": "boat", "label": "boat", "labelClean": "boat" }
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
        |> ProgramTest.withSimulatedSubscriptions simulateSubscriptions
        |> ProgramTest.start flags


suite : Test
suite =
    describe "Example: empty-option-with-label-and-other-options-2"
        [ test "second empty-option variant maintains label/value mapping" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas [ text "Car" ]
                    |> ProgramTest.simulateIncomingPort
                        "selectOptionReceiver"
                        (Json.Encode.object
                            [ ( "value", Json.Encode.string "" )
                            , ( "label", Json.Encode.string "" )
                            , ( "labelClean", Json.Encode.string "" )
                            ]
                        )
                    |> ProgramTest.expectViewHas
                        [ classes [ "selected", "option" ]
                        , attribute (Html.Attributes.attribute "data-value" "")
                        ]
        ]
