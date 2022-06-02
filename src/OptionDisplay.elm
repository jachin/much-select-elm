module OptionDisplay exposing (OptionDisplay(..), addHighlight, default, deselect, disabled, getErrors, getSelectedIndex, isHighlightable, isHighlighted, isInvalid, isPendingValidation, isSelected, removeHighlight, select, selected, selectedAndInvalid, selectedAndPendingValidation, setErrors, setSelectedIndex, shown)

import SelectionMode exposing (SelectionMode)
import TransformAndValidate exposing (ValidationFailureMessage)


type OptionDisplay
    = OptionShown
    | OptionHidden
    | OptionSelected Int
    | OptionSelectedAndInvalid Int (List ValidationFailureMessage)
    | OptionSelectedPendingValidation Int
    | OptionSelectedHighlighted Int
    | OptionHighlighted
    | OptionDisabled
    | OptionNew


default : OptionDisplay
default =
    OptionShown


shown : OptionDisplay
shown =
    OptionShown


selected : Int -> OptionDisplay
selected index =
    OptionSelected index


selectedAndInvalid : Int -> List ValidationFailureMessage -> OptionDisplay
selectedAndInvalid index validationFailureMessages =
    OptionSelectedAndInvalid index validationFailureMessages


selectedAndPendingValidation : Int -> OptionDisplay
selectedAndPendingValidation index =
    OptionSelectedPendingValidation index


disabled : OptionDisplay
disabled =
    OptionDisabled


isSelected : OptionDisplay -> Bool
isSelected optionDisplay =
    case optionDisplay of
        OptionShown ->
            False

        OptionHidden ->
            False

        OptionSelected _ ->
            True

        OptionSelectedPendingValidation _ ->
            True

        OptionSelectedAndInvalid _ _ ->
            True

        OptionSelectedHighlighted _ ->
            True

        OptionHighlighted ->
            False

        OptionDisabled ->
            False

        OptionNew ->
            False


setSelectedIndex : Int -> OptionDisplay -> OptionDisplay
setSelectedIndex selectedIndex optionDisplay =
    case optionDisplay of
        OptionShown ->
            optionDisplay

        OptionHidden ->
            optionDisplay

        OptionSelected _ ->
            OptionSelected selectedIndex

        OptionSelectedPendingValidation _ ->
            OptionSelectedPendingValidation selectedIndex

        OptionSelectedAndInvalid _ errors ->
            OptionSelectedAndInvalid selectedIndex errors

        OptionSelectedHighlighted _ ->
            OptionSelectedHighlighted selectedIndex

        OptionHighlighted ->
            optionDisplay

        OptionDisabled ->
            optionDisplay

        OptionNew ->
            optionDisplay


getSelectedIndex : OptionDisplay -> Int
getSelectedIndex optionDisplay =
    case optionDisplay of
        OptionShown ->
            -1

        OptionHidden ->
            -1

        OptionSelected int ->
            int

        OptionSelectedPendingValidation int ->
            int

        OptionSelectedAndInvalid int _ ->
            int

        OptionSelectedHighlighted int ->
            int

        OptionHighlighted ->
            -1

        OptionDisabled ->
            -1

        OptionNew ->
            -1


select : Int -> OptionDisplay -> OptionDisplay
select selectedIndex optionDisplay =
    case optionDisplay of
        OptionShown ->
            OptionSelected selectedIndex

        OptionHidden ->
            OptionSelected selectedIndex

        OptionSelected _ ->
            OptionSelected selectedIndex

        OptionSelectedPendingValidation _ ->
            optionDisplay

        OptionSelectedAndInvalid _ _ ->
            optionDisplay

        OptionSelectedHighlighted _ ->
            OptionSelectedHighlighted selectedIndex

        OptionHighlighted ->
            OptionSelected selectedIndex

        OptionDisabled ->
            optionDisplay

        OptionNew ->
            optionDisplay


deselect : OptionDisplay -> OptionDisplay
deselect optionDisplay =
    case optionDisplay of
        OptionShown ->
            optionDisplay

        OptionHidden ->
            optionDisplay

        OptionSelected _ ->
            OptionShown

        OptionSelectedPendingValidation _ ->
            OptionShown

        OptionSelectedAndInvalid _ _ ->
            OptionShown

        OptionSelectedHighlighted _ ->
            OptionShown

        OptionHighlighted ->
            optionDisplay

        OptionDisabled ->
            optionDisplay

        OptionNew ->
            optionDisplay


