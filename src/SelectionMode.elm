module SelectionMode exposing
    ( OutputStyle(..)
    , SelectionConfig(..)
    , canDoSingleItemRemoval
    , defaultSelectionMode
    , getCustomOptionHint
    , getCustomOptions
    , getDropdownStyle
    , getMaxDropdownItems
    , getOutputStyle
    , getPlaceHolder
    , getSearchStringMinimumLength
    , getSelectedItemPlacementMode
    , getSingleItemRemoval
    , isDisabled
    , isFocused
    , isSingleSelect
    , makeSelectionMode
    , setAllowCustomOptionsWithBool
    , setDropdownStyle
    , setInteractionState
    , setIsDisabled
    , setIsFocused
    , setMaxDropdownItems
    , setMultiSelectModeWithBool
    , setSearchStringMinimumLength
    , setSelectedItemStaysInPlaceWithBool
    , setShowDropdown
    , setSingleItemRemoval
    , showDropdown
    , showDropdownFooter
    , stringToOutputStyle
    )

import OutputStyle
    exposing
        ( CustomOptionHint
        , CustomOptions(..)
        , DropdownState(..)
        , DropdownStyle(..)
        , MaxDropdownItems(..)
        , MultiSelectOutputStyle(..)
        , SearchStringMinimumLength(..)
        , SelectedItemPlacementMode(..)
        , SingleItemRemoval(..)
        , SingleSelectOutputStyle(..)
        )
import PositiveInt


type alias Placeholder =
    String


type InteractionState
    = Focused
    | Unfocused
    | Disabled


type OutputStyle
    = CustomHtml
    | Datalist


type SelectionConfig
    = SingleSelect SingleSelectOutputStyle Placeholder InteractionState
    | MultiSelect MultiSelectOutputStyle Placeholder InteractionState


defaultSelectionMode : SelectionConfig
defaultSelectionMode =
    SingleSelect
        (SingleSelectCustomHtml
            { customOptions = NoCustomOptions
            , selectedItemPlacementMode = SelectedItemStaysInPlace
            , maxDropdownItems = NoLimitToDropdownItems
            , searchStringMinimumLength = NoMinimumToSearchStringLength
            , dropdownState = Collapsed
            , dropdownStyle = NoFooter
            }
        )
        ""
        Unfocused


makeSelectionMode : Bool -> Bool -> Bool -> String -> String -> Maybe String -> Bool -> Int -> Bool -> Int -> Bool -> Result String SelectionConfig
makeSelectionMode disabled allowMultiSelect allowCustomOptions outputStyle placeholder customOptionHint enableMultiSelectSingleItemRemoval maxDropdownItems selectedItemStaysInPlace searchStringMinimumLength shouldShowDropdownFooter =
    let
        outputStyleResult =
            stringToOutputStyle outputStyle

        interactionState =
            if disabled then
                Disabled

            else
                Unfocused
    in
    Result.andThen
        (\s ->
            if allowMultiSelect then
                let
                    styleResult =
                        makeMultiSelectOutputStyle s allowCustomOptions enableMultiSelectSingleItemRemoval maxDropdownItems searchStringMinimumLength shouldShowDropdownFooter customOptionHint
                in
                Result.map (\style_ -> MultiSelect style_ placeholder interactionState) styleResult

            else
                let
                    styleResult =
                        makeSingleSelectOutputStyle s allowCustomOptions selectedItemStaysInPlace maxDropdownItems searchStringMinimumLength shouldShowDropdownFooter customOptionHint
                in
                Result.map
                    (\style_ -> SingleSelect style_ placeholder interactionState)
                    styleResult
        )
        outputStyleResult


