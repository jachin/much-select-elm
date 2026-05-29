module Examples.ReadyEvent exposing (suite)

import Expect
import MuchSelect exposing (Flags)
import ProgramTest exposing (expectLastEffect)
import Test exposing (Test, describe, test)


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
    , optionsJson = "[]"
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


element =
    ProgramTest.createElement
        { init = MuchSelect.init
        , update = MuchSelect.update
        , view = MuchSelect.view
        }


suite : Test
suite =
    describe "Example: ready-event"
        [ test "component init emits ready event exactly once" <|
            \_ ->
                element
                    |> ProgramTest.start flags
                    |> expectLastEffect
                        (\effect ->
                            case effect of
                                MuchSelect.Batch effects ->
                                    if List.member MuchSelect.ReportReady effects then
                                        Expect.equal 1 (List.length (List.filter ((==) MuchSelect.ReportReady) effects))

                                    else
                                        Expect.fail "Expected ReportReady in init effects"

                                _ ->
                                    Expect.fail "Expected init to return a batch of effects"
                        )
        ]