addHighlight : OptionDisplay -> OptionDisplay
addHighlight optionDisplay =
    case optionDisplay of
        OptionShown ->
            OptionHighlighted

        OptionHidden ->
            optionDisplay

        OptionSelected selectedIndex ->
            OptionSelectedHighlighted selectedIndex

        OptionSelectedPendingValidation _ ->
            optionDisplay

        OptionSelectedAndInvalid _ _ ->
            optionDisplay

        OptionSelectedHighlighted _ ->
            optionDisplay

        OptionHighlighted ->
            optionDisplay

        OptionDisabled ->
            optionDisplay

        OptionNew ->
            optionDisplay


removeHighlight : OptionDisplay -> OptionDisplay
removeHighlight optionDisplay =
    case optionDisplay of
        OptionShown ->
            optionDisplay

        OptionHidden ->
            optionDisplay

        OptionSelected _ ->
            optionDisplay

        OptionSelectedPendingValidation _ ->
            optionDisplay

        OptionSelectedAndInvalid _ _ ->
            optionDisplay

        OptionSelectedHighlighted selectedIndex ->
            OptionSelected selectedIndex

        OptionHighlighted ->
            OptionShown

        OptionDisabled ->
            optionDisplay

        OptionNew ->
            optionDisplay


isHighlighted : OptionDisplay -> Bool
isHighlighted optionDisplay =
    case optionDisplay of
        OptionShown ->
            False

        OptionHidden ->
            False

        OptionSelected _ ->
            False

        OptionSelectedAndInvalid _ _ ->
            False

        OptionSelectedPendingValidation _ ->
            False

        OptionSelectedHighlighted _ ->
            False

        OptionHighlighted ->
            True

        OptionDisabled ->
            False

        OptionNew ->
            False


isHighlightable : SelectionMode -> OptionDisplay -> Bool
isHighlightable selectionMode optionDisplay =
    case optionDisplay of
        OptionShown ->
            True

        OptionHidden ->
            False

        OptionSelected _ ->
            case selectionMode of
                SelectionMode.SingleSelect ->
                    True

                SelectionMode.MultiSelect ->
                    False

        OptionSelectedPendingValidation _ ->
            False

        OptionSelectedAndInvalid _ _ ->
            False

        OptionSelectedHighlighted _ ->
            False

        OptionHighlighted ->
            False

        OptionDisabled ->
            False

        OptionNew ->
            False


setErrors : List ValidationFailureMessage -> OptionDisplay -> OptionDisplay
setErrors validationErrorMessages optionDisplay =
    case optionDisplay of
        OptionShown ->
            optionDisplay

        OptionHidden ->
            optionDisplay

        OptionSelected selectedIndex ->
            if List.length validationErrorMessages > 0 then
                OptionSelectedAndInvalid selectedIndex validationErrorMessages

            else
                optionDisplay

        OptionSelectedPendingValidation selectedIndex ->
            if List.length validationErrorMessages > 0 then
                OptionSelectedAndInvalid selectedIndex validationErrorMessages

            else
                optionDisplay

        OptionSelectedAndInvalid selectedIndex _ ->
            OptionSelectedAndInvalid selectedIndex validationErrorMessages

        OptionSelectedHighlighted _ ->
            optionDisplay

        OptionHighlighted ->
            optionDisplay

        OptionDisabled ->
            optionDisplay

        OptionNew ->
            optionDisplay


getErrors : OptionDisplay -> List ValidationFailureMessage
getErrors optionDisplay =
    case optionDisplay of
        OptionShown ->
            []

        OptionHidden ->
            []

        OptionSelected _ ->
            []

        OptionSelectedPendingValidation _ ->
            []

        OptionSelectedAndInvalid _ validationFailures ->
            validationFailures

        OptionSelectedHighlighted _ ->
            []

        OptionHighlighted ->
            []

        OptionDisabled ->
            []

        OptionNew ->
            []


isInvalid : OptionDisplay -> Bool
isInvalid optionDisplay =
    case optionDisplay of
        OptionShown ->
            False

        OptionHidden ->
            False

        OptionSelected _ ->
            False

        OptionSelectedPendingValidation _ ->
            False

        OptionSelectedAndInvalid _ _ ->
            True

        OptionSelectedHighlighted _ ->
            False

        OptionHighlighted ->
            False

        OptionDisabled ->
            False

        OptionNew ->
            -- TODO ???
            False


isPendingValidation : OptionDisplay -> Bool
isPendingValidation optionDisplay =
    case optionDisplay of
        OptionShown ->
            False

        OptionHidden ->
            False

        OptionSelected _ ->
            False

        OptionSelectedPendingValidation _ ->
            True

        OptionSelectedAndInvalid _ _ ->
            False

        OptionSelectedHighlighted _ ->
            False

        OptionHighlighted ->
            False

        OptionDisabled ->
            False

        OptionNew ->
            -- TODO ???
            False
