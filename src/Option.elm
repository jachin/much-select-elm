module Option exposing
    ( Option(..)
    , SearchResults
    , SlottedOption(..)
    , activateOption
    , decodeSearchResults
    , decoder
    , deselectOption
    , encode
    , encodeSearchResults
    , equal
    , getMaybeOptionSearchFilter
    , getOptionDescription
    , getOptionDisplay
    , getOptionLabel
    , getOptionSelectedIndex
    , getOptionValidationErrors
    , getOptionValue
    , getOptionValueAsString
    , getSlot
    , hasSelectedItemIndex
    , highlightOption
    , isCustomOption
    , isEmptyOption
    , isEmptyOptionOrHasEmptyValue
    , isInvalid
    , isOptionHighlighted
    , isOptionSelected
    , isOptionSelectedHighlighted
    , isOptionValueInListOfStrings
    , isPendingValidation
    , isValid
    , newDisabledOption
    , newSelectedOption
    , optionIsHighlightable
    , optionToValueLabelTuple
    , optionValuesEqual
    , optionsDecoder
    , removeHighlightFromOption
    , selectOption
    , setDescriptionWithString
    , setGroupWithString
    , setLabel
    , setLabelWithString
    , setMaybeSortRank
    , setOptionDisplay
    , setOptionDisplayAge
    , setOptionSearchFilter
    , setOptionValue
    , setOptionValueErrors
    , test_optionToDebuggingString
    , transformOptionForOutputStyle
    )

import DatalistOption
import FancyOption
import Json.Decode
import Json.Encode
import OptionDescription exposing (OptionDescription)
import OptionDisplay exposing (OptionDisplay)
import OptionGroup exposing (OptionGroup)
import OptionLabel exposing (OptionLabel(..), labelDecoder, optionLabelToString)
import OptionSearchFilter exposing (OptionSearchFilter, OptionSearchFilterWithValue, OptionSearchResult)
import OptionSlot exposing (OptionSlot)
import OptionValue exposing (OptionValue(..), optionValueToString)
import SelectionMode exposing (OutputStyle(..), SelectionConfig)
import SlottedOption
import SortRank exposing (SortRank(..))
import TransformAndValidate exposing (ValidationErrorMessage, ValidationFailureMessage)


type Option
    = FancyOption FancyOption.FancyOption
    | DatalistOption DatalistOption.DatalistOption
    | SlottedOption SlottedOption.SlottedOption


type SlottedOption
    = SlottedOption OptionDisplay OptionValue OptionSlot


setOptionValue : OptionValue -> Option -> Option
setOptionValue optionValue option =
    case option of
        FancyOption fancyOption ->
            FancyOption (FancyOption.setOptionValue optionValue fancyOption)

        DatalistOption datalistOption ->
            DatalistOption (DatalistOption.setOptionValue optionValue datalistOption)

        SlottedOption slottedOption ->
            SlottedOption (SlottedOption.setOptionValue optionValue slottedOption)


getOptionLabel : Option -> OptionLabel
getOptionLabel option =
    case option of
        FancyOption fancyOption ->
            FancyOption.getOptionLabel fancyOption

        DatalistOption datalistOption ->
            DatalistOption.getOptionLabel datalistOption

        SlottedOption _ ->
            OptionLabel.new ""


setLabel : OptionLabel -> Option -> Option
setLabel label option =
    case option of
        FancyOption fancyOption ->
            FancyOption (FancyOption.setLabel label fancyOption)

        DatalistOption _ ->
            option

        SlottedOption _ ->
            option


setLabelWithString : String -> Maybe String -> Option -> Option
setLabelWithString string maybeCleanString option =
    let
        newOptionLabel =
            OptionLabel.newWithCleanLabel string maybeCleanString
    in
    setLabel newOptionLabel option


setDescription : OptionDescription -> Option -> Option
setDescription description option =
    case option of
        FancyOption fancyOption ->
            FancyOption (FancyOption.setDescription description fancyOption)

        DatalistOption _ ->
            option

        SlottedOption _ ->
            option


setDescriptionWithString : String -> Option -> Option
setDescriptionWithString string option =
    let
        newOptionDescription =
            OptionDescription.new string
    in
    setDescription newOptionDescription option


