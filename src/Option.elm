module Option exposing
    ( Option(..)
    , OptionDescription
    , OptionDisplay(..)
    , OptionGroup
    , OptionLabel(..)
    , OptionValue
    , decoder
    , emptyOptionGroup
    , getOptionDescription
    , getOptionDescriptionString
    , getOptionDisplay
    , getOptionGroup
    , getOptionLabel
    , getOptionLabelString
    , getOptionValue
    , highlightOptionInList
    , newDisabledOption
    , newOption
    , newSelectedOption
    , optionDescriptionToBool
    , optionDescriptionToString
    , optionGroupToString
    , optionHasDescription
    , optionLabelToString
    , optionsDecoder
    , removeHighlightOptionInList
    , selectOptionInList
    , selectOptionsInOptionsList
    , selectSingleOptionInList
    , selectedOptionsToTuple
    , setDescription
    , setGroup
    , setLabel
    )

import Json.Decode


type Option
    = Option OptionDisplay OptionLabel OptionValue OptionDescription OptionGroup


getOptionLabel : Option -> OptionLabel
getOptionLabel (Option _ label _ _ _) =
    label


type OptionDisplay
    = OptionShown
    | OptionHidden
    | OptionSelected
    | OptionHighlighted
    | OptionDisabled


type OptionLabel
    = OptionLabel String


optionLabelToString : OptionLabel -> String
optionLabelToString optionLabel =
    case optionLabel of
        OptionLabel label ->
            label


type OptionValue
    = OptionValue String


type OptionDescription
    = OptionDescription String
    | NoDescription


optionDescriptionToString : OptionDescription -> String
optionDescriptionToString optionDescription =
    case optionDescription of
        OptionDescription string ->
            string

        NoDescription ->
            ""


optionDescriptionToBool : OptionDescription -> Bool
optionDescriptionToBool optionDescription =
    case optionDescription of
        OptionDescription _ ->
            True

        NoDescription ->
            False


type OptionGroup
    = OptionGroup String
    | NoOptionGroup


emptyOptionGroup : OptionGroup
emptyOptionGroup =
    NoOptionGroup


getOptionGroup : Option -> OptionGroup
getOptionGroup (Option _ _ _ _ group) =
    group


newOption : String -> Option
newOption string =
    Option OptionShown (OptionLabel string) (OptionValue string) NoDescription NoOptionGroup


setLabel : String -> Option -> Option
setLabel string option =
    case option of
        Option optionDisplay _ optionValue description group ->
            Option optionDisplay (OptionLabel string) optionValue description group


setDescription : String -> Option -> Option
setDescription string option =
    case option of
        Option optionDisplay label optionValue _ group ->
            Option optionDisplay label optionValue (OptionDescription string) group


setGroup : String -> Option -> Option
setGroup string option =
    case option of
        Option optionDisplay label optionValue description _ ->
            Option optionDisplay label optionValue description (OptionGroup string)


newSelectedOption : String -> Option
newSelectedOption string =
    Option OptionSelected (OptionLabel string) (OptionValue string) NoDescription NoOptionGroup


newDisabledOption : String -> Option
newDisabledOption string =
    Option OptionDisabled (OptionLabel string) (OptionValue string) NoDescription NoOptionGroup


getOptionDisplay : Option -> OptionDisplay
getOptionDisplay (Option display _ _ _ _) =
    display


getOptionValue : Option -> OptionValue
getOptionValue (Option _ _ value _ _) =
    value


getOptionValueAsString : Option -> String
getOptionValueAsString option =
    case option |> getOptionValue of
        OptionValue string ->
            string


optionGroupToString : OptionGroup -> String
optionGroupToString optionGroup =
    case optionGroup of
        OptionGroup string ->
            string

        NoOptionGroup ->
            ""


getOptionLabelString : Option -> String
getOptionLabelString (Option _ label _ _ _) =
    optionLabelToString label


getOptionDescription : Option -> OptionDescription
getOptionDescription option =
    case option of
        Option _ _ _ optionDescription _ ->
            optionDescription


getOptionDescriptionString : Option -> String
getOptionDescriptionString option =
    case option |> getOptionDescription of
        OptionDescription string ->
            string

        NoDescription ->
            ""


optionHasDescription : Option -> Bool
optionHasDescription option =
    case option |> getOptionDescription of
        OptionDescription _ ->
            True

        NoDescription ->
            False


selectedOptionsToTuple : List Option -> List ( String, String )
selectedOptionsToTuple options =
    options |> selectedOptions |> List.map optionToValueLabelTuple


selectOptionsInOptionsList : List String -> List Option -> List Option
selectOptionsInOptionsList strings options =
    List.map
        (\option ->
            if isOptionValueInList strings option then
                selectOption option

            else
                deselectOption option
        )
        options


