module IntegrationTests.DisplayingOptions exposing (suite)

import Main
import ProgramTest exposing (ProgramTest, expectView, expectViewHas)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (text)


start : ProgramTest Main.Model Main.Msg (Cmd Main.Msg)
start =
    ProgramTest.createElement
        { init = Main.init
        , update = Main.update
        , view = Main.view
        }
        |> ProgramTest.start
            { value = "Orange"
            , placeholder = "What is your favorite color"
            , size = ""
            , allowMultiSelect = False
            , optionsJson = "[]"
            , loading = False
            , maxDropdownItems = 10
            , disabled = False
            , allowCustomOptions = False
            }


suite : Test
suite =
    describe "When displaying the "
        [ test "If there is an initial value create an option for it" <|
            \() ->
                start
                    |> expectViewHas
                        [ text "Orange"
                        ]
        ]
