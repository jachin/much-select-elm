module OptionLabel exposing (..)

import SortRank exposing (SortRank)


type OptionLabel
    = OptionLabel String (Maybe String) SortRank


optionLabelToString : OptionLabel -> String
optionLabelToString optionLabel =
    case optionLabel of
        OptionLabel label _ _ ->
            label


optionLabelToSearchString : OptionLabel -> String
optionLabelToSearchString optionLabel =
    case optionLabel of
        OptionLabel string maybeCleanString _ ->
            case maybeCleanString of
                Just cleanString ->
                    cleanString

                Nothing ->
                    String.toLower string