makeSingleSelectOutputStyle : OutputStyle -> Bool -> Bool -> Int -> Int -> Bool -> Maybe String -> Result String SingleSelectOutputStyle
makeSingleSelectOutputStyle outputStyle allowCustomOptions selectedItemStaysInPlace maxDropdownItems searchStringMinimumLength shouldShowDropdownFooter customOptionHint =
    case outputStyle of
        CustomHtml ->
            let
                customOptions =
                    if allowCustomOptions then
                        AllowCustomOptions customOptionHint

                    else
                        NoCustomOptions

                selectedItemPlacementMode =
                    if selectedItemStaysInPlace then
                        SelectedItemStaysInPlace

                    else
                        SelectedItemMovesToTheTop

                dropdownStyle =
                    if shouldShowDropdownFooter then
                        ShowFooter

                    else
                        NoFooter
            in
            Ok
                (SingleSelectCustomHtml
                    { customOptions = customOptions
                    , selectedItemPlacementMode = selectedItemPlacementMode
                    , maxDropdownItems = FixedMaxDropdownItems (PositiveInt.new maxDropdownItems)
                    , searchStringMinimumLength = FixedSearchStringMinimumLength (PositiveInt.new searchStringMinimumLength)
                    , dropdownState = Collapsed
                    , dropdownStyle = dropdownStyle
                    }
                )

        Datalist ->
            Ok SingleSelectDatalist


makeMultiSelectOutputStyle : OutputStyle -> Bool -> Bool -> Int -> Int -> Bool -> Maybe String -> Result String MultiSelectOutputStyle
makeMultiSelectOutputStyle outputStyle allowCustomOptions enableMultiSelectSingleItemRemoval maxDropdownItems searchStringMinimumLength shouldShowDropdownFooter customOptionHint =
    case outputStyle of
        CustomHtml ->
            let
                customOptions =
                    if allowCustomOptions then
                        AllowCustomOptions customOptionHint

                    else
                        NoCustomOptions

                singleItemRemoval =
                    if enableMultiSelectSingleItemRemoval then
                        EnableSingleItemRemoval

                    else
                        DisableSingleItemRemoval

                dropdownStyle =
                    if shouldShowDropdownFooter then
                        ShowFooter

                    else
                        NoFooter
            in
            Ok
                (MultiSelectCustomHtml
                    { customOptions = customOptions
                    , singleItemRemoval = singleItemRemoval
                    , maxDropdownItems = FixedMaxDropdownItems (PositiveInt.new maxDropdownItems)
                    , searchStringMinimumLength = FixedSearchStringMinimumLength (PositiveInt.new searchStringMinimumLength)
                    , dropdownState = Collapsed
                    , dropdownStyle = dropdownStyle
                    }
                )

        Datalist ->
            Ok MultiSelectDataList


isSingleSelect : SelectionConfig -> Bool
isSingleSelect selectionMode =
    case selectionMode of
        SingleSelect _ _ _ ->
            True

        MultiSelect _ _ _ ->
            False


getOutputStyle : SelectionConfig -> OutputStyle
getOutputStyle selectionMode =
    case selectionMode of
        SingleSelect singleSelectOutputStyle _ _ ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml _ ->
                    CustomHtml

                SingleSelectDatalist ->
                    Datalist

        MultiSelect multiSelectOutputStyle _ _ ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml _ ->
                    CustomHtml

                MultiSelectDataList ->
                    Datalist


getCustomOptions : SelectionConfig -> CustomOptions
getCustomOptions selectionMode =
    case selectionMode of
        SingleSelect singleSelectOutputStyle _ _ ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    singleSelectCustomHtmlFields.customOptions

                SingleSelectDatalist ->
                    AllowCustomOptions Nothing

        MultiSelect multiSelectOutputStyle _ _ ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    multiSelectCustomHtmlFields.customOptions

                MultiSelectDataList ->
                    AllowCustomOptions Nothing


setCustomOptions : CustomOptions -> SelectionConfig -> SelectionConfig
setCustomOptions customOptions selectionMode =
    case selectionMode of
        SingleSelect singleSelectOutputStyle placeholder interactionState ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    SingleSelect
                        (SingleSelectCustomHtml
                            { singleSelectCustomHtmlFields | customOptions = customOptions }
                        )
                        placeholder
                        interactionState

                SingleSelectDatalist ->
                    selectionMode

        MultiSelect multiSelectOutputStyle placeholder interactionState ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    MultiSelect (MultiSelectCustomHtml { multiSelectCustomHtmlFields | customOptions = customOptions }) placeholder interactionState

                MultiSelectDataList ->
                    selectionMode


