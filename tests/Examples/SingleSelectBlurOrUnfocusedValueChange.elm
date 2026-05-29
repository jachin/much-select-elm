module Examples.SingleSelectBlurOrUnfocusedValueChange exposing (suite)

import Html.Attributes
import Json.Decode
import Json.Encode
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import SimulatedEffect.Ports
import SimulatedEffect.Sub
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (attribute, classes)


optionsJson : String
optionsJson =
    """
[
  { "value": "111", "label": "Grass Pea", "labelClean": "Grass Pea" },
  { "value": "222", "label": "Velvet Bean", "labelClean": "Velvet Bean" },
  { "value": "333", "label": "Sword Bean", "labelClean": "Sword Bean" },
  { "value": "444", "label": "Soybean", "labelClean": "Soybean" }
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
        [ SimulatedEffect.Ports.subscribe "valueChangedReceiver"
            Json.Decode.value
            MuchSelect.ValueChanged
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
    describe "Example: single-select-blur-or-unfocused-value-change"
        [ test "single-select value change while unfocused still updates model/view" <|
            \_ ->
                start
                    |> ProgramTest.simulateIncomingPort
                        "valueChangedReceiver"
                        (Json.Encode.string "222")
                    |> ProgramTest.expectViewHas
                        [ classes [ "selected", "option" ]
                        , attribute (Html.Attributes.attribute "data-value" "222")
                        ]
        ]
