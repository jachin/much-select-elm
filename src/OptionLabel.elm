module OptionLabel exposing (..)

import Json.Decode
import SortRank exposing (SortRank, sortRankDecoder)


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


getSortRank : OptionLabel -> SortRank
getSortRank optionLabel =
    case optionLabel of
        OptionLabel _ _ sortRank ->
            sortRank


labelDecoder : Json.Decode.Decoder OptionLabel
labelDecoder =
    Json.Decode.map3
        OptionLabel
        (Json.Decode.field "label" Json.Decode.string)
        (Json.Decode.field "labelClean" (Json.Decode.nullable Json.Decode.string))
        sortRankDecoder