getCustomOptionHint : SelectionConfig -> CustomOptionHint
getCustomOptionHint selectionMode =
    case selectionMode of
        SingleSelect singleSelectOutputStyle placeholder interactionState ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    case singleSelectCustomHtmlFields.customOptions of
                        AllowCustomOptions customOptionHint ->
                            customOptionHint

                        NoCustomOptions ->
                            Nothing

                SingleSelectDatalist ->
                    Nothing

        MultiSelect multiSelectOutputStyle placeholder interactionState ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    case multiSelectCustomHtmlFields.customOptions of
                        AllowCustomOptions customOptionHint ->
                            customOptionHint

                        NoCustomOptions ->
                            Nothing

                MultiSelectDataList ->
                    Nothing


setAllowCustomOptionsWithBool : Bool -> CustomOptionHint -> SelectionConfig -> SelectionConfig
setAllowCustomOptionsWithBool allowCustomOptions customOptionHint mode =
    let
        newAllowCustomOptions : CustomOptions
        newAllowCustomOptions =
            if allowCustomOptions then
                AllowCustomOptions customOptionHint

            else
                NoCustomOptions
    in
    setCustomOptions newAllowCustomOptions mode


getSelectedItemPlacementMode : SelectionConfig -> SelectedItemPlacementMode
getSelectedItemPlacementMode selectionMode =
    case selectionMode of
        SingleSelect singleSelectOutputStyle _ _ ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    singleSelectCustomHtmlFields.selectedItemPlacementMode

                SingleSelectDatalist ->
                    SelectedItemIsHidden

        MultiSelect _ _ _ ->
            SelectedItemStaysInPlace


setSelectedItemStaysInPlaceWithBool : Bool -> SelectionConfig -> SelectionConfig
setSelectedItemStaysInPlaceWithBool selectedItemStaysInPlace selectionMode =
    if selectedItemStaysInPlace then
        setSelectedItemPlacementMode SelectedItemStaysInPlace selectionMode

    else
        setSelectedItemPlacementMode SelectedItemMovesToTheTop selectionMode


setSelectedItemPlacementMode : SelectedItemPlacementMode -> SelectionConfig -> SelectionConfig
setSelectedItemPlacementMode selectedItemPlacementMode selectionMode =
    case selectionMode of
        SingleSelect singleSelectOutputStyle placeholder interactionState ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    SingleSelect
                        (SingleSelectCustomHtml
                            { singleSelectCustomHtmlFields | selectedItemPlacementMode = selectedItemPlacementMode }
                        )
                        placeholder
                        interactionState

                SingleSelectDatalist ->
                    selectionMode

        MultiSelect _ _ _ ->
            selectionMode


setMultiSelectModeWithBool : Bool -> SelectionConfig -> SelectionConfig
setMultiSelectModeWithBool isInMultiSelectMode selectionMode =
    case selectionMode of
        SingleSelect singleSelectOutputStyle placeholder interactionState ->
            if isInMultiSelectMode then
                MultiSelect (OutputStyle.singleToMulti singleSelectOutputStyle) placeholder interactionState

            else
                selectionMode

        MultiSelect multiSelectOutputStyle placeholder interactionState ->
            if isInMultiSelectMode then
                selectionMode

            else
                SingleSelect (OutputStyle.multiToSingle multiSelectOutputStyle) placeholder interactionState


stringToOutputStyle : String -> Result String OutputStyle
stringToOutputStyle string =
    case string of
        "customHtml" ->
            Ok CustomHtml

        "datalist" ->
            Ok Datalist

        _ ->
            Err "Invalid output style"


isFocused : SelectionConfig -> Bool
isFocused selectionMode =
    case selectionMode of
        SingleSelect _ _ interactionState ->
            case interactionState of
                Focused ->
                    True

                Unfocused ->
                    False

                Disabled ->
                    False

        MultiSelect _ _ interactionState ->
            case interactionState of
                Focused ->
                    True

                Unfocused ->
                    False

                Disabled ->
                    False


setIsFocused : Bool -> SelectionConfig -> SelectionConfig
setIsFocused isFocused_ selectionMode =
    let
        newInteractionState =
            if isFocused_ then
                Focused

            else
                Unfocused
    in
    setInteractionState newInteractionState selectionMode


