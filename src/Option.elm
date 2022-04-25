module Option exposing
    ( Option(..)
    , OptionDescription
    , OptionDisplay(..)
    , OptionGroup
    , OptionValue(..)
    , decoder
    , deselectOption
    , encode
    , getMaybeOptionSearchFilter
    , getOptionDescription
    , getOptionDisplay
    , getOptionGroup
    , getOptionLabel
    , getOptionSelectedIndex
    , getOptionValue
    , getOptionValueAsString
    , highlightOption
    , isCustomOption
    , isEmptyOption
    , isOptionDisplaySelectedHighlighted
    , isOptionHighlighted
    , isOptionSelected
    , isOptionSelectedHighlighted
    , isOptionValueInListOfStrings
    , merge2Options
    , newCustomOption
    , newDisabledOption
    , newOption
    , newOptionGroup
    , newSelectedOption
    , optionDescriptionToBool
    , optionDescriptionToSearchString
    , optionDescriptionToString
    , optionGroupToSearchString
    , optionGroupToString
    , optionIsHighlightable
    , optionToValueLabelTuple
    , optionValueToString
    , optionValuesEqual
    , optionsDecoder
    , removeHighlightOption
    , selectOption
    , setDescriptionWithString
    , setGroupWithString
    , setLabel
    , setLabelWithString
    , setMaybeSortRank
    , setOptionDisplay
    , setOptionSearchFilter
    , stringToOptionValue
    )

import Json.Decode
import Json.Encode
import OptionLabel exposing (OptionLabel(..), labelDecoder, optionLabelToString)
import OptionSearchFilter exposing (OptionSearchFilter, OptionSearchResult)
import SortRank exposing (SortRank(..))


type Option
    = Option OptionDisplay OptionLabel OptionValue OptionDescription OptionGroup (Maybe OptionSearchFilter)
    | CustomOption OptionDisplay OptionLabel OptionValue (Maybe OptionSearchFilter)
    | EmptyOption OptionDisplay OptionLabel


getOptionLabel : Option -> OptionLabel
getOptionLabel option =
    case option of
        Option _ label _ _ _ _ ->
            label

        CustomOption _ label _ _ ->
            label

        EmptyOption _ label ->
            label


type OptionDisplay
    = OptionShown
    | OptionHidden
    | OptionSelected Int
    | OptionSelectedHighlighted Int
    | OptionHighlighted
    | OptionDisabled


type OptionValue
    = OptionValue String
    | EmptyOptionValue


optionValueToString : OptionValue -> String
optionValueToString optionValue =
    case optionValue of
        OptionValue valueString ->
            valueString

        EmptyOptionValue ->
            ""


stringToOptionValue : String -> OptionValue
stringToOptionValue string =
    OptionValue string


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
        Option _ _ _ _ optionGroup _ ->
            optionGroup

        CustomOption _ _ _ _ ->
            NoOptionGroup

        EmptyOption _ _ ->
            NoOptionGroup


newOption : String -> Maybe String -> Option
newOption value maybeCleanLabel =
    case value of
        "" ->
            EmptyOption OptionShown (OptionLabel.newWithCleanLabel "" maybeCleanLabel)

        _ ->
            Option
                OptionShown
                (OptionLabel.newWithCleanLabel value maybeCleanLabel)
                (OptionValue value)
                NoDescription
                NoOptionGroup
                Nothing


newCustomOption : String -> Maybe String -> Option
newCustomOption value maybeCleanLabel =
    CustomOption
        OptionShown
        (OptionLabel.newWithCleanLabel value maybeCleanLabel)
        (OptionValue value)
        Nothing


setLabelWithString : String -> Maybe String -> Option -> Option
setLabelWithString string maybeCleanString option =
    case option of
        Option optionDisplay _ optionValue description group search ->
            Option
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


setLabel : OptionLabel -> Option -> Option
setLabel label option =
    case option of
        Option optionDisplay _ optionValue description group search ->
            Option
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


setDescriptionWithString : String -> Option -> Option
setDescriptionWithString string option =
    case option of
        Option optionDisplay label optionValue _ group search ->
            Option optionDisplay
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


setDescription : OptionDescription -> Option -> Option
setDescription description option =
    case option of
        Option optionDisplay label optionValue _ group search ->
            Option optionDisplay
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


setGroup : OptionGroup -> Option -> Option
setGroup optionGroup option =
    case option of
        Option optionDisplay label optionValue description _ search ->
            Option optionDisplay
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


