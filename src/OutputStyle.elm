module OutputStyle exposing (..)

import PositiveInt exposing (PositiveInt)


type MaxDropdownItems
    = FixedMaxDropdownItems PositiveInt
    | NoLimitToDropdownItems


type SearchStringMinimumLength
    = FixedSearchStringMinimumLength PositiveInt
    | NoMinimumToSearchStringLength


type alias CustomOptionHint =
    Maybe String


type DropdownState
    = Expanded
    | Collapsed
    | NotManagedByMe


type DropdownStyle
    = NoFooter
    | ShowFooter


type CustomOptions
    = AllowCustomOptions CustomOptionHint
    | NoCustomOptions


type SelectedItemPlacementMode
    = SelectedItemStaysInPlace
    | SelectedItemMovesToTheTop
    | SelectedItemIsHidden


type SingleItemRemoval
    = EnableSingleItemRemoval
    | DisableSingleItemRemoval


type alias SingleSelectCustomHtmlFields =
    { customOptions : CustomOptions
    , selectedItemPlacementMode : SelectedItemPlacementMode
    , maxDropdownItems : MaxDropdownItems
    , searchStringMinimumLength : SearchStringMinimumLength
    , dropdownState : DropdownState
    , dropdownStyle : DropdownStyle
    }


type alias MultiSelectCustomHtmlFields =
    { customOptions : CustomOptions
    , singleItemRemoval : SingleItemRemoval
    , maxDropdownItems : MaxDropdownItems
    , searchStringMinimumLength : SearchStringMinimumLength
    , dropdownState : DropdownState
    , dropdownStyle : DropdownStyle
    }


type SingleSelectOutputStyle
    = SingleSelectCustomHtml SingleSelectCustomHtmlFields
    | SingleSelectDatalist


type MultiSelectOutputStyle
    = MultiSelectCustomHtml MultiSelectCustomHtmlFields
    | MultiSelectDataList


singleToMulti : SingleSelectOutputStyle -> MultiSelectOutputStyle
singleToMulti singleSelectOutputStyle =
    case singleSelectOutputStyle of
        SingleSelectCustomHtml singleSelectCustomHtmlFields ->
            MultiSelectCustomHtml
                { customOptions = singleSelectCustomHtmlFields.customOptions
                , singleItemRemoval = DisableSingleItemRemoval
                , maxDropdownItems = singleSelectCustomHtmlFields.maxDropdownItems
                , searchStringMinimumLength = singleSelectCustomHtmlFields.searchStringMinimumLength
                , dropdownState = singleSelectCustomHtmlFields.dropdownState
                , dropdownStyle = singleSelectCustomHtmlFields.dropdownStyle
                }

        SingleSelectDatalist ->
            MultiSelectDataList


multiToSingle : MultiSelectOutputStyle -> SingleSelectOutputStyle
multiToSingle multiSelectOutputStyle =
    case multiSelectOutputStyle of
        MultiSelectCustomHtml multiSelectCustomHtmlFields ->
            SingleSelectCustomHtml
                { customOptions = multiSelectCustomHtmlFields.customOptions
                , selectedItemPlacementMode = SelectedItemStaysInPlace
                , maxDropdownItems = multiSelectCustomHtmlFields.maxDropdownItems
                , searchStringMinimumLength = multiSelectCustomHtmlFields.searchStringMinimumLength
                , dropdownState = multiSelectCustomHtmlFields.dropdownState
                , dropdownStyle = multiSelectCustomHtmlFields.dropdownStyle
                }

        MultiSelectDataList ->
            SingleSelectDatalist
