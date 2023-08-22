module OptionList exposing (isSlottedOptionList)

import Option exposing (Option)


isSlottedOptionList : List Option -> Bool
isSlottedOptionList options =
    List.all
        (\option ->
            case option of
                Option.SlottedOption _ _ _ ->
                    True

                _ ->
                    False
        )
        options
