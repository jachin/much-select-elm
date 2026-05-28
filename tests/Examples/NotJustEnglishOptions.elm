module Examples.NotJustEnglishOptions exposing (suite)

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
  { "value": "hvid", "label": "hvid", "labelClean": "hvid" },
  { "value": "gul", "label": "gul", "labelClean": "gul" },
  { "value": "orange", "label": "orange", "labelClean": "orange" },
  { "value": "pink", "label": "pink", "labelClean": "pink" },
  { "value": "rød", "label": "rød", "labelClean": "rod" },
  { "value": "brun", "label": "brun", "labelClean": "brun" },
  { "value": "grøn", "label": "grøn", "labelClean": "gron" },
  { "value": "blå", "label": "blå", "labelClean": "bla" },
  { "value": "lilla", "label": "lilla", "labelClean": "lilla" },
  { "value": "grå", "label": "grå", "labelClean": "gra" },
  { "value": "sølvfarvet", "label": "sølvfarvet", "labelClean": "solvfarvet" },
  { "value": "guldfarvet", "label": "guldfarvet", "labelClean": "guldfarvet" }
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
    describe "Example: not-just-english-options"
        [ test "unicode option labels/values render and search correctly" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas [ text "rød" ]
                    |> ProgramTest.simulateIncomingPort
                        "selectOptionReceiver"
                        (Json.Encode.object
                            [ ( "value", Json.Encode.string "grå" )
                            , ( "label", Json.Encode.string "grå" )
                            , ( "labelClean", Json.Encode.string "gra" )
                            ]
                        )
                    |> ProgramTest.expectViewHas
                        [ classes [ "selected", "option" ]
                        , attribute (Html.Attributes.attribute "data-value" "grå")
                        ]
        ]