setGroup : OptionGroup -> Option -> Option
setGroup optionGroup option =
    case option of
        FancyOption fancyOption ->
            FancyOption (FancyOption.setOptionGroup optionGroup fancyOption)

        DatalistOption _ ->
            option

        SlottedOption _ ->
            option


setGroupWithString : String -> Option -> Option
setGroupWithString string option =
    let
        newOptionGroup =
            OptionGroup.new string
    in
    setGroup newOptionGroup option


setOptionDisplay : OptionDisplay -> Option -> Option
setOptionDisplay optionDisplay option =
    case option of
        FancyOption fancyOption ->
            FancyOption (FancyOption.setOptionDisplay optionDisplay fancyOption)

        DatalistOption datalistOption ->
            DatalistOption (DatalistOption.setOptionDisplay optionDisplay datalistOption)

        SlottedOption slottedOption ->
            SlottedOption (SlottedOption.setOptionDisplay optionDisplay slottedOption)


setOptionDisplayAge : OptionDisplay.OptionAge -> Option -> Option
setOptionDisplayAge optionAge option =
    setOptionDisplay (option |> getOptionDisplay |> OptionDisplay.setAge optionAge) option


setOptionSearchFilter : Maybe OptionSearchFilter -> Option -> Option
setOptionSearchFilter maybeOptionSearchFilter option =
    case option of
        FancyOption fancyOption ->
            FancyOption (FancyOption.setOptionSearchFilter maybeOptionSearchFilter fancyOption)

        DatalistOption _ ->
            option

        SlottedOption _ ->
            option


setMaybeSortRank : Maybe SortRank -> Option -> Option
setMaybeSortRank maybeSortRank option =
    setLabel (option |> getOptionLabel |> OptionLabel.setMaybeSortRank maybeSortRank) option


newSelectedOption : Int -> String -> Maybe String -> Option
newSelectedOption index labelString maybeCleanLabel =
    FancyOption (FancyOption.newSelectedOption index labelString maybeCleanLabel)


newDisabledOption : String -> Maybe String -> Option
newDisabledOption string maybeCleanLabel =
    FancyOption (FancyOption.newDisabledOption string maybeCleanLabel)


isOptionSelected : Option -> Bool
isOptionSelected option =
    case option of
        FancyOption fancyOption ->
            FancyOption.isSelected fancyOption

        DatalistOption datalistOption ->
            DatalistOption.isSelected datalistOption

        SlottedOption slottedOption ->
            SlottedOption.isSelected slottedOption


getOptionDisplay : Option -> OptionDisplay
getOptionDisplay option =
    case option of
        FancyOption fancyOption ->
            FancyOption.getOptionDisplay fancyOption

        DatalistOption datalistOption ->
            DatalistOption.getOptionDisplay datalistOption

        SlottedOption slottedOption ->
            SlottedOption.getOptionDisplay slottedOption


getOptionSelectedIndex : Option -> Int
getOptionSelectedIndex option =
    case option of
        FancyOption fancyOption ->
            FancyOption.getOptionSelectedIndex fancyOption

        DatalistOption datalistOption ->
            DatalistOption.getOptionSelectedIndex datalistOption

        SlottedOption slottedOption ->
            SlottedOption.getOptionSelectedIndex slottedOption


setOptionSelectedIndex : Int -> Option -> Option
setOptionSelectedIndex selectedIndex option =
    case option of
        FancyOption fancyOption ->
            FancyOption (FancyOption.setOptionSelectedIndex selectedIndex fancyOption)

        DatalistOption datalistOption ->
            DatalistOption (DatalistOption.setOptionSelectedIndex selectedIndex datalistOption)

        SlottedOption slottedOption ->
            SlottedOption (SlottedOption.setOptionSelectedIndex selectedIndex slottedOption)


hasSelectedItemIndex : Int -> Option -> Bool
hasSelectedItemIndex selectedItemIndex option =
    getOptionSelectedIndex option == selectedItemIndex