setGroupWithString : String -> Option -> Option
setGroupWithString string option =
    case option of
        Option optionDisplay label optionValue description _ search ->
            Option optionDisplay
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


setOptionDisplay : OptionDisplay -> Option -> Option
setOptionDisplay optionDisplay option =
    case option of
        Option _ optionLabel optionValue optionDescription optionGroup search ->
            Option
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


setOptionSearchFilter : Maybe OptionSearchFilter -> Option -> Option
setOptionSearchFilter maybeOptionSearchFilter option =
    case option of
        Option optionDisplay optionLabel optionValue optionDescription optionGroup _ ->
            Option
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


setMaybeSortRank : Maybe SortRank -> Option -> Option
setMaybeSortRank maybeSortRank option =
    setLabel (option |> getOptionLabel |> OptionLabel.setMaybeSortRank maybeSortRank) option


newSelectedOption : Int -> String -> Maybe String -> Option
newSelectedOption index string maybeCleanLabel =
    Option (OptionSelected index)
        (OptionLabel.newWithCleanLabel string maybeCleanLabel)
        (OptionValue string)
        NoDescription
        NoOptionGroup
        Nothing


newDisabledOption : String -> Maybe String -> Option
newDisabledOption string maybeCleanLabel =
    Option OptionDisabled
        (OptionLabel.newWithCleanLabel string maybeCleanLabel)
        (OptionValue string)
        NoDescription
        NoOptionGroup
        Nothing


isOptionSelected : Option -> Bool
isOptionSelected option =
    let
        isOptionDisplaySelected optionDisplay =
            case optionDisplay of
                OptionShown ->
                    False

                OptionHidden ->
                    False

                OptionSelected _ ->
                    True

                OptionSelectedHighlighted _ ->
                    True

                OptionHighlighted ->
                    False

                OptionDisabled ->
                    False
    in
    case option of
        Option optionDisplay _ _ _ _ _ ->
            isOptionDisplaySelected optionDisplay

        CustomOption optionDisplay _ _ _ ->
            isOptionDisplaySelected optionDisplay

        EmptyOption optionDisplay _ ->
            isOptionDisplaySelected optionDisplay


getOptionDisplay : Option -> OptionDisplay
getOptionDisplay option =
    case option of
        Option display _ _ _ _ _ ->
            display

        CustomOption display _ _ _ ->
            display

        EmptyOption display _ ->
            display


getOptionSelectedIndex : Option -> Int
getOptionSelectedIndex option =
    case option of
        Option optionDisplay _ _ _ _ _ ->
            optionDisplayToSelectedIndex optionDisplay

        CustomOption optionDisplay _ _ _ ->
            optionDisplayToSelectedIndex optionDisplay

        EmptyOption optionDisplay _ ->
            optionDisplayToSelectedIndex optionDisplay


setOptionSelectedIndex : Int -> Option -> Option
setOptionSelectedIndex selectedIndex option =
    case option of
        Option optionDisplay _ _ _ _ _ ->
            setOptionDisplay (setOptionDisplaySelectedIndex selectedIndex optionDisplay) option

        CustomOption optionDisplay _ _ _ ->
            setOptionDisplay (setOptionDisplaySelectedIndex selectedIndex optionDisplay) option

        EmptyOption optionDisplay _ ->
            setOptionDisplay (setOptionDisplaySelectedIndex selectedIndex optionDisplay) option


setOptionDisplaySelectedIndex : Int -> OptionDisplay -> OptionDisplay
setOptionDisplaySelectedIndex selectedIndex optionDisplay =
    case optionDisplay of
        OptionShown ->
            optionDisplay

        OptionHidden ->
            optionDisplay

        OptionSelected _ ->
            OptionSelected selectedIndex

        OptionSelectedHighlighted _ ->
            OptionSelectedHighlighted selectedIndex

        OptionHighlighted ->
            optionDisplay

        OptionDisabled ->
            optionDisplay


optionDisplayToSelectedIndex : OptionDisplay -> Int
optionDisplayToSelectedIndex optionDisplay =
    case optionDisplay of
        OptionShown ->
            -1

        OptionHidden ->
            -1

        OptionSelected int ->
            int

        OptionSelectedHighlighted int ->
            int

        OptionHighlighted ->
            -1

        OptionDisabled ->
            -1


