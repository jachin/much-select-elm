module IntegrationTests.DisplayingOptions exposing (suite)

import Html.Attributes
import Json.Encode
import Main exposing (Flags)
import ProgramTest
    exposing
        ( ProgramTest
        , ensureViewHas
        , ensureViewHasNot
        , expectViewHas
        , expectViewHasNot
        )
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (classes, text)


flagsEmptyOptionsWithOrangeSelected : Flags
flagsEmptyOptionsWithOrangeSelected =
    { value = Json.Encode.list Json.Encode.string [ "Orange" ]
    , placeholder = "What is your favorite color"
    , customOptionHint = Nothing
    , allowMultiSelect = False
    , enableMultiSelectSingleItemRemoval = False
    , optionsJson = "[]"
    , loading = False
    , maxDropdownItems = 10
    , disabled = False
    , allowCustomOptions = False
    , selectedItemStaysInPlace = True
    , searchStringMinimumLength = 2
    }


booksJson =
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
    "labelClean": "Matilda"
  },
  {
    "value": "The BFG",
    "label": "The BFG",
    "labelClean": "The BFG"
  }
]
"""


booksJsonWithSelected =
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


flagsBookOptions : Flags
flagsBookOptions =
    { value = Json.Encode.object []
    , placeholder = "A book"
    , customOptionHint = Nothing
    , allowMultiSelect = False
    , enableMultiSelectSingleItemRemoval = False
    , optionsJson = booksJson
    , loading = False
    , maxDropdownItems = 2
    , disabled = False
    , allowCustomOptions = False
    , selectedItemStaysInPlace = True
    , searchStringMinimumLength = 2
    }


flagsBookOptionsWithValue : Flags
flagsBookOptionsWithValue =
    { value = Json.Encode.list Json.Encode.string [ "Matilda" ]
    , placeholder = "A book"
    , customOptionHint = Nothing
    , allowMultiSelect = False
    , enableMultiSelectSingleItemRemoval = False
    , optionsJson = booksJson
    , loading = False
    , maxDropdownItems = 2
    , disabled = False
    , allowCustomOptions = False
    , selectedItemStaysInPlace = True
    , searchStringMinimumLength = 2
    }


flagsBookOptionsWithSelected : Flags
flagsBookOptionsWithSelected =
    { value = Json.Encode.object []
    , placeholder = "A book"
    , customOptionHint = Nothing
    , allowMultiSelect = False
    , enableMultiSelectSingleItemRemoval = False
    , optionsJson = booksJsonWithSelected
    , loading = False
    , maxDropdownItems = 2
    , disabled = False
    , allowCustomOptions = False
    , selectedItemStaysInPlace = True
    , searchStringMinimumLength = 2
    }


element =
    ProgramTest.createElement
        { init = Main.init
        , update = Main.update
        , view = Main.view
        }


start : Flags -> ProgramTest Main.Model Main.Msg (Cmd Main.Msg)
start flags =
    element
        |> ProgramTest.start
            flags


suite : Test
suite =
    describe "When displaying the dropdown"
        [ test "if there is an initial value create an option for it" <|
            \() ->
                start flagsEmptyOptionsWithOrangeSelected
                    |> expectViewHas
                        [ text "Orange"
                        ]
        , describe "with initial options"
            [ test "if there is an initial selected attribute and a list of options where the selection is not reflected the value should still be selected" <|
                \() ->
                    start flagsBookOptionsWithValue
                        |> expectViewHas
                            [ classes [ "selected", "option" ]
                            , Test.Html.Selector.attribute (Html.Attributes.attribute "data-value" "Matilda")
                            ]
            ]
        , describe "if there are more options that there are max dropdown options"
            [ test "only show the first ones" <|
                \_ ->
                    start flagsBookOptions
                        |> ensureViewHas
                            [ text "The Enormous Crocodile"
                            ]
                        |> ensureViewHas
                            [ text "James and the Giant Peach"
                            ]
                        |> ensureViewHasNot
                            [ text "Matilda" ]
                        |> expectViewHasNot
                            [ text "The BFG" ]
            , test "show the options around the selected option" <|
                \_ ->
                    start flagsBookOptionsWithSelected
                        |> ensureViewHasNot
                            [ text "The Enormous Crocodile"
                            ]
                        |> ensureViewHasNot
                            [ text "James and the Giant Peach"
                            ]
                        |> ensureViewHas
                            [ text "Matilda" ]
                        |> expectViewHas
                            [ text "The BFG" ]
            ]
        ]