getOptionValue : Option -> OptionValue
getOptionValue option =
    case option of
        FancyOption fancyOption ->
            FancyOption.getOptionValue fancyOption

        DatalistOption datalistOption ->
            DatalistOption.getOptionValue datalistOption

        SlottedOption slottedOption ->
            SlottedOption.getOptionValue slottedOption


getOptionValueAsString : Option -> String
getOptionValueAsString option =
    case option |> getOptionValue of
        OptionValue string ->
            string

        EmptyOptionValue ->
            ""


getOptionDescription : Option -> OptionDescription
getOptionDescription option =
    case option of
        FancyOption fancyOption ->
            FancyOption.getOptionDescription fancyOption

        DatalistOption _ ->
            OptionDescription.noDescription

        SlottedOption _ ->
            OptionDescription.noDescription


getMaybeOptionSearchFilter : Option -> Maybe OptionSearchFilter
getMaybeOptionSearchFilter option =
    case option of
        FancyOption fancyOption ->
            FancyOption.getMaybeOptionSearchFilter fancyOption

        DatalistOption _ ->
            Nothing

        SlottedOption _ ->
            Nothing


isOptionValueInListOfStrings : List String -> Option -> Bool
isOptionValueInListOfStrings possibleValues option =
    List.any (\possibleValue -> getOptionValueAsString option == possibleValue) possibleValues


optionValuesEqual : Option -> OptionValue -> Bool
optionValuesEqual option optionValue =
    getOptionValue option == optionValue


highlightOption : Option -> Option
highlightOption option =
    case option of
        FancyOption fancyOption ->
            FancyOption (FancyOption.highlightOption fancyOption)

        DatalistOption _ ->
            option

        SlottedOption slottedOption ->
            SlottedOption (SlottedOption.highlightOption slottedOption)


removeHighlightFromOption : Option -> Option
removeHighlightFromOption option =
    case option of
        FancyOption fancyOption ->
            FancyOption (FancyOption.removeHighlightFromOption fancyOption)

        DatalistOption _ ->
            option

        SlottedOption slottedOption ->
            SlottedOption (SlottedOption.removeHighlightFromOption slottedOption)


isOptionHighlighted : Option -> Bool
isOptionHighlighted option =
    case option of
        FancyOption fancyOption ->
            FancyOption.isOptionHighlighted fancyOption

        DatalistOption _ ->
            False

        SlottedOption slottedOption ->
            SlottedOption.isOptionHighlighted slottedOption


optionIsHighlightable : SelectionConfig -> Option -> Bool
optionIsHighlightable selectionConfig option =
    case option of
        FancyOption fancyOption ->
            FancyOption.optionIsHighlightable selectionConfig fancyOption

        DatalistOption _ ->
            False

        SlottedOption slottedOption ->
            SlottedOption.optionIsHighlightable selectionConfig slottedOption


selectOption : Int -> Option -> Option
selectOption selectionIndex option =
    setOptionDisplay (OptionDisplay.select selectionIndex (getOptionDisplay option)) option


deselectOption : Option -> Option
deselectOption option =
    setOptionDisplay (OptionDisplay.deselect (getOptionDisplay option)) option


isOptionSelectedHighlighted : Option -> Bool
isOptionSelectedHighlighted option =
    case option of
        FancyOption fancyOption ->
            FancyOption.isOptionSelectedHighlighted fancyOption

        DatalistOption _ ->
            False

        SlottedOption slottedOption ->
            SlottedOption.isOptionSelectedHighlighted slottedOption


activateOption : Option -> Option
activateOption option =
    setOptionDisplay (getOptionDisplay option |> OptionDisplay.activate) option


isEmptyOption : Option -> Bool
isEmptyOption option =
    case option of
        FancyOption fancyOption ->
            FancyOption.isEmptyOption fancyOption

        DatalistOption _ ->
            False

        SlottedOption _ ->
            False


isEmptyOptionOrHasEmptyValue : Option -> Bool
isEmptyOptionOrHasEmptyValue option =
    isEmptyOption option || (getOptionValue option |> OptionValue.isEmpty)


optionToValueLabelTuple : Option -> ( String, String )
optionToValueLabelTuple option =
    ( getOptionValueAsString option, getOptionLabel option |> optionLabelToString )