getOptionValue : Option -> OptionValue
getOptionValue option =
    case option of
        Option _ _ value _ _ _ ->
            value

        CustomOption _ _ value _ ->
            value

        EmptyOption _ _ ->
            EmptyOptionValue


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
        Option _ _ _ optionDescription _ _ ->
            optionDescription

        CustomOption _ _ _ _ ->
            NoDescription

        EmptyOption _ _ ->
            NoDescription


getMaybeOptionSearchFilter : Option -> Maybe OptionSearchFilter
getMaybeOptionSearchFilter option =
    case option of
        Option _ _ _ _ _ maybeOptionSearchFilter ->
            maybeOptionSearchFilter

        CustomOption _ _ _ maybeOptionSearchFilter ->
            maybeOptionSearchFilter

        EmptyOption _ _ ->
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
        Option display label value description group search ->
            case display of
                OptionShown ->
                    Option OptionHighlighted label value description group search

                OptionHidden ->
                    Option OptionHidden label value description group search

                OptionSelected selectedIndex ->
                    Option (OptionSelectedHighlighted selectedIndex) label value description group search

                OptionSelectedHighlighted selectedIndex ->
                    Option (OptionSelectedHighlighted selectedIndex) label value description group search

                OptionHighlighted ->
                    Option OptionHighlighted label value description group search

                OptionDisabled ->
                    Option OptionDisabled label value description group search

        CustomOption display label value search ->
            case display of
                OptionShown ->
                    CustomOption OptionHighlighted label value search

                OptionHidden ->
                    CustomOption OptionHidden label value search

                OptionSelected selectedIndex ->
                    CustomOption (OptionSelectedHighlighted selectedIndex) label value search

                OptionSelectedHighlighted selectedIndex ->
                    CustomOption (OptionSelectedHighlighted selectedIndex) label value search

                OptionHighlighted ->
                    CustomOption OptionHighlighted label value search

                OptionDisabled ->
                    CustomOption OptionDisabled label value search

        EmptyOption display label ->
            case display of
                OptionShown ->
                    EmptyOption OptionHighlighted label

                OptionHidden ->
                    EmptyOption OptionHidden label

                OptionSelected selectedIndex ->
                    EmptyOption (OptionSelectedHighlighted selectedIndex) label

                OptionSelectedHighlighted selectedIndex ->
                    EmptyOption (OptionSelectedHighlighted selectedIndex) label

                OptionHighlighted ->
                    EmptyOption OptionHighlighted label

                OptionDisabled ->
                    EmptyOption OptionDisabled label


removeHighlightOption : Option -> Option
removeHighlightOption option =
    case option of
        Option display label value description group search ->
            case display of
                OptionShown ->
                    Option OptionShown
                        label
                        value
                        description
                        group
                        search

                OptionHidden ->
                    Option OptionHidden
                        label
                        value
                        description
                        group
                        search

                OptionSelected selectedIndex ->
                    Option (OptionSelected selectedIndex)
                        label
                        value
                        description
                        group
                        search

                OptionSelectedHighlighted selectedIndex ->
                    Option (OptionSelectedHighlighted selectedIndex)
                        label
                        value
                        description
                        group
                        search

                OptionHighlighted ->
                    Option OptionShown label value description group search

                OptionDisabled ->
                    Option OptionDisabled label value description group search

        CustomOption display label value search ->
            case display of
                OptionShown ->
                    CustomOption OptionShown label value search

                OptionHidden ->
                    CustomOption OptionHidden label value search

                OptionSelected selectedIndex ->
                    CustomOption (OptionSelected selectedIndex) label value search

                OptionSelectedHighlighted selectedIndex ->
                    CustomOption
                        (OptionSelectedHighlighted selectedIndex)
                        label
                        value
                        search

                OptionHighlighted ->
                    CustomOption OptionShown label value search

                OptionDisabled ->
                    CustomOption OptionDisabled label value search

        EmptyOption display label ->
            case display of
                OptionShown ->
                    EmptyOption OptionShown label

                OptionHidden ->
                    EmptyOption OptionHidden label

                OptionSelected selectedIndex ->
                    EmptyOption (OptionSelected selectedIndex) label

                OptionHighlighted ->
                    EmptyOption OptionShown label

                OptionDisabled ->
                    EmptyOption OptionDisabled label

                OptionSelectedHighlighted selectedIndex ->
                    EmptyOption (OptionSelectedHighlighted selectedIndex) label


