module PositiveInt exposing (PositiveInt, new, toInt)


type PositiveInt
    = PositiveInt Int


new : Int -> PositiveInt
new int =
    PositiveInt (abs int)


toInt : PositiveInt -> Int
toInt positiveInt =
    case positiveInt of
        PositiveInt int ->
            int