isCustomOption : Option -> Bool
isCustomOption option =
    case option of
        FancyOption fancyOption ->
            FancyOption.isCustomOption fancyOption

        DatalistOption _ ->
            False

        SlottedOption _ ->
            False


optionsDecoder : OptionDisplay.OptionAge -> OutputStyle -> Json.Decode.Decoder (List Option)
optionsDecoder age outputStyle =
    Json.Decode.list (decoder age outputStyle)


decoder : OptionDisplay.OptionAge -> OutputStyle -> Json.Decode.Decoder Option
decoder age outputStyle =
    case outputStyle of
        CustomHtml ->
            Json.Decode.oneOf
                [ decodeOptionWithoutAValue age
                , decodeOptionWithAValue age
                , decodeSlottedOption age
                ]

        Datalist ->
            decodeOptionForDatalist


decodeOptionWithoutAValue : OptionDisplay.OptionAge -> Json.Decode.Decoder Option
decodeOptionWithoutAValue age =
    Json.Decode.field
        "value"
        valueDecoder
        |> Json.Decode.andThen
            (\value ->
                case value of
                    OptionValue _ ->
                        Json.Decode.fail "It can not be an option without a value because it has a value."

                    EmptyOptionValue ->
                        Json.Decode.map2
                            EmptyOption
                            (OptionDisplay.decoder age)
                            labelDecoder
            )


decodeOptionWithAValue : OptionDisplay.OptionAge -> Json.Decode.Decoder Option
decodeOptionWithAValue age =
    Json.Decode.map6 FancyOption
        (OptionDisplay.decoder age)
        labelDecoder
        (Json.Decode.field
            "value"
            valueDecoder
        )
        descriptionDecoder
        optionGroupDecoder
        (Json.Decode.succeed Nothing)


decodeSlottedOption : OptionDisplay.OptionAge -> Json.Decode.Decoder Option
decodeSlottedOption age =
    Json.Decode.map3
        SlottedOption
        (OptionDisplay.decoder age)
        (Json.Decode.field
            "value"
            valueDecoder
        )
        (Json.Decode.field "slot" OptionSlot.decoder)


decodeOptionForDatalist : Json.Decode.Decoder Option
decodeOptionForDatalist =
    Json.Decode.map2 DatalistOption
        (OptionDisplay.decoder OptionDisplay.MatureOption)
        (Json.Decode.field
            "value"
            valueDecoder
        )


valueDecoder : Json.Decode.Decoder OptionValue
valueDecoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\valueStr ->
                case String.trim valueStr of
                    "" ->
                        Json.Decode.succeed EmptyOptionValue

                    str ->
                        Json.Decode.succeed (OptionValue str)
            )


encode : Option -> Json.Decode.Value
encode option =
    Json.Encode.object
        [ ( "value", Json.Encode.string (getOptionValueAsString option) )
        , ( "label", Json.Encode.string (getOptionLabel option |> optionLabelToString) )
        , ( "labelClean", Json.Encode.string (getOptionLabel option |> OptionLabel.optionLabelToSearchString) )
        , ( "group", Json.Encode.string (getOptionGroup option |> optionGroupToString) )
        , ( "description", Json.Encode.string (getOptionDescription option |> optionDescriptionToString) )
        , ( "descriptionClean", Json.Encode.string (getOptionDescription option |> optionDescriptionToSearchString) )
        , ( "isSelected", Json.Encode.bool (isOptionSelected option) )
        ]


type alias SearchResults =
    { optionSearchFilters : List OptionSearchFilterWithValue
    , searchNonce : Int
    , isClearingSearch : Bool
    }


encodeSearchResults : List Option -> Int -> Bool -> Json.Encode.Value
encodeSearchResults options nonce isClearingList =
    Json.Encode.object
        [ ( "searchNonce", Json.Encode.int nonce )
        , ( "clearingSearch", Json.Encode.bool isClearingList )
        , ( "options", Json.Encode.list encodeSearchResult options )
        ]