isDisabled : SelectionConfig -> Bool
isDisabled selectionMode =
    case selectionMode of
        SingleSelect _ _ interactionState ->
            case interactionState of
                Focused ->
                    False

                Unfocused ->
                    False

                Disabled ->
                    True

        MultiSelect _ _ interactionState ->
            case interactionState of
                Focused ->
                    False

                Unfocused ->
                    False

                Disabled ->
                    True


setIsDisabled : Bool -> SelectionConfig -> SelectionConfig
setIsDisabled isDisabled_ selectionMode =
    if isDisabled_ then
        setInteractionState Disabled selectionMode

    else
        selectionMode


setInteractionState : InteractionState -> SelectionConfig -> SelectionConfig
setInteractionState newInteractionState selectionMode =
    case selectionMode of
        SingleSelect singleSelectOutputStyle placeholder _ ->
            SingleSelect singleSelectOutputStyle placeholder newInteractionState

        MultiSelect multiSelectOutputStyle placeholder _ ->
            MultiSelect multiSelectOutputStyle placeholder newInteractionState


setShowDropdown : Bool -> SelectionConfig -> SelectionConfig
setShowDropdown showDropdown_ selectionMode =
    let
        newDropdownState =
            if showDropdown_ then
                Expanded

            else
                Collapsed
    in
    case selectionMode of
        SingleSelect singleSelectOutputStyle placeholder interactionState ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    SingleSelect
                        (SingleSelectCustomHtml
                            { singleSelectCustomHtmlFields | dropdownState = newDropdownState }
                        )
                        placeholder
                        interactionState

                SingleSelectDatalist ->
                    selectionMode

        MultiSelect multiSelectOutputStyle placeholder interactionState ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    MultiSelect
                        (MultiSelectCustomHtml { multiSelectCustomHtmlFields | dropdownState = newDropdownState })
                        placeholder
                        interactionState

                MultiSelectDataList ->
                    selectionMode


setDropdownStyle : DropdownStyle -> SelectionConfig -> SelectionConfig
setDropdownStyle dropdownStyle selectionMode =
    case selectionMode of
        SingleSelect singleSelectOutputStyle placeholder interactionState ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    SingleSelect
                        (SingleSelectCustomHtml
                            { singleSelectCustomHtmlFields | dropdownStyle = dropdownStyle }
                        )
                        placeholder
                        interactionState

                SingleSelectDatalist ->
                    selectionMode

        MultiSelect multiSelectOutputStyle placeholder interactionState ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    MultiSelect
                        (MultiSelectCustomHtml { multiSelectCustomHtmlFields | dropdownStyle = dropdownStyle })
                        placeholder
                        interactionState

                MultiSelectDataList ->
                    selectionMode


setMaxDropdownItems : MaxDropdownItems -> SelectionConfig -> SelectionConfig
setMaxDropdownItems maxDropdownItems selectionMode =
    case selectionMode of
        SingleSelect singleSelectOutputStyle placeholder interactionState ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    SingleSelect
                        (SingleSelectCustomHtml
                            { singleSelectCustomHtmlFields | maxDropdownItems = maxDropdownItems }
                        )
                        placeholder
                        interactionState

                SingleSelectDatalist ->
                    selectionMode

        MultiSelect multiSelectOutputStyle placeholder interactionState ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    MultiSelect
                        (MultiSelectCustomHtml { multiSelectCustomHtmlFields | maxDropdownItems = maxDropdownItems })
                        placeholder
                        interactionState

                MultiSelectDataList ->
                    selectionMode


getMaxDropdownItems : SelectionConfig -> MaxDropdownItems
getMaxDropdownItems selectionMode =
    case selectionMode of
        SingleSelect singleSelectOutputStyle _ _ ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    singleSelectCustomHtmlFields.maxDropdownItems

                SingleSelectDatalist ->
                    NoLimitToDropdownItems

        MultiSelect multiSelectOutputStyle _ _ ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    multiSelectCustomHtmlFields.maxDropdownItems

                MultiSelectDataList ->
                    NoLimitToDropdownItems


