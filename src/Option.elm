module Option exposing
    ( Option(..)
    , OptionDisplay(..)
    , OptionLabel(..)
    , OptionValue
    , decoder
    , getOptionDisplay
    , getOptionLabelString
    , highlightOptionInList
    , newOption
    , newSelectedOption
    , optionsDecoder
    , removeHighlightOptionInList
    , selectOptionInList
    , selectSingleOptionInList
    , selectedOptionsToTuple
    , setDescription
    , setGroup
    , setLabel
    )

import Json.Decode


type Option
    = Option OptionDisplay OptionLabel OptionValue OptionDescription OptionGroup


type OptionDisplay
    = OptionShown
    | OptionHidden
    | OptionSelected
    | OptionHighlighted


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


type OptionGroup
    = OptionGroup String
    | NoOptionGroup


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


getOptionDisplay : Option -> OptionDisplay
getOptionDisplay (Option display _ _ _ _) =
    display


getOptionLabelString : Option -> String
getOptionLabelString (Option _ label _ _ _) =
    optionLabelToString label


selectedOptionsToTuple : List Option -> List ( String, String )
selectedOptionsToTuple options =
    options |> selectedOptions |> List.map optionToValueLabelTuple


highlightOptionInList : Option -> List Option -> List Option
highlightOptionInList option options =
    List.map
        (\option_ ->
            if option_ == option then
                highlightOption option_

            else
                removeHighlightOption option_
        )
        options


removeHighlightOptionInList : Option -> List Option -> List Option
removeHighlightOptionInList option options =
    List.map
        (\option_ ->
            if option_ == option then
                removeHighlightOption option

            else
                option_
        )
        options


selectOptionInList : Option -> List Option -> List Option
selectOptionInList option options =
    List.map
        (\option_ ->
            if option_ == option then
                selectOption option_

            else
                option_
        )
        options


selectSingleOptionInList : Option -> List Option -> List Option
selectSingleOptionInList option options =
    options
        |> List.map
            (\option_ ->
                if option_ == option then
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
                            Json.Decode.succeed OptionShown
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
