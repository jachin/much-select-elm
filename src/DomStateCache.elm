module DomStateCache exposing (CustomOptionsAttribute(..), DomStateCache, updateAllowCustomOptions)


type alias DomStateCache =
    { allowCustomOptions : CustomOptionsAttribute
    }


type CustomOptionsAttribute
    = CustomOptionsNotAllowed
    | CustomOptionsAllowed
    | CustomOptionsAllowedWithHint String


updateAllowCustomOptions : CustomOptionsAttribute -> DomStateCache -> DomStateCache
updateAllowCustomOptions customOptions domStateCache =
    { domStateCache | allowCustomOptions = customOptions }