setSingleItemRemoval : SingleItemRemoval -> SelectionConfig -> SelectionConfig
setSingleItemRemoval newSingleItemRemoval selectionMode =
    case selectionMode of
        SingleSelect _ _ _ ->
            selectionMode

        MultiSelect multiSelectOutputStyle placeholder interactionState ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    MultiSelect
                        (MultiSelectCustomHtml { multiSelectCustomHtmlFields | singleItemRemoval = newSingleItemRemoval })
                        placeholder
                        interactionState

                MultiSelectDataList ->
                    selectionMode


setSearchStringMinimumLength : SearchStringMinimumLength -> SelectionConfig -> SelectionConfig
setSearchStringMinimumLength newSearchStringMinimumLength selectionMode =
    case selectionMode of
        SingleSelect singleSelectOutputStyle placeholder interactionState ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    SingleSelect
                        (SingleSelectCustomHtml
                            { singleSelectCustomHtmlFields | searchStringMinimumLength = newSearchStringMinimumLength }
                        )
                        placeholder
                        interactionState

                SingleSelectDatalist ->
                    selectionMode

        MultiSelect multiSelectOutputStyle placeholder interactionState ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    MultiSelect
                        (MultiSelectCustomHtml { multiSelectCustomHtmlFields | searchStringMinimumLength = newSearchStringMinimumLength })
                        placeholder
                        interactionState

                MultiSelectDataList ->
                    selectionMode


getSearchStringMinimumLength : SelectionConfig -> SearchStringMinimumLength
getSearchStringMinimumLength selectionMode =
    case selectionMode of
        SingleSelect singleSelectOutputStyle placeholder interactionState ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    singleSelectCustomHtmlFields.searchStringMinimumLength

                SingleSelectDatalist ->
                    NoMinimumToSearchStringLength

        MultiSelect multiSelectOutputStyle placeholder interactionState ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    multiSelectCustomHtmlFields.searchStringMinimumLength

                MultiSelectDataList ->
                    NoMinimumToSearchStringLength


getPlaceHolder : SelectionConfig -> Placeholder
getPlaceHolder selectionMode =
    case selectionMode of
        SingleSelect _ placeholder _ ->
            placeholder

        MultiSelect _ placeholder _ ->
            placeholder


getSingleItemRemoval : SelectionConfig -> SingleItemRemoval
getSingleItemRemoval selectionMode =
    case selectionMode of
        SingleSelect _ _ _ ->
            DisableSingleItemRemoval

        MultiSelect multiSelectOutputStyle placeholder interactionState ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    multiSelectCustomHtmlFields.singleItemRemoval

                MultiSelectDataList ->
                    EnableSingleItemRemoval


canDoSingleItemRemoval : SelectionConfig -> Bool
canDoSingleItemRemoval selectionMode =
    case getSingleItemRemoval selectionMode of
        EnableSingleItemRemoval ->
            True

        DisableSingleItemRemoval ->
            False


getDropdownStyle : SelectionConfig -> DropdownStyle
getDropdownStyle selectionMode =
    case selectionMode of
        SingleSelect singleSelectOutputStyle placeholder interactionState ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    singleSelectCustomHtmlFields.dropdownStyle

                SingleSelectDatalist ->
                    NoFooter

        MultiSelect multiSelectOutputStyle placeholder interactionState ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    multiSelectCustomHtmlFields.dropdownStyle

                MultiSelectDataList ->
                    NoFooter


showDropdownFooter : SelectionConfig -> Bool
showDropdownFooter selectionMode =
    case getDropdownStyle selectionMode of
        NoFooter ->
            False

        ShowFooter ->
            True


getDropdownState : SelectionConfig -> DropdownState
getDropdownState selectionMode =
    case selectionMode of
        SingleSelect singleSelectOutputStyle placeholder interactionState ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    singleSelectCustomHtmlFields.dropdownState

                SingleSelectDatalist ->
                    NotManagedByMe

        MultiSelect multiSelectOutputStyle placeholder interactionState ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    multiSelectCustomHtmlFields.dropdownState

                MultiSelectDataList ->
                    NotManagedByMe


showDropdown : SelectionConfig -> Bool
showDropdown selectionMode =
    case getDropdownState selectionMode of
        Expanded ->
            True

        Collapsed ->
            False

        NotManagedByMe ->
            False
