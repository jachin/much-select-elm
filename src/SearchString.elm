module SearchString exposing (SearchString, decode, encode, isEmpty, length, new, reset, toLower, toString)

import Json.Decode
import Json.Encode


type SearchString
    = SearchString String


reset : SearchString
reset =
    SearchString ""


new : String -> SearchString
new string =
    SearchString string


length : SearchString -> Int
length (SearchString str) =
    String.length str


toLower : SearchString -> String
toLower (SearchString str) =
    String.toLower str


toString : SearchString -> String
toString (SearchString str) =
    str


isEmpty : SearchString -> Bool
isEmpty (SearchString str) =
    String.length str == 0


encode : SearchString -> Json.Encode.Value
encode searchString =
    Json.Encode.string (toString searchString)


decode : Json.Decode.Decoder SearchString
decode =
    Json.Decode.map
        SearchString
        Json.Decode.string