isOptionValueInList : List String -> Option -> Bool
isOptionValueInList possibleValues option =
    List.any (\possibleValue -> getOptionValueAsString option == possibleValue) possibleValues


optionValuesEqual : Option -> OptionValue -> Bool
optionValuesEqual option optionValue =
    getOptionValue option == optionValue


highlightOptionInList : OptionValue -> List Option -> List Option
highlightOptionInList value options =
    List.map
        (\option_ ->
            if optionValuesEqual option_ value then
                highlightOption option_

            else
                removeHighlightOption option_
        )
        options


removeHighlightOptionInList : OptionValue -> List Option -> List Option
removeHighlightOptionInList value options =
    List.map
        (\option_ ->
            if optionValuesEqual option_ value then
                removeHighlightOption option_

            else
                option_
        )
        options


selectOptionInList : OptionValue -> List Option -> List Option
selectOptionInList value options =
    List.map
        (\option_ ->
            if optionValuesEqual option_ value then
                selectOption option_

            else
                option_
        )
        options


selectSingleOptionInList : OptionValue -> List Option -> List Option
selectSingleOptionInList value options =
    options
        |> List.map
            (\option_ ->
                if optionValuesEqual option_ value then
                    selectOption option_

                else
                    deselectOption option_
            )


highlightOption : Option -> Option
highlightOption (Option display label value description group) =
    case display of
        OptionShown ->
            Option OptionHighlighted label value description group

        OptionHidden ->
            Option OptionHidden label value description group

        OptionSelected ->
            Option OptionSelected label value description group

        OptionHighlighted ->
            Option OptionHighlighted label value description group

        OptionDisabled ->
            Option OptionDisabled label value description group


removeHighlightOption : Option -> Option
removeHighlightOption (Option display label value description group) =
    case display of
        OptionShown ->
            Option OptionShown label value description group

        OptionHidden ->
            Option OptionHidden label value description group

        OptionSelected ->
            Option OptionSelected label value description group

        OptionHighlighted ->
            Option OptionShown label value description group

        OptionDisabled ->
            Option OptionDisabled label value description group


selectOption : Option -> Option
selectOption (Option display label value description group) =
    case display of
        OptionShown ->
            Option OptionSelected label value description group

        OptionHidden ->
            Option OptionSelected label value description group

        OptionSelected ->
            Option OptionSelected label value description group

        OptionHighlighted ->
            Option OptionSelected label value description group

        OptionDisabled ->
            Option OptionDisabled label value description group


deselectOption : Option -> Option
deselectOption (Option display label value description group) =
    case display of
        OptionShown ->
            Option OptionShown label value description group

        OptionHidden ->
            Option OptionHidden label value description group

        OptionSelected ->
            Option OptionShown label value description group

        OptionHighlighted ->
            Option OptionHighlighted label value description group

        OptionDisabled ->
            Option OptionDisabled label value description group


selectedOptions : List Option -> List Option
selectedOptions options =
    options
        |> List.filter
            (\option_ ->
                case option_ of
                    Option display _ _ _ _ ->
                        case display of
                            OptionShown ->
                                False

                            OptionHidden ->
                                False

                            OptionSelected ->
                                True

                            OptionHighlighted ->
                                False

                            OptionDisabled ->
                                False
            )


optionToValueLabelTuple : Option -> ( String, String )
optionToValueLabelTuple option =
    case option of
        Option _ (OptionLabel label) (OptionValue value) _ _ ->
            ( value, label )


optionsDecoder : Json.Decode.Decoder (List Option)
optionsDecoder =
    Json.Decode.list decoder


decoder : Json.Decode.Decoder Option
decoder =
    Json.Decode.map5 Option
        displayDecoder
        (Json.Decode.field
            "label"
            labelDecoder
        )
        (Json.Decode.field
            "value"
            valueDecoder
        )
        descriptionDecoder
        optionGroupDecoder


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
                            Json.Decode.succeed OptionSelected

                        _ ->
                            Json.Decode.fail "Option is not selected"
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


labelDecoder : Json.Decode.Decoder OptionLabel
labelDecoder =
    Json.Decode.string
        |> Json.Decode.map
            OptionLabel


valueDecoder : Json.Decode.Decoder OptionValue
valueDecoder =
    Json.Decode.string
        |> Json.Decode.map
            OptionValue


descriptionDecoder : Json.Decode.Decoder OptionDescription
descriptionDecoder =
    Json.Decode.oneOf
        [ Json.Decode.field "description" Json.Decode.string
            |> Json.Decode.map OptionDescription
        , Json.Decode.succeed NoDescription
        ]


optionGroupDecoder : Json.Decode.Decoder OptionGroup
optionGroupDecoder =
    Json.Decode.oneOf
        [ Json.Decode.field "group" Json.Decode.string
            |> Json.Decode.map OptionGroup
        , Json.Decode.succeed NoOptionGroup
        ]
