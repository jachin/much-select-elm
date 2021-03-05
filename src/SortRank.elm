module SortRank exposing (SortRank(..), sortRankDecoder)

import Json.Decode
import PositiveInt exposing (PositiveInt)


type SortRank
    = Auto PositiveInt
    | Manual PositiveInt
    | NoSortRank


sortRankDecoder : Json.Decode.Decoder SortRank
sortRankDecoder =
    Json.Decode.oneOf
        [ Json.Decode.field "index" Json.Decode.int
            |> Json.Decode.andThen
                (\int ->
                    case PositiveInt.maybeNew int of
                        Just positiveInt ->
                            Json.Decode.succeed (Auto positiveInt)

                        Nothing ->
                            Json.Decode.fail "The index must be a positive number."
                )
        , Json.Decode.field "weight" Json.Decode.int
            |> Json.Decode.andThen
                (\int ->
                    case PositiveInt.maybeNew int of
                        Just positiveInt ->
                            Json.Decode.succeed (Manual positiveInt)

                        Nothing ->
                            Json.Decode.fail "The weight must be a positive number."
                )
        , Json.Decode.succeed NoSortRank
        ]
