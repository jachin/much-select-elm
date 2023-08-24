module OptionList exposing (OptionList(..))

import DatalistOption exposing (DatalistOption)
import FancyOption exposing (FancyOption)
import SlottedOption exposing (SlottedOption)


type OptionList
    = FancyOptionList (List FancyOption)
    | DatalistOptionList (List DatalistOption)
    | SlottedOptionList (List SlottedOption)
