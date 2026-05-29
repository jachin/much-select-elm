module Examples.ValidationAndTransformationSlotSingleCustomHtml exposing (suite)

import Json.Decode
import Json.Encode
import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import SimulatedEffect.Ports
import SimulatedEffect.Sub
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (classes, id, text)


optionsJson : String
optionsJson =
    """
[
  { "value": "Apple", "label": "Apple", "labelClean": "Apple" },
  { "value": "Asian pear", "label": "Asian pear", "labelClean": "Asian pear" },
  { "value": "Pear", "label": "Pear", "labelClean": "Pear" }
]
"""


transformationAndValidationJson : String
transformationAndValidationJson =
    """
{
  "transformers": [
    { "name": "lowercase" }
  ],
  "validators": [
    {
      "name": "no-white-space",
      "level": "error",
      "message": "Spaces are not allow for custom fruit."
    },
    {
      "name": "minimum-length",
      "level": "silent",
      "minimum-length": 3,
      "message": "The minimum length is 3."
    }
  ]
}
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
    , allowCustomOptions = True
    , selectedItemStaysInPlace = True
    , searchStringMinimumLength = Nothing
    , showDropdownFooter = False
    , transformationAndValidationJson = transformationAndValidationJson
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
    describe "Example: validation-and-transformation-slot-single-custom-html"
        [ test "single custom-html applies lowercase transformer to custom option label" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas
                        [ id "value-casing"
                        , classes [ "single", "allows-custom-options" ]
                        ]
                    |> ProgramTest.simulateIncomingPort
                        "searchStringReceiver"
                        (Json.Encode.string "PEARL")
                    |> ProgramTest.simulateIncomingPort
                        "searchStringSteadyReceiver"
                        Json.Encode.null
                    |> ProgramTest.expectViewHas [ text "Add pearl…" ]
        ]
