module Option exposing
    ( Option(..)
    , OptionDescription
    , OptionGroup
    , SearchResults
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
    , getOptionGroup
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
    , merge2Options
    , newCustomOption
    , newDatalistOption
    , newDisabledOption
    , newOption
    , newOptionGroup
    , newSelectedDatalistOption
    , newSelectedDatalistOptionPendingValidation
    , newSelectedDatalistOptionWithErrors
    , newSelectedOption
    , optionDescriptionToBool
    , optionDescriptionToSearchString
    , optionDescriptionToString
    , optionGroupToSearchString
    , optionGroupToString
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

import Json.Decode
import Json.Encode
import OptionDisplay exposing (OptionDisplay)
import OptionLabel exposing (OptionLabel(..), labelDecoder, optionLabelToString)
import OptionSearchFilter exposing (OptionSearchFilter, OptionSearchFilterWithValue, OptionSearchResult)
import OptionSlot exposing (OptionSlot)
import OptionValue exposing (OptionValue(..), optionValueToString, stringToOptionValue)
import SelectionMode exposing (OutputStyle(..), SelectionConfig)
import SortRank exposing (SortRank(..))
import TransformAndValidate exposing (ValidationErrorMessage, ValidationFailureMessage)


type Option
    = FancyOption OptionDisplay OptionLabel OptionValue OptionDescription OptionGroup (Maybe OptionSearchFilter)
    | CustomOption OptionDisplay OptionLabel OptionValue (Maybe OptionSearchFilter)
    | DatalistOption OptionDisplay OptionValue
    | SlottedOption OptionDisplay OptionValue OptionSlot
    | EmptyOption OptionDisplay OptionLabel


getOptionLabel : Option -> OptionLabel
getOptionLabel option =
    case option of
        FancyOption _ label _ _ _ _ ->
            label

        CustomOption _ label _ _ ->
            label

        EmptyOption _ label ->
            label

        DatalistOption _ optionValue ->
            optionValue |> optionValueToString |> OptionLabel.new

        SlottedOption _ _ _ ->
            OptionLabel.new ""


type OptionDescription
    = OptionDescription String (Maybe String)
    | NoDescription


optionDescriptionToString : OptionDescription -> String
optionDescriptionToString optionDescription =
    case optionDescription of
        OptionDescription string _ ->
            string

        NoDescription ->
            ""


optionDescriptionToSearchString : OptionDescription -> String
optionDescriptionToSearchString optionDescription =
    case optionDescription of
        OptionDescription description maybeCleanDescription ->
            case maybeCleanDescription of
                Just cleanDescription ->
                    cleanDescription

                Nothing ->
                    String.toLower description

        NoDescription ->
            ""


optionDescriptionToBool : OptionDescription -> Bool
optionDescriptionToBool optionDescription =
    case optionDescription of
        OptionDescription _ _ ->
            True

        NoDescription ->
            False


type OptionGroup
    = OptionGroup String
    | NoOptionGroup


newOptionGroup : String -> OptionGroup
newOptionGroup string =
    if string == "" then
        NoOptionGroup

    else
        OptionGroup string


getOptionGroup : Option -> OptionGroup
getOptionGroup option =
    case option of
        FancyOption _ _ _ _ optionGroup _ ->
            optionGroup

        CustomOption _ _ _ _ ->
            NoOptionGroup

        EmptyOption _ _ ->
            NoOptionGroup

        DatalistOption _ _ ->
            NoOptionGroup

        SlottedOption _ _ _ ->
            NoOptionGroup


newOption : String -> Maybe String -> Option
newOption value maybeCleanLabel =
    case value of
        "" ->
            EmptyOption OptionDisplay.default (OptionLabel.newWithCleanLabel "" maybeCleanLabel)

        _ ->
            FancyOption
                OptionDisplay.default
                (OptionLabel.newWithCleanLabel value maybeCleanLabel)
                (OptionValue value)
                NoDescription
                NoOptionGroup
                Nothing


newCustomOption : String -> Maybe String -> Option
newCustomOption value maybeCleanLabel =
    CustomOption
        OptionDisplay.default
        (OptionLabel.newWithCleanLabel value maybeCleanLabel)
        (OptionValue value)
        Nothing


newSelectedDatalistOption : OptionValue -> Int -> Option
newSelectedDatalistOption optionValue selectedIndex =
    DatalistOption
        (OptionDisplay.selected selectedIndex)
        optionValue


newSelectedDatalistOptionWithErrors : List ValidationFailureMessage -> OptionValue -> Int -> Option
newSelectedDatalistOptionWithErrors errors optionValue selectedIndex =
    DatalistOption
        (OptionDisplay.selectedAndInvalid selectedIndex errors)
        optionValue


newSelectedDatalistOptionPendingValidation : OptionValue -> Int -> Option
newSelectedDatalistOptionPendingValidation optionValue selectedIndex =
    DatalistOption
        (OptionDisplay.selectedAndPendingValidation selectedIndex)
        optionValue


newDatalistOption : OptionValue -> Option
newDatalistOption optionValue =
    DatalistOption
        OptionDisplay.default
        optionValue


setOptionValue : OptionValue -> Option -> Option
setOptionValue optionValue option =
    case option of
        FancyOption optionDisplay optionLabel _ optionDescription optionGroup maybeOptionSearchFilter ->
            FancyOption optionDisplay optionLabel optionValue optionDescription optionGroup maybeOptionSearchFilter

        CustomOption optionDisplay optionLabel _ maybeOptionSearchFilter ->
            CustomOption optionDisplay optionLabel optionValue maybeOptionSearchFilter

        DatalistOption optionDisplay _ ->
            DatalistOption optionDisplay optionValue

        EmptyOption optionDisplay optionLabel ->
            EmptyOption optionDisplay optionLabel

        SlottedOption optionDisplay _ optionSlot ->
            SlottedOption optionDisplay optionValue optionSlot


setLabelWithString : String -> Maybe String -> Option -> Option
setLabelWithString string maybeCleanString option =
    case option of
        FancyOption optionDisplay _ optionValue description group search ->
            FancyOption
                optionDisplay
                (OptionLabel.newWithCleanLabel string maybeCleanString)
                optionValue
                description
                group
                search

        CustomOption optionDisplay _ _ search ->
            CustomOption
                optionDisplay
                (OptionLabel.newWithCleanLabel string maybeCleanString)
                (OptionValue string)
                search

        EmptyOption optionDisplay _ ->
            EmptyOption optionDisplay (OptionLabel.newWithCleanLabel string maybeCleanString)

        DatalistOption optionDisplay _ ->
            DatalistOption optionDisplay (stringToOptionValue string)

        SlottedOption _ _ _ ->
            option


setLabel : OptionLabel -> Option -> Option
setLabel label option =
    case option of
        FancyOption optionDisplay _ optionValue description group search ->
            FancyOption
                optionDisplay
                label
                optionValue
                description
                group
                search

        CustomOption optionDisplay _ _ search ->
            CustomOption
                optionDisplay
                label
                (OptionValue (optionLabelToString label))
                search

        EmptyOption optionDisplay _ ->
            EmptyOption optionDisplay
                label

        DatalistOption optionDisplay _ ->
            DatalistOption optionDisplay (stringToOptionValue (OptionLabel.optionLabelToString label))

        SlottedOption _ _ _ ->
            option


setDescriptionWithString : String -> Option -> Option
setDescriptionWithString string option =
    case option of
        FancyOption optionDisplay label optionValue _ group search ->
            FancyOption optionDisplay
                label
                optionValue
                (OptionDescription string Nothing)
                group
                search

        CustomOption optionDisplay optionLabel optionValue search ->
            CustomOption
                optionDisplay
                optionLabel
                optionValue
                search

        EmptyOption optionDisplay optionLabel ->
            EmptyOption optionDisplay optionLabel

        DatalistOption _ _ ->
            option

        SlottedOption _ _ _ ->
            option


setDescription : OptionDescription -> Option -> Option
setDescription description option =
    case option of
        FancyOption optionDisplay label optionValue _ group search ->
            FancyOption optionDisplay
                label
                optionValue
                description
                group
                search

        CustomOption optionDisplay optionLabel optionValue search ->
            CustomOption
                optionDisplay
                optionLabel
                optionValue
                search

        EmptyOption optionDisplay optionLabel ->
            EmptyOption optionDisplay optionLabel

        DatalistOption _ _ ->
            option

        SlottedOption _ _ _ ->
            option


setGroup : OptionGroup -> Option -> Option
setGroup optionGroup option =
    case option of
        FancyOption optionDisplay label optionValue description _ search ->
            FancyOption optionDisplay
                label
                optionValue
                description
                optionGroup
                search

        CustomOption optionDisplay optionLabel optionValue search ->
            CustomOption optionDisplay
                optionLabel
                optionValue
                search

        EmptyOption optionDisplay optionLabel ->
            EmptyOption optionDisplay optionLabel

        DatalistOption _ _ ->
            option

        SlottedOption _ _ _ ->
            option


setGroupWithString : String -> Option -> Option
setGroupWithString string option =
    case option of
        FancyOption optionDisplay label optionValue description _ search ->
            FancyOption optionDisplay
                label
                optionValue
                description
                (OptionGroup string)
                search

        CustomOption optionDisplay optionLabel optionValue search ->
            CustomOption optionDisplay
                optionLabel
                optionValue
                search

        EmptyOption optionDisplay optionLabel ->
            EmptyOption optionDisplay optionLabel

        DatalistOption _ _ ->
            option

        SlottedOption _ _ _ ->
            option


setOptionDisplay : OptionDisplay -> Option -> Option
setOptionDisplay optionDisplay option =
    case option of
        FancyOption _ optionLabel optionValue optionDescription optionGroup search ->
            FancyOption
                optionDisplay
                optionLabel
                optionValue
                optionDescription
                optionGroup
                search

        CustomOption _ optionLabel optionValue search ->
            CustomOption optionDisplay
                optionLabel
                optionValue
                search

        EmptyOption _ optionLabel ->
            EmptyOption optionDisplay optionLabel

        DatalistOption _ optionValue ->
            DatalistOption optionDisplay optionValue

        SlottedOption _ optionValue optionSlot ->
            SlottedOption optionDisplay optionValue optionSlot


setOptionDisplayAge : OptionDisplay.OptionAge -> Option -> Option
setOptionDisplayAge optionAge option =
    setOptionDisplay (option |> getOptionDisplay |> OptionDisplay.setAge optionAge) option


setOptionSearchFilter : Maybe OptionSearchFilter -> Option -> Option
setOptionSearchFilter maybeOptionSearchFilter option =
    case option of
        FancyOption optionDisplay optionLabel optionValue optionDescription optionGroup _ ->
            FancyOption
                optionDisplay
                optionLabel
                optionValue
                optionDescription
                optionGroup
                maybeOptionSearchFilter

        CustomOption optionDisplay optionLabel optionValue _ ->
            CustomOption
                optionDisplay
                optionLabel
                optionValue
                maybeOptionSearchFilter

        EmptyOption optionDisplay optionLabel ->
            EmptyOption
                optionDisplay
                optionLabel

        DatalistOption _ _ ->
            option

        SlottedOption _ _ _ ->
            option


setMaybeSortRank : Maybe SortRank -> Option -> Option
setMaybeSortRank maybeSortRank option =
    setLabel (option |> getOptionLabel |> OptionLabel.setMaybeSortRank maybeSortRank) option


newSelectedOption : Int -> String -> Maybe String -> Option
newSelectedOption index string maybeCleanLabel =
    FancyOption (OptionDisplay.selected index)
        (OptionLabel.newWithCleanLabel string maybeCleanLabel)
        (OptionValue string)
        NoDescription
        NoOptionGroup
        Nothing


newDisabledOption : String -> Maybe String -> Option
newDisabledOption string maybeCleanLabel =
    FancyOption OptionDisplay.disabled
        (OptionLabel.newWithCleanLabel string maybeCleanLabel)
        (OptionValue string)
        NoDescription
        NoOptionGroup
        Nothing


isOptionSelected : Option -> Bool
isOptionSelected option =
    case option of
        FancyOption optionDisplay _ _ _ _ _ ->
            OptionDisplay.isSelected optionDisplay

        CustomOption optionDisplay _ _ _ ->
            OptionDisplay.isSelected optionDisplay

        EmptyOption optionDisplay _ ->
            OptionDisplay.isSelected optionDisplay

        DatalistOption optionDisplay _ ->
            OptionDisplay.isSelected optionDisplay

        SlottedOption optionDisplay _ _ ->
            OptionDisplay.isSelected optionDisplay


getOptionDisplay : Option -> OptionDisplay
getOptionDisplay option =
    case option of
        FancyOption display _ _ _ _ _ ->
            display

        CustomOption display _ _ _ ->
            display

        EmptyOption display _ ->
            display

        DatalistOption display _ ->
            display

        SlottedOption display _ _ ->
            display


getOptionSelectedIndex : Option -> Int
getOptionSelectedIndex option =
    case option of
        FancyOption optionDisplay _ _ _ _ _ ->
            OptionDisplay.getSelectedIndex optionDisplay

        CustomOption optionDisplay _ _ _ ->
            OptionDisplay.getSelectedIndex optionDisplay

        EmptyOption optionDisplay _ ->
            OptionDisplay.getSelectedIndex optionDisplay

        DatalistOption optionDisplay _ ->
            OptionDisplay.getSelectedIndex optionDisplay

        SlottedOption optionDisplay _ _ ->
            OptionDisplay.getSelectedIndex optionDisplay


setOptionSelectedIndex : Int -> Option -> Option
setOptionSelectedIndex selectedIndex option =
    case option of
        FancyOption optionDisplay _ _ _ _ _ ->
            setOptionDisplay (OptionDisplay.setSelectedIndex selectedIndex optionDisplay) option

        CustomOption optionDisplay _ _ _ ->
            setOptionDisplay (OptionDisplay.setSelectedIndex selectedIndex optionDisplay) option

        EmptyOption optionDisplay _ ->
            setOptionDisplay (OptionDisplay.setSelectedIndex selectedIndex optionDisplay) option

        DatalistOption optionDisplay _ ->
            setOptionDisplay (OptionDisplay.setSelectedIndex selectedIndex optionDisplay) option

        SlottedOption _ _ _ ->
            setOptionDisplay (OptionDisplay.setSelectedIndex selectedIndex OptionDisplay.default) option


hasSelectedItemIndex : Int -> Option -> Bool
hasSelectedItemIndex selectedItemIndex option =
    getOptionSelectedIndex option == selectedItemIndex


getOptionValue : Option -> OptionValue
getOptionValue option =
    case option of
        FancyOption _ _ value _ _ _ ->
            value

        CustomOption _ _ value _ ->
            value

        EmptyOption _ _ ->
            EmptyOptionValue

        DatalistOption _ optionValue ->
            optionValue

        SlottedOption _ optionValue _ ->
            optionValue


getOptionValueAsString : Option -> String
getOptionValueAsString option =
    case option |> getOptionValue of
        OptionValue string ->
            string

        EmptyOptionValue ->
            ""


optionGroupToString : OptionGroup -> String
optionGroupToString optionGroup =
    case optionGroup of
        OptionGroup string ->
            string

        NoOptionGroup ->
            ""


optionGroupToSearchString : OptionGroup -> String
optionGroupToSearchString optionGroup =
    case optionGroup of
        OptionGroup string ->
            String.toLower string

        NoOptionGroup ->
            ""


getOptionDescription : Option -> OptionDescription
getOptionDescription option =
    case option of
        FancyOption _ _ _ optionDescription _ _ ->
            optionDescription

        CustomOption _ _ _ _ ->
            NoDescription

        EmptyOption _ _ ->
            NoDescription

        DatalistOption _ _ ->
            NoDescription

        SlottedOption _ _ _ ->
            NoDescription


getMaybeOptionSearchFilter : Option -> Maybe OptionSearchFilter
getMaybeOptionSearchFilter option =
    case option of
        FancyOption _ _ _ _ _ maybeOptionSearchFilter ->
            maybeOptionSearchFilter

        CustomOption _ _ _ maybeOptionSearchFilter ->
            maybeOptionSearchFilter

        EmptyOption _ _ ->
            Nothing

        DatalistOption _ _ ->
            Nothing

        SlottedOption _ _ _ ->
            Nothing


merge2Options : Option -> Option -> Option
merge2Options optionA optionB =
    let
        optionLabel =
            orOptionLabel optionA optionB

        optionDescription =
            orOptionDescriptions optionA optionB

        optionGroup =
            orOptionGroup optionA optionB

        selectedIndex =
            orSelectedIndex optionA optionB
    in
    optionA
        |> setDescription optionDescription
        |> setLabel optionLabel
        |> setGroup optionGroup
        |> setOptionSelectedIndex selectedIndex


isOptionValueEqualToOptionLabel : Option -> Bool
isOptionValueEqualToOptionLabel option =
    let
        optionValueString =
            option
                |> getOptionValueAsString

        optionLabelString =
            option
                |> getOptionLabel
                |> optionLabelToString
    in
    optionValueString == optionLabelString


{-| A utility helper, the idea is that an option's label is going to match it's value by default.

If a label does not match the value then it's probably a label that's been set and it something we should
preserver (all else being equal).

TODO: Perhaps this could be addresses with types. Maybe there should be an option label variation that specifies it's a default label.

-}
orOptionLabel : Option -> Option -> OptionLabel
orOptionLabel optionA optionB =
    if isOptionValueEqualToOptionLabel optionA then
        if isOptionValueEqualToOptionLabel optionB then
            getOptionLabel optionA

        else
            getOptionLabel optionB

    else
        getOptionLabel optionA


orOptionDescriptions : Option -> Option -> OptionDescription
orOptionDescriptions optionA optionB =
    let
        optionDescriptionA =
            getOptionDescription optionA

        optionDescriptionB =
            getOptionDescription optionB
    in
    case optionDescriptionA of
        OptionDescription _ _ ->
            optionDescriptionA

        NoDescription ->
            case optionDescriptionB of
                OptionDescription _ _ ->
                    optionDescriptionB

                NoDescription ->
                    optionDescriptionB


orOptionGroup : Option -> Option -> OptionGroup
orOptionGroup optionA optionB =
    case getOptionGroup optionA of
        OptionGroup _ ->
            getOptionGroup optionA

        NoOptionGroup ->
            case getOptionGroup optionB of
                OptionGroup _ ->
                    getOptionGroup optionB

                NoOptionGroup ->
                    getOptionGroup optionA


orSelectedIndex : Option -> Option -> Int
orSelectedIndex optionA optionB =
    if getOptionSelectedIndex optionA == getOptionSelectedIndex optionB then
        getOptionSelectedIndex optionA

    else if getOptionSelectedIndex optionA > getOptionSelectedIndex optionB then
        getOptionSelectedIndex optionA

    else
        getOptionSelectedIndex optionB


isOptionValueInListOfStrings : List String -> Option -> Bool
isOptionValueInListOfStrings possibleValues option =
    List.any (\possibleValue -> getOptionValueAsString option == possibleValue) possibleValues


optionValuesEqual : Option -> OptionValue -> Bool
optionValuesEqual option optionValue =
    getOptionValue option == optionValue


highlightOption : Option -> Option
highlightOption option =
    case option of
        FancyOption display _ _ _ _ _ ->
            setOptionDisplay (OptionDisplay.addHighlight display) option

        CustomOption display _ _ _ ->
            setOptionDisplay (OptionDisplay.addHighlight display) option

        EmptyOption display _ ->
            setOptionDisplay (OptionDisplay.addHighlight display) option

        DatalistOption _ _ ->
            option

        SlottedOption optionDisplay _ _ ->
            setOptionDisplay (OptionDisplay.addHighlight optionDisplay) option


removeHighlightFromOption : Option -> Option
removeHighlightFromOption option =
    case option of
        FancyOption display _ _ _ _ _ ->
            setOptionDisplay (OptionDisplay.removeHighlight display) option

        CustomOption display _ _ _ ->
            setOptionDisplay (OptionDisplay.removeHighlight display) option

        EmptyOption display _ ->
            setOptionDisplay (OptionDisplay.removeHighlight display) option

        DatalistOption _ _ ->
            option

        SlottedOption optionDisplay _ _ ->
            setOptionDisplay (OptionDisplay.removeHighlight optionDisplay) option


isOptionHighlighted : Option -> Bool
isOptionHighlighted option =
    case option of
        FancyOption display _ _ _ _ _ ->
            OptionDisplay.isHighlighted display

        CustomOption display _ _ _ ->
            OptionDisplay.isHighlighted display

        EmptyOption display _ ->
            OptionDisplay.isHighlighted display

        DatalistOption _ _ ->
            False

        SlottedOption optionDisplay _ _ ->
            OptionDisplay.isHighlighted optionDisplay


optionIsHighlightable : SelectionConfig -> Option -> Bool
optionIsHighlightable selectionConfig option =
    case option of
        FancyOption display _ _ _ _ _ ->
            OptionDisplay.isHighlightable (SelectionMode.getSelectionMode selectionConfig) display

        CustomOption display _ _ _ ->
            OptionDisplay.isHighlightable (SelectionMode.getSelectionMode selectionConfig) display

        EmptyOption display _ ->
            OptionDisplay.isHighlightable (SelectionMode.getSelectionMode selectionConfig) display

        DatalistOption _ _ ->
            False

        SlottedOption optionDisplay _ _ ->
            OptionDisplay.isHighlightable (SelectionMode.getSelectionMode selectionConfig) optionDisplay


selectOption : Int -> Option -> Option
selectOption selectionIndex option =
    setOptionDisplay (OptionDisplay.select selectionIndex (getOptionDisplay option)) option


deselectOption : Option -> Option
deselectOption option =
    setOptionDisplay (OptionDisplay.deselect (getOptionDisplay option)) option


isOptionSelectedHighlighted : Option -> Bool
isOptionSelectedHighlighted option =
    case option of
        FancyOption optionDisplay _ _ _ _ _ ->
            OptionDisplay.isHighlightedSelected optionDisplay

        CustomOption optionDisplay _ _ _ ->
            OptionDisplay.isHighlightedSelected optionDisplay

        EmptyOption optionDisplay _ ->
            OptionDisplay.isHighlightedSelected optionDisplay

        DatalistOption _ _ ->
            False

        SlottedOption optionDisplay _ _ ->
            OptionDisplay.isHighlightedSelected optionDisplay


activateOption : Option -> Option
activateOption option =
    setOptionDisplay (getOptionDisplay option |> OptionDisplay.activate) option


isEmptyOption : Option -> Bool
isEmptyOption option =
    case option of
        FancyOption _ _ _ _ _ _ ->
            False

        CustomOption _ _ _ _ ->
            False

        EmptyOption _ _ ->
            True

        DatalistOption _ optionValue ->
            case optionValue of
                OptionValue _ ->
                    False

                EmptyOptionValue ->
                    True

        SlottedOption _ _ _ ->
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
        FancyOption _ _ _ _ _ _ ->
            False

        CustomOption _ _ _ _ ->
            True

        EmptyOption _ _ ->
            False

        DatalistOption _ _ ->
            False

        SlottedOption _ _ _ ->
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


descriptionDecoder : Json.Decode.Decoder OptionDescription
descriptionDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map2 OptionDescription
            (Json.Decode.field "description" Json.Decode.string)
            (Json.Decode.field "descriptionClean" (Json.Decode.nullable Json.Decode.string))
        , Json.Decode.succeed NoDescription
        ]


optionGroupDecoder : Json.Decode.Decoder OptionGroup
optionGroupDecoder =
    Json.Decode.oneOf
        [ Json.Decode.field "group" Json.Decode.string
            |> Json.Decode.map OptionGroup
        , Json.Decode.succeed NoOptionGroup
        ]


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
