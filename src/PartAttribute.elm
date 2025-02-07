module PartAttribute exposing (part, partsList)

import Html
import Html.Attributes


part p =
    Html.Attributes.attribute "part" p


partsList : List ( String, Bool ) -> Html.Attribute msg
partsList classes =
    part <|
        String.join " " <|
            List.map Tuple.first <|
                List.filter Tuple.second classes
