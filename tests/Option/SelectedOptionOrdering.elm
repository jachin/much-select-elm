module Option.SelectedOptionOrdering exposing (..)

import Json.Decode
import Json.Encode
import Main exposing (Flags)
import ProgramTest exposing (ProgramTest)
import SimulatedEffect.Cmd
import SimulatedEffect.Ports
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (all, classes, containing, id, text)


booksJsonWithIndexesAndWithSelected =
    """
[
  {
    "value": "The Enormous Crocodile",
    "label": "The Enormous Crocodile",
    "labelClean": "The Enormous Crocodile"
  },
  {
    "value": "James and the Giant Peach",
    "label": "James and the Giant Peach",
    "labelClean": "James and the Giant Peach"
  },
  {
    "value": "Matilda",
    "label": "Matilda",
    "labelClean": "Matilda",
    "selected": true
  },
  {
    "value": "The BFG",
    "label": "The BFG",
    "labelClean": "The BFG"
  }
]
"""


flagsBookOptionsWithSelected : Flags
flagsBookOptionsWithSelected =
    { value = Json.Encode.object []
    , placeholder = ( True, "A book" )
    , customOptionHint = Nothing
    , allowMultiSelect = False
    , outputStyle = "customHtml"
    , enableMultiSelectSingleItemRemoval = False
    , optionsJson = booksJsonWithIndexesAndWithSelected
    , optionSort = ""
    , loading = False
    , maxDropdownItems = 2
    , disabled = False
    , allowCustomOptions = False
    , selectedItemStaysInPlace = True
    , searchStringMinimumLength = 2
    , showDropdownFooter = False
    , transformationAndValidationJson = ""
    }


simulatedEffects : Main.Effect -> ProgramTest.SimulatedEffect Main.Msg
simulatedEffects effect =
    case effect of
        Main.NoEffect ->
            SimulatedEffect.Cmd.none

        Main.Batch effects ->
            SimulatedEffect.Cmd.batch (List.map simulatedEffects effects)

        Main.FocusInput ->
            SimulatedEffect.Ports.send "focusInput" (Json.Encode.object [])

        Main.BlurInput ->
            SimulatedEffect.Ports.send "blurInput" (Json.Encode.object [])

        Main.InputHasBeenFocused ->
            SimulatedEffect.Ports.send "inputFocused" (Json.Encode.object [])

        Main.InputHasBeenBlurred ->
            SimulatedEffect.Ports.send "inputBlurred" (Json.Encode.object [])

        Main.InputHasBeenKeyUp string _ ->
            SimulatedEffect.Ports.send "inputKeyUp" (Json.Encode.string string)

        Main.SearchStringTouched _ ->
            SimulatedEffect.Cmd.none

        Main.UpdateOptionsInWebWorker ->
            SimulatedEffect.Ports.send "updateOptionsInWebWorker" (Json.Encode.object [])

        Main.SearchOptionsWithWebWorker value ->
            SimulatedEffect.Ports.send "searchOptionsWithWebWorker" value

        Main.ReportValueChanged value ->
            SimulatedEffect.Ports.send "valueChanged" value

        Main.ValueCleared ->
            SimulatedEffect.Ports.send "valueCleared" (Json.Encode.object [])

        Main.InvalidValue value ->
            SimulatedEffect.Ports.send "invalidValue" value

        Main.CustomOptionSelected strings ->
            SimulatedEffect.Ports.send "invalidValue" (Json.Encode.list Json.Encode.string strings)

        Main.ReportOptionSelected value ->
            SimulatedEffect.Ports.send "optionSelected" value

        Main.OptionDeselected value ->
            SimulatedEffect.Ports.send "optionDeselected" value

        Main.OptionsUpdated bool ->
            SimulatedEffect.Ports.send "optionDeselected" (Json.Encode.bool bool)

        Main.SendCustomValidationRequest ( string, int ) ->
            SimulatedEffect.Ports.send "sendCustomValidationRequest"
                (Json.Encode.list identity
                    [ Json.Encode.string string
                    , Json.Encode.int int
                    ]
                )

        Main.ReportErrorMessage string ->
            SimulatedEffect.Ports.send "errorMessage" (Json.Encode.string string)

        Main.ReportReady ->
            SimulatedEffect.Ports.send "ready" (Json.Encode.object [])

        Main.ReportInitialValueSet value ->
            SimulatedEffect.Ports.send "initialValueSet" value

        Main.FetchOptionsFromDom ->
            SimulatedEffect.Ports.send "ready" (Json.Encode.object [])

        Main.ScrollDownToElement string ->
            SimulatedEffect.Ports.send "scrollDropdownToElement" (Json.Encode.string string)

        Main.ReportAllOptions value ->
            SimulatedEffect.Ports.send "allOptions" value


simulateSubscriptions : Main.Model -> ProgramTest.SimulatedSub Main.Msg
simulateSubscriptions _ =
    SimulatedEffect.Ports.subscribe "addOptions"
        Json.Decode.value
        Main.AddOptions


start : ProgramTest Main.Model Main.Msg Main.Effect
start =
    ProgramTest.createElement
        { init = Main.init, update = Main.update, view = Main.view }
        |> ProgramTest.withSimulatedEffects simulatedEffects
        |> ProgramTest.withSimulatedSubscriptions simulateSubscriptions
        |> ProgramTest.start flagsBookOptionsWithSelected


suite : Test
suite =
    describe "Selected Option Ordering"
        [ test "initial selected value should be selected" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas
                        [ all
                            [ id "selected-value"
                            , containing [ text "Matilda" ]
                            ]
                        ]
                    |> ProgramTest.ensureViewHas
                        [ classes [ "selected", "option" ]
                        , containing
                            [ text "Matilda" ]
                        ]
                    |> ProgramTest.ensureViewHas
                        [ classes [ "option" ]
                        , containing
                            [ text "The BFG" ]
                        ]
                    |> ProgramTest.expectViewHasNot
                        [ classes [ "selected", "option" ]
                        , containing
                            [ text "The BFG" ]
                        ]
        ]
