module Option exposing
    ( Option(..)
    , OptionDisplay(..)
    , OptionLabel(..)
    , OptionValue
    , decodeOptions
    , decoder
    , getOptionDisplay
    , getOptionLabelString
    , highlightOptionInList
    , newOption
    , newSelectedOption
    , removeHighlightOptionInList
    , selectOptionInList
    , selectSingleOptionInList
    , selectedOptionsToTuple
    , setLabel
    )

import Json.Decode


type Option
    = Option OptionDisplay OptionLabel OptionValue


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


newOption : String -> Option
newOption string =
    Option OptionShown (OptionLabel string) (OptionValue string)


setLabel : String -> Option -> Option
setLabel string option =
    case option of
        Option optionDisplay _ optionValue ->
            Option optionDisplay (OptionLabel string) optionValue


newSelectedOption : String -> Option
newSelectedOption string =
    Option OptionSelected (OptionLabel string) (OptionValue string)


getOptionDisplay : Option -> OptionDisplay
getOptionDisplay (Option display _ _) =
    display


getOptionLabelString : Option -> String
getOptionLabelString (Option _ label _) =
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
highlightOption (Option display label value) =
    case display of
        OptionShown ->
            Option OptionHighlighted label value

        OptionHidden ->
            Option OptionHidden label value

        OptionSelected ->
            Option OptionSelected label value

        OptionHighlighted ->
            Option OptionHighlighted label value


removeHighlightOption : Option -> Option
removeHighlightOption (Option display label value) =
    case display of
        OptionShown ->
            Option OptionShown label value

        OptionHidden ->
            Option OptionHidden label value

        OptionSelected ->
            Option OptionSelected label value

        OptionHighlighted ->
            Option OptionShown label value


selectOption : Option -> Option
selectOption (Option display label value) =
    case display of
        OptionShown ->
            Option OptionSelected label value

        OptionHidden ->
            Option OptionSelected label value

        OptionSelected ->
            Option OptionSelected label value

        OptionHighlighted ->
            Option OptionSelected label value


deselectOption : Option -> Option
deselectOption (Option display label value) =
    case display of
        OptionShown ->
            Option OptionShown label value

        OptionHidden ->
            Option OptionHidden label value

        OptionSelected ->
            Option OptionShown label value

        OptionHighlighted ->
            Option OptionHighlighted label value


selectedOptions : List Option -> List Option
selectedOptions options =
    options
        |> List.filter
            (\option_ ->
                case option_ of
                    Option display _ _ ->
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
        Option _ (OptionLabel label) (OptionValue value) ->
            ( value, label )


decodeOptions : Json.Decode.Decoder (List Option)
decodeOptions =
    Json.Decode.list decoder


decoder : Json.Decode.Decoder Option
decoder =
    Json.Decode.map3 Option
        displayDecoder
        (Json.Decode.field
            "label"
            labelDecoder
        )
        (Json.Decode.field
            "value"
            valueDecoder
        )


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