encodeSearchResult : Option -> Json.Encode.Value
encodeSearchResult option =
    Json.Encode.object
        [ ( "value", Json.Encode.string (getOptionValueAsString option) )
        , ( "searchFilter"
          , case getMaybeOptionSearchFilter option of
                Just optionSearchFilter ->
                    OptionSearchFilter.encode optionSearchFilter

                Nothing ->
                    Json.Encode.null
          )
        ]


decodeSearchResults : Json.Decode.Decoder SearchResults
decodeSearchResults =
    Json.Decode.map3
        SearchResults
        (Json.Decode.field "options"
            (Json.Decode.list
                (Json.Decode.map2
                    (\value searchFilter ->
                        { value = value, maybeSearchFilter = searchFilter }
                    )
                    (Json.Decode.field "value" valueDecoder)
                    (Json.Decode.field "searchFilter"
                        (Json.Decode.nullable OptionSearchFilter.decode)
                    )
                )
            )
        )
        (Json.Decode.field "searchNonce" Json.Decode.int)
        (Json.Decode.field "clearingSearch" Json.Decode.bool)


transformOptionForOutputStyle : OutputStyle -> Option -> Maybe Option
transformOptionForOutputStyle outputStyle option =
    case outputStyle of
        SelectionMode.CustomHtml ->
            case option of
                FancyOption _ _ _ _ _ _ ->
                    Just option

                CustomOption _ _ _ _ ->
                    Just option

                DatalistOption optionDisplay optionValue ->
                    Just
                        (FancyOption optionDisplay
                            (OptionLabel.new
                                (OptionValue.optionValueToString optionValue)
                            )
                            optionValue
                            NoDescription
                            NoOptionGroup
                            Nothing
                        )

                EmptyOption _ _ ->
                    Just option

                SlottedOption _ _ _ ->
                    Just option

        SelectionMode.Datalist ->
            case option of
                FancyOption optionDisplay _ optionValue _ _ _ ->
                    Just (DatalistOption optionDisplay optionValue)

                CustomOption optionDisplay _ optionValue _ ->
                    Just (DatalistOption optionDisplay optionValue)

                DatalistOption _ _ ->
                    Just option

                EmptyOption _ _ ->
                    Nothing

                SlottedOption _ _ _ ->
                    Nothing


equal : Option -> Option -> Bool
equal optionA optionB =
    optionA == optionB


setOptionValueErrors : List ValidationFailureMessage -> Option -> Option
setOptionValueErrors validationFailures option =
    let
        newOptionDisplay =
            option
                |> getOptionDisplay
                |> OptionDisplay.setErrors validationFailures
    in
    setOptionDisplay newOptionDisplay option


getOptionValidationErrors : Option -> List ValidationFailureMessage
getOptionValidationErrors option =
    OptionDisplay.getErrors (getOptionDisplay option)


isInvalid : Option -> Bool
isInvalid option =
    OptionDisplay.isInvalid (getOptionDisplay option)


isPendingValidation : Option -> Bool
isPendingValidation option =
    OptionDisplay.isPendingValidation (getOptionDisplay option)


isValid : Option -> Bool
isValid option =
    not (isInvalid option || isPendingValidation option)


getSlot : Option -> OptionSlot
getSlot option =
    case option of
        FancyOption _ _ _ _ _ _ ->
            OptionSlot.empty

        CustomOption _ _ _ _ ->
            OptionSlot.empty

        EmptyOption _ _ ->
            OptionSlot.empty

        DatalistOption _ _ ->
            OptionSlot.empty

        SlottedOption _ _ slot ->
            slot


test_optionToDebuggingString : Option -> String
test_optionToDebuggingString option =
    case option of
        FancyOption _ optionLabel _ _ optionGroup _ ->
            case optionGroupToString optionGroup of
                "" ->
                    optionLabelToString optionLabel

                optionGroupString ->
                    optionGroupString ++ " - " ++ optionLabelToString optionLabel

        CustomOption _ optionLabel _ _ ->
            optionLabelToString optionLabel

        EmptyOption _ optionLabel ->
            optionLabelToString optionLabel

        DatalistOption _ optionValue ->
            optionValueToString optionValue

        SlottedOption _ optionValue _ ->
            optionValueToString optionValue
