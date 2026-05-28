module Examples.RemoveAnOptionFromAMuchSelect exposing (suite)

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
  { "value": "Ice Cream", "label": "Ice Cream", "labelClean": "Ice Cream" },
  { "value": "Cake", "label": "Cake", "labelClean": "Cake" },
  { "value": "Pie", "label": "Pie", "labelClean": "Pie" },
  { "value": "Candy", "label": "Candy", "labelClean": "Candy" },
  { "value": "Pudding", "label": "Pudding", "labelClean": "Pudding" }
]
"""


flags : Flags
flags =
    { isEventsOnly = False
    , selectedValue = "Pie"
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
        [ SimulatedEffect.Ports.subscribe "removeOptionsReceiver"
            Json.Decode.value
            MuchSelect.RemoveOptions
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
    describe "Example: remove-an-option-from-a-much-select"
        [ test "remove option updates option list and selected state" <|
            \_ ->
                start
                    |> ProgramTest.simulateIncomingPort
                        "removeOptionsReceiver"
                        (Json.Encode.list identity
                            [ Json.Encode.object
                                [ ( "value", Json.Encode.string "Pie" )
                                , ( "label", Json.Encode.string "Pie" )
                                , ( "labelClean", Json.Encode.string "Pie" )
                                ]
                            ]
                        )
                    |> ProgramTest.ensureViewHas [ text "Cake" ]
                    |> ProgramTest.ensureViewHas [ classes [ "no-option-selected" ] ]
                    |> ProgramTest.expectViewHasNot
                        [ classes [ "selected", "option" ]
                        , attribute (Html.Attributes.attribute "data-value" "Pie")
                        ]
        ]
