module Option.SelectedOptionOrdering exposing (..)

import Json.Decode
import Json.Encode
import Main exposing (Flags)
import ProgramTest exposing (ProgramTest)
import SimulatedEffect.Cmd
import SimulatedEffect.Ports
import Test exposing (Test, describe, test)
import Test.Html.Query exposing (find)
import Test.Html.Selector exposing (all, class, classes, containing, exactClassName, id, text)


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

        Main.InputHasBeenKeyUp string ->
            SimulatedEffect.Ports.send "inputKeyUp" (Json.Encode.string string)

        Main.SearchStringTouched float ->
            SimulatedEffect.Cmd.none

        Main.UpdateOptionsInWebWorker ->
            SimulatedEffect.Cmd.none

        Main.SearchOptionsWithWebWorker value ->
            SimulatedEffect.Cmd.none

        Main.ReportValueChanged value ->
            SimulatedEffect.Cmd.none

        Main.ValueCleared ->
            SimulatedEffect.Cmd.none

        Main.InvalidValue value ->
            SimulatedEffect.Cmd.none

        Main.CustomOptionSelected strings ->
            SimulatedEffect.Cmd.none

        Main.ReportOptionSelected value ->
            SimulatedEffect.Cmd.none

        Main.OptionDeselected value ->
            SimulatedEffect.Cmd.none

        Main.OptionsUpdated bool ->
            SimulatedEffect.Cmd.none

        Main.SendCustomValidationRequest ( string, int ) ->
            SimulatedEffect.Cmd.none

        Main.ReportErrorMessage string ->
            SimulatedEffect.Cmd.none

        Main.ReportReady ->
            SimulatedEffect.Cmd.none

        Main.ReportInitialValueSet value ->
            SimulatedEffect.Cmd.none

        Main.FetchOptionsFromDom ->
            SimulatedEffect.Cmd.none

        Main.ScrollDownToElement string ->
            SimulatedEffect.Cmd.none

        Main.ReportAllOptions value ->
            SimulatedEffect.Cmd.none


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