isOptionHighlighted : Option -> Bool
isOptionHighlighted option =
    case option of
        Option display _ _ _ _ _ ->
            case display of
                OptionShown ->
                    False

                OptionHidden ->
                    False

                OptionSelected _ ->
                    False

                OptionSelectedHighlighted _ ->
                    False

                OptionHighlighted ->
                    True

                OptionDisabled ->
                    False

        CustomOption display _ _ _ ->
            case display of
                OptionShown ->
                    False

                OptionHidden ->
                    False

                OptionSelected _ ->
                    False

                OptionSelectedHighlighted _ ->
                    False

                OptionHighlighted ->
                    True

                OptionDisabled ->
                    False

        EmptyOption display _ ->
            case display of
                OptionShown ->
                    False

                OptionHidden ->
                    False

                OptionSelected _ ->
                    False

                OptionSelectedHighlighted _ ->
                    False

                OptionHighlighted ->
                    True

                OptionDisabled ->
                    False


optionIsHighlightable : Option -> Bool
optionIsHighlightable option =
    case option of
        Option display _ _ _ _ _ ->
            case display of
                OptionShown ->
                    True

                OptionHidden ->
                    False

                OptionSelected _ ->
                    False

                OptionSelectedHighlighted _ ->
                    False

                OptionHighlighted ->
                    False

                OptionDisabled ->
                    False

        CustomOption display _ _ _ ->
            case display of
                OptionShown ->
                    True

                OptionHidden ->
                    False

                OptionSelected _ ->
                    False

                OptionSelectedHighlighted _ ->
                    False

                OptionHighlighted ->
                    False

                OptionDisabled ->
                    False

        EmptyOption display _ ->
            case display of
                OptionShown ->
                    True

                OptionHidden ->
                    False

                OptionSelected _ ->
                    False

                OptionSelectedHighlighted _ ->
                    False

                OptionHighlighted ->
                    False

                OptionDisabled ->
                    False


selectOption : Int -> Option -> Option
selectOption selectionIndex option =
    case option of
        Option display label value description group search ->
            case display of
                OptionShown ->
                    Option (OptionSelected selectionIndex) label value description group search

                OptionHidden ->
                    Option (OptionSelected selectionIndex) label value description group search

                OptionSelected selectedIndex ->
                    Option (OptionSelected selectedIndex) label value description group search

                OptionSelectedHighlighted selectedIndex ->
                    Option (OptionSelectedHighlighted selectedIndex) label value description group search

                OptionHighlighted ->
                    Option (OptionSelected selectionIndex) label value description group search

                OptionDisabled ->
                    Option OptionDisabled label value description group search

        CustomOption display label value search ->
            case display of
                OptionShown ->
                    CustomOption (OptionSelected selectionIndex) label value search

                OptionHidden ->
                    CustomOption OptionHidden label value search

                OptionSelected selectedIndex ->
                    CustomOption (OptionSelected selectedIndex) label value search

                OptionSelectedHighlighted selectedIndex ->
                    CustomOption (OptionSelectedHighlighted selectedIndex) label value search

                OptionHighlighted ->
                    CustomOption (OptionSelected selectionIndex) label value search

                OptionDisabled ->
                    CustomOption OptionDisabled label value search

        EmptyOption display label ->
            case display of
                OptionShown ->
                    EmptyOption (OptionSelected selectionIndex) label

                OptionHidden ->
                    EmptyOption (OptionSelected selectionIndex) label

                OptionSelected selectedIndex ->
                    EmptyOption (OptionSelected selectedIndex) label

                OptionSelectedHighlighted selectedIndex ->
                    EmptyOption (OptionSelected selectedIndex) label

                OptionHighlighted ->
                    EmptyOption (OptionSelected selectionIndex) label

                OptionDisabled ->
                    EmptyOption OptionDisabled label


