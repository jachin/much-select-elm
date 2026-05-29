module Examples.MaxNumberOfDropdownItemsBigList exposing (suite)

import MuchSelect exposing (Flags)
import ProgramTest exposing (ProgramTest)
import Test exposing (Test, describe, test)
import Test.Html.Selector exposing (text)


optionsJson : String
optionsJson =
    """
[
  { "value": "Aachenosaurus", "label": "Aachenosaurus", "labelClean": "Aachenosaurus" },
  { "value": "Aardonyx", "label": "Aardonyx", "labelClean": "Aardonyx" },
  { "value": "Abdallahsaurus", "label": "Abdallahsaurus", "labelClean": "Abdallahsaurus" },
  { "value": "Abdarainurus", "label": "Abdarainurus", "labelClean": "Abdarainurus" },
  { "value": "Abelisaurus", "label": "Abelisaurus", "labelClean": "Abelisaurus" },
  { "value": "Abrictosaurus", "label": "Abrictosaurus", "labelClean": "Abrictosaurus" },
  { "value": "Abrosaurus", "label": "Abrosaurus", "labelClean": "Abrosaurus" },
  { "value": "Abydosaurus", "label": "Abydosaurus", "labelClean": "Abydosaurus" },
  { "value": "Acantholipan", "label": "Acantholipan", "labelClean": "Acantholipan" },
  { "value": "Acanthopholis", "label": "Acanthopholis", "labelClean": "Acanthopholis" },
  { "value": "Achelousaurus", "label": "Achelousaurus", "labelClean": "Achelousaurus" },
  { "value": "Acheroraptor", "label": "Acheroraptor", "labelClean": "Acheroraptor" },
  { "value": "Achillesaurus", "label": "Achillesaurus", "labelClean": "Achillesaurus" },
  { "value": "Achillobator", "label": "Achillobator", "labelClean": "Achillobator" },
  { "value": "Acristavus", "label": "Acristavus", "labelClean": "Acristavus" },
  { "value": "Acrocanthosaurus", "label": "Acrocanthosaurus", "labelClean": "Acrocanthosaurus" },
  { "value": "Acrotholus", "label": "Acrotholus", "labelClean": "Acrotholus" },
  { "value": "Actiosaurus", "label": "Actiosaurus", "labelClean": "Actiosaurus" },
  { "value": "Adamantisaurus", "label": "Adamantisaurus", "labelClean": "Adamantisaurus" },
  { "value": "Adasaurus", "label": "Adasaurus", "labelClean": "Adasaurus" },
  { "value": "Adelolophus", "label": "Adelolophus", "labelClean": "Adelolophus" }
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
    , maxDropdownItems = Just "20"
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


start : ProgramTest MuchSelect.Model MuchSelect.Msg MuchSelect.Effect
start =
    element
        |> ProgramTest.start flags


suite : Test
suite =
    describe "Example: max-number-of-dropdown-items-big-list"
        [ test "keeps dropdown bounded with a large option set" <|
            \_ ->
                start
                    |> ProgramTest.ensureViewHas [ text "Aachenosaurus" ]
                    |> ProgramTest.ensureViewHas [ text "Adasaurus" ]
                    |> ProgramTest.expectViewHasNot [ text "Adelolophus" ]
        ]
