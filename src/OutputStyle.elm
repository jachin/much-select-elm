module OutputStyle exposing (..)

import Json.Decode
import Json.Encode
import PositiveInt exposing (PositiveInt)


type MaxDropdownItems
    = FixedMaxDropdownItems PositiveInt
    | NoLimitToDropdownItems


type SearchStringMinimumLength
    = FixedSearchStringMinimumLength PositiveInt
    | NoMinimumToSearchStringLength


encodeSearchStringMinimumLength : SearchStringMinimumLength -> Json.Encode.Value
encodeSearchStringMinimumLength searchStringMinimumLength =
    case searchStringMinimumLength of
        FixedSearchStringMinimumLength positiveInt ->
            PositiveInt.encode positiveInt

        NoMinimumToSearchStringLength ->
            Json.Encode.int 0


decodeSearchStringMinimumLength : Json.Decode.Decoder SearchStringMinimumLength
decodeSearchStringMinimumLength =
    PositiveInt.decode
        |> Json.Decode.andThen
            (\positiveInt ->
                if PositiveInt.isZero positiveInt then
                    Json.Decode.succeed NoMinimumToSearchStringLength

                else
                    Json.Decode.succeed (FixedSearchStringMinimumLength positiveInt)
            )


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


defaultSingleSelectCustomHtmlFields : SingleSelectCustomHtmlFields
defaultSingleSelectCustomHtmlFields =
    { customOptions = NoCustomOptions
    , selectedItemPlacementMode = SelectedItemStaysInPlace
    , maxDropdownItems = NoLimitToDropdownItems
    , searchStringMinimumLength = FixedSearchStringMinimumLength (PositiveInt.new 2)
    , dropdownState = Collapsed
    , dropdownStyle = NoFooter
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