deselectOption : Option -> Option
deselectOption option =
    case option of
        Option display label value description group search ->
            case display of
                OptionShown ->
                    Option OptionShown label value description group search

                OptionHidden ->
                    Option OptionHidden label value description group search

                OptionSelected _ ->
                    Option OptionShown label value description group search

                OptionSelectedHighlighted _ ->
                    Option OptionShown label value description group search

                OptionHighlighted ->
                    Option OptionHighlighted
                        label
                        value
                        description
                        group
                        search

                OptionDisabled ->
                    Option OptionDisabled label value description group search

        CustomOption display label value search ->
            case display of
                OptionShown ->
                    CustomOption OptionShown label value search

                OptionHidden ->
                    CustomOption OptionHidden label value search

                OptionSelected _ ->
                    CustomOption OptionShown label value search

                OptionSelectedHighlighted _ ->
                    CustomOption OptionShown label value search

                OptionHighlighted ->
                    CustomOption OptionHighlighted label value search

                OptionDisabled ->
                    CustomOption OptionDisabled label value search

        EmptyOption display label ->
            case display of
                OptionShown ->
                    EmptyOption OptionShown label

                OptionHidden ->
                    EmptyOption OptionHidden label

                OptionSelected _ ->
                    EmptyOption OptionShown label

                OptionSelectedHighlighted _ ->
                    EmptyOption OptionShown label

                OptionHighlighted ->
                    EmptyOption OptionHighlighted label

                OptionDisabled ->
                    EmptyOption OptionDisabled label


isOptionSelectedHighlighted : Option -> Bool
isOptionSelectedHighlighted option =
    case option of
        Option optionDisplay _ _ _ _ _ ->
            isOptionDisplaySelectedHighlighted optionDisplay

        CustomOption optionDisplay _ _ _ ->
            isOptionDisplaySelectedHighlighted optionDisplay

        EmptyOption optionDisplay _ ->
            isOptionDisplaySelectedHighlighted optionDisplay


isOptionDisplaySelectedHighlighted : OptionDisplay -> Bool
isOptionDisplaySelectedHighlighted optionDisplay =
    case optionDisplay of
        OptionShown ->
            False

        OptionHidden ->
            False

        OptionSelected _ ->
            False

        OptionSelectedHighlighted _ ->
            True

        OptionHighlighted ->
            False

        OptionDisabled ->
            False


isEmptyOption : Option -> Bool
isEmptyOption option =
    case option of
        Option _ _ _ _ _ _ ->
            False

        CustomOption _ _ _ _ ->
            False

        EmptyOption _ _ ->
            True


optionToValueLabelTuple : Option -> ( String, String )
optionToValueLabelTuple option =
    ( getOptionValueAsString option, getOptionLabel option |> optionLabelToString )


isCustomOption : Option -> Bool
isCustomOption option =
    case option of
        Option _ _ _ _ _ _ ->
            False

        CustomOption _ _ _ _ ->
            True

        EmptyOption _ _ ->
            False


optionsDecoder : Json.Decode.Decoder (List Option)
optionsDecoder =
    Json.Decode.list decoder


decoder : Json.Decode.Decoder Option
decoder =
    Json.Decode.oneOf
        [ decodeOptionWithoutAValue
        , decodeOptionWithAValue
        ]


decodeOptionWithoutAValue : Json.Decode.Decoder Option
decodeOptionWithoutAValue =
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
                            displayDecoder
                            labelDecoder
            )


decodeOptionWithAValue : Json.Decode.Decoder Option
decodeOptionWithAValue =
    Json.Decode.map6 Option
        displayDecoder
        labelDecoder
        (Json.Decode.field
            "value"
            valueDecoder
        )
        descriptionDecoder
        optionGroupDecoder
        (Json.Decode.succeed Nothing)


displayDecoder : Json.Decode.Decoder OptionDisplay
displayDecoder =
    Json.Decode.oneOf
        [ Json.Decode.field
            "selected"
            Json.Decode.string
            |> Json.Decode.andThen
                (\str ->
                    case str of
                        "true" ->
                            Json.Decode.succeed (OptionSelected 0)

                        _ ->
                            Json.Decode.fail "Option is not selected"
                )
        , Json.Decode.field
            "selected"
            Json.Decode.bool
            |> Json.Decode.andThen
                (\isSelected ->
                    if isSelected then
                        Json.Decode.succeed (OptionSelected 0)

                    else
                        Json.Decode.succeed OptionShown
                )
        , Json.Decode.field
            "disabled"
            Json.Decode.bool
            |> Json.Decode.andThen
                (\isDisabled ->
                    if isDisabled then
                        Json.Decode.succeed OptionDisabled

                    else
                        Json.Decode.fail "Option is not disabled"
                )
        , Json.Decode.succeed OptionShown
        ]


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
        , ( "description", Json.Encode.string (getOptionDescription option |> optionDescriptionToString) )
        , ( "isSelected", Json.Encode.bool (isOptionSelected option) )
        ]
