module SearchString exposing (SearchString, isEmpty, length, new, reset, toLower, toString)


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
