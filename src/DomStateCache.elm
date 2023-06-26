module DomStateCache exposing (CustomOptionsAttribute(..), DomStateCache, OutputStyleAttribute(..), updateAllowCustomOptions, updateOutputStyle)


type alias DomStateCache =
    { allowCustomOptions : CustomOptionsAttribute
    , outputStyle : OutputStyleAttribute
    }


type CustomOptionsAttribute
    = CustomOptionsNotAllowed
    | CustomOptionsAllowed
    | CustomOptionsAllowedWithHint String


type OutputStyleAttribute
    = OutputStyleDatalist
    | OutputStyleCustomHtml


updateAllowCustomOptions : CustomOptionsAttribute -> DomStateCache -> DomStateCache
updateAllowCustomOptions customOptions domStateCache =
    { domStateCache | allowCustomOptions = customOptions }


updateOutputStyle : OutputStyleAttribute -> DomStateCache -> DomStateCache
updateOutputStyle outputStyleAttribute domStateCache =
    { domStateCache | outputStyle = outputStyleAttribute }
