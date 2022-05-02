module SelectionMode exposing
    ( OutputStyle(..)
    , SelectionConfig(..)
    , SelectionMode(..)
    , canDoSingleItemRemoval
    , defaultSelectionConfig
    , getCustomOptionHint
    , getCustomOptions
    , getDropdownStyle
    , getMaxDropdownItems
    , getOutputStyle
    , getPlaceholder
    , getSearchStringMinimumLength
    , getSelectedItemPlacementMode
    , getSelectionMode
    , getSingleItemRemoval
    , isDisabled
    , isFocused
    , isSingleSelect
    , makeSelectionConfig
    , setAllowCustomOptionsWithBool
    , setDropdownStyle
    , setInteractionState
    , setIsDisabled
    , setIsFocused
    , setMaxDropdownItems
    , setMultiSelectModeWithBool
    , setSearchStringMinimumLength
    , setSelectedItemStaysInPlaceWithBool
    , setSelectionMode
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


type SelectionMode
    = SingleSelect
    | MultiSelect


type SelectionConfig
    = SingleSelectConfig SingleSelectOutputStyle Placeholder InteractionState
    | MultiSelectConfig MultiSelectOutputStyle Placeholder InteractionState


defaultSelectionConfig : SelectionConfig
defaultSelectionConfig =
    SingleSelectConfig
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


makeSelectionConfig : Bool -> Bool -> Bool -> String -> String -> Maybe String -> Bool -> Int -> Bool -> Int -> Bool -> Result String SelectionConfig
makeSelectionConfig disabled allowMultiSelect allowCustomOptions outputStyle placeholder customOptionHint enableMultiSelectSingleItemRemoval maxDropdownItems selectedItemStaysInPlace searchStringMinimumLength shouldShowDropdownFooter =
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
                Result.map (\style_ -> MultiSelectConfig style_ placeholder interactionState) styleResult

            else
                let
                    styleResult =
                        makeSingleSelectOutputStyle s allowCustomOptions selectedItemStaysInPlace maxDropdownItems searchStringMinimumLength shouldShowDropdownFooter customOptionHint
                in
                Result.map
                    (\style_ -> SingleSelectConfig style_ placeholder interactionState)
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
        SingleSelectConfig _ _ _ ->
            True

        MultiSelectConfig _ _ _ ->
            False


getOutputStyle : SelectionConfig -> OutputStyle
getOutputStyle selectionConfig =
    case selectionConfig of
        SingleSelectConfig singleSelectOutputStyle _ _ ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml _ ->
                    CustomHtml

                SingleSelectDatalist ->
                    Datalist

        MultiSelectConfig multiSelectOutputStyle _ _ ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml _ ->
                    CustomHtml

                MultiSelectDataList ->
                    Datalist


getCustomOptions : SelectionConfig -> CustomOptions
getCustomOptions selectionConfig =
    case selectionConfig of
        SingleSelectConfig singleSelectOutputStyle _ _ ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    singleSelectCustomHtmlFields.customOptions

                SingleSelectDatalist ->
                    AllowCustomOptions Nothing

        MultiSelectConfig multiSelectOutputStyle _ _ ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    multiSelectCustomHtmlFields.customOptions

                MultiSelectDataList ->
                    AllowCustomOptions Nothing


setCustomOptions : CustomOptions -> SelectionConfig -> SelectionConfig
setCustomOptions customOptions selectionConfig =
    case selectionConfig of
        SingleSelectConfig singleSelectOutputStyle placeholder interactionState ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    SingleSelectConfig
                        (SingleSelectCustomHtml
                            { singleSelectCustomHtmlFields | customOptions = customOptions }
                        )
                        placeholder
                        interactionState

                SingleSelectDatalist ->
                    selectionConfig

        MultiSelectConfig multiSelectOutputStyle placeholder interactionState ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    MultiSelectConfig (MultiSelectCustomHtml { multiSelectCustomHtmlFields | customOptions = customOptions }) placeholder interactionState

                MultiSelectDataList ->
                    selectionConfig


getCustomOptionHint : SelectionConfig -> CustomOptionHint
getCustomOptionHint selectionConfig =
    case selectionConfig of
        SingleSelectConfig singleSelectOutputStyle _ _ ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    case singleSelectCustomHtmlFields.customOptions of
                        AllowCustomOptions customOptionHint ->
                            customOptionHint

                        NoCustomOptions ->
                            Nothing

                SingleSelectDatalist ->
                    Nothing

        MultiSelectConfig multiSelectOutputStyle _ _ ->
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
getSelectedItemPlacementMode selectionConfig =
    case selectionConfig of
        SingleSelectConfig singleSelectOutputStyle _ _ ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    singleSelectCustomHtmlFields.selectedItemPlacementMode

                SingleSelectDatalist ->
                    SelectedItemIsHidden

        MultiSelectConfig _ _ _ ->
            SelectedItemStaysInPlace


setSelectedItemStaysInPlaceWithBool : Bool -> SelectionConfig -> SelectionConfig
setSelectedItemStaysInPlaceWithBool selectedItemStaysInPlace selectionConfig =
    if selectedItemStaysInPlace then
        setSelectedItemPlacementMode SelectedItemStaysInPlace selectionConfig

    else
        setSelectedItemPlacementMode SelectedItemMovesToTheTop selectionConfig


setSelectedItemPlacementMode : SelectedItemPlacementMode -> SelectionConfig -> SelectionConfig
setSelectedItemPlacementMode selectedItemPlacementMode selectionConfig =
    case selectionConfig of
        SingleSelectConfig singleSelectOutputStyle placeholder interactionState ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    SingleSelectConfig
                        (SingleSelectCustomHtml
                            { singleSelectCustomHtmlFields | selectedItemPlacementMode = selectedItemPlacementMode }
                        )
                        placeholder
                        interactionState

                SingleSelectDatalist ->
                    selectionConfig

        MultiSelectConfig _ _ _ ->
            selectionConfig


setMultiSelectModeWithBool : Bool -> SelectionConfig -> SelectionConfig
setMultiSelectModeWithBool isInMultiSelectMode selectionConfig =
    case selectionConfig of
        SingleSelectConfig singleSelectOutputStyle placeholder interactionState ->
            if isInMultiSelectMode then
                MultiSelectConfig (OutputStyle.singleToMulti singleSelectOutputStyle) placeholder interactionState

            else
                selectionConfig

        MultiSelectConfig multiSelectOutputStyle placeholder interactionState ->
            if isInMultiSelectMode then
                selectionConfig

            else
                SingleSelectConfig (OutputStyle.multiToSingle multiSelectOutputStyle) placeholder interactionState


getSelectionMode : SelectionConfig -> SelectionMode
getSelectionMode selectionConfig =
    case selectionConfig of
        SingleSelectConfig singleSelectOutputStyle placeholder interactionState ->
            SingleSelect

        MultiSelectConfig multiSelectOutputStyle placeholder interactionState ->
            MultiSelect


setSelectionMode : SelectionMode -> SelectionConfig -> SelectionConfig
setSelectionMode selectionMode selectionConfig =
    case selectionMode of
        SingleSelect ->
            case selectionConfig of
                SingleSelectConfig _ _ _ ->
                    selectionConfig

                MultiSelectConfig multiSelectOutputStyle placeholder interactionState ->
                    SingleSelectConfig (OutputStyle.multiToSingle multiSelectOutputStyle) placeholder interactionState

        MultiSelect ->
            case selectionConfig of
                SingleSelectConfig singleSelectOutputStyle placeholder interactionState ->
                    MultiSelectConfig (OutputStyle.singleToMulti singleSelectOutputStyle) placeholder interactionState

                MultiSelectConfig _ _ _ ->
                    selectionConfig


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
isFocused selectionConfig =
    case selectionConfig of
        SingleSelectConfig _ _ interactionState ->
            case interactionState of
                Focused ->
                    True

                Unfocused ->
                    False

                Disabled ->
                    False

        MultiSelectConfig _ _ interactionState ->
            case interactionState of
                Focused ->
                    True

                Unfocused ->
                    False

                Disabled ->
                    False


setIsFocused : Bool -> SelectionConfig -> SelectionConfig
setIsFocused isFocused_ selectionConfig =
    let
        newInteractionState =
            if isFocused_ then
                Focused

            else
                Unfocused
    in
    setInteractionState newInteractionState selectionConfig


isDisabled : SelectionConfig -> Bool
isDisabled selectionConfig =
    case selectionConfig of
        SingleSelectConfig _ _ interactionState ->
            case interactionState of
                Focused ->
                    False

                Unfocused ->
                    False

                Disabled ->
                    True

        MultiSelectConfig _ _ interactionState ->
            case interactionState of
                Focused ->
                    False

                Unfocused ->
                    False

                Disabled ->
                    True


setIsDisabled : Bool -> SelectionConfig -> SelectionConfig
setIsDisabled isDisabled_ selectionConfig =
    if isDisabled_ then
        setInteractionState Disabled selectionConfig

    else
        selectionConfig


setInteractionState : InteractionState -> SelectionConfig -> SelectionConfig
setInteractionState newInteractionState selectionConfig =
    case selectionConfig of
        SingleSelectConfig singleSelectOutputStyle placeholder _ ->
            SingleSelectConfig singleSelectOutputStyle placeholder newInteractionState

        MultiSelectConfig multiSelectOutputStyle placeholder _ ->
            MultiSelectConfig multiSelectOutputStyle placeholder newInteractionState


setShowDropdown : Bool -> SelectionConfig -> SelectionConfig
setShowDropdown showDropdown_ selectionConfig =
    let
        newDropdownState =
            if showDropdown_ then
                Expanded

            else
                Collapsed
    in
    case selectionConfig of
        SingleSelectConfig singleSelectOutputStyle placeholder interactionState ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    SingleSelectConfig
                        (SingleSelectCustomHtml
                            { singleSelectCustomHtmlFields | dropdownState = newDropdownState }
                        )
                        placeholder
                        interactionState

                SingleSelectDatalist ->
                    selectionConfig

        MultiSelectConfig multiSelectOutputStyle placeholder interactionState ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    MultiSelectConfig
                        (MultiSelectCustomHtml { multiSelectCustomHtmlFields | dropdownState = newDropdownState })
                        placeholder
                        interactionState

                MultiSelectDataList ->
                    selectionConfig


setDropdownStyle : DropdownStyle -> SelectionConfig -> SelectionConfig
setDropdownStyle dropdownStyle selectionConfig =
    case selectionConfig of
        SingleSelectConfig singleSelectOutputStyle placeholder interactionState ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    SingleSelectConfig
                        (SingleSelectCustomHtml
                            { singleSelectCustomHtmlFields | dropdownStyle = dropdownStyle }
                        )
                        placeholder
                        interactionState

                SingleSelectDatalist ->
                    selectionConfig

        MultiSelectConfig multiSelectOutputStyle placeholder interactionState ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    MultiSelectConfig
                        (MultiSelectCustomHtml { multiSelectCustomHtmlFields | dropdownStyle = dropdownStyle })
                        placeholder
                        interactionState

                MultiSelectDataList ->
                    selectionConfig


setMaxDropdownItems : MaxDropdownItems -> SelectionConfig -> SelectionConfig
setMaxDropdownItems maxDropdownItems selectionConfig =
    case selectionConfig of
        SingleSelectConfig singleSelectOutputStyle placeholder interactionState ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    SingleSelectConfig
                        (SingleSelectCustomHtml
                            { singleSelectCustomHtmlFields | maxDropdownItems = maxDropdownItems }
                        )
                        placeholder
                        interactionState

                SingleSelectDatalist ->
                    selectionConfig

        MultiSelectConfig multiSelectOutputStyle placeholder interactionState ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    MultiSelectConfig
                        (MultiSelectCustomHtml { multiSelectCustomHtmlFields | maxDropdownItems = maxDropdownItems })
                        placeholder
                        interactionState

                MultiSelectDataList ->
                    selectionConfig


getMaxDropdownItems : SelectionConfig -> MaxDropdownItems
getMaxDropdownItems selectionConfig =
    case selectionConfig of
        SingleSelectConfig singleSelectOutputStyle _ _ ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    singleSelectCustomHtmlFields.maxDropdownItems

                SingleSelectDatalist ->
                    NoLimitToDropdownItems

        MultiSelectConfig multiSelectOutputStyle _ _ ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    multiSelectCustomHtmlFields.maxDropdownItems

                MultiSelectDataList ->
                    NoLimitToDropdownItems


setSingleItemRemoval : SingleItemRemoval -> SelectionConfig -> SelectionConfig
setSingleItemRemoval newSingleItemRemoval selectionConfig =
    case selectionConfig of
        SingleSelectConfig _ _ _ ->
            selectionConfig

        MultiSelectConfig multiSelectOutputStyle placeholder interactionState ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    MultiSelectConfig
                        (MultiSelectCustomHtml { multiSelectCustomHtmlFields | singleItemRemoval = newSingleItemRemoval })
                        placeholder
                        interactionState

                MultiSelectDataList ->
                    selectionConfig


setSearchStringMinimumLength : SearchStringMinimumLength -> SelectionConfig -> SelectionConfig
setSearchStringMinimumLength newSearchStringMinimumLength selectionConfig =
    case selectionConfig of
        SingleSelectConfig singleSelectOutputStyle placeholder interactionState ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    SingleSelectConfig
                        (SingleSelectCustomHtml
                            { singleSelectCustomHtmlFields | searchStringMinimumLength = newSearchStringMinimumLength }
                        )
                        placeholder
                        interactionState

                SingleSelectDatalist ->
                    selectionConfig

        MultiSelectConfig multiSelectOutputStyle placeholder interactionState ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    MultiSelectConfig
                        (MultiSelectCustomHtml { multiSelectCustomHtmlFields | searchStringMinimumLength = newSearchStringMinimumLength })
                        placeholder
                        interactionState

                MultiSelectDataList ->
                    selectionConfig


getSearchStringMinimumLength : SelectionConfig -> SearchStringMinimumLength
getSearchStringMinimumLength selectionConfig =
    case selectionConfig of
        SingleSelectConfig singleSelectOutputStyle _ _ ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    singleSelectCustomHtmlFields.searchStringMinimumLength

                SingleSelectDatalist ->
                    NoMinimumToSearchStringLength

        MultiSelectConfig multiSelectOutputStyle _ _ ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    multiSelectCustomHtmlFields.searchStringMinimumLength

                MultiSelectDataList ->
                    NoMinimumToSearchStringLength


getPlaceholder : SelectionConfig -> Placeholder
getPlaceholder selectionConfig =
    case selectionConfig of
        SingleSelectConfig _ placeholder _ ->
            placeholder

        MultiSelectConfig _ placeholder _ ->
            placeholder


getSingleItemRemoval : SelectionConfig -> SingleItemRemoval
getSingleItemRemoval selectionConfig =
    case selectionConfig of
        SingleSelectConfig _ _ _ ->
            DisableSingleItemRemoval

        MultiSelectConfig multiSelectOutputStyle _ _ ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    multiSelectCustomHtmlFields.singleItemRemoval

                MultiSelectDataList ->
                    EnableSingleItemRemoval


canDoSingleItemRemoval : SelectionConfig -> Bool
canDoSingleItemRemoval selectionConfig =
    case getSingleItemRemoval selectionConfig of
        EnableSingleItemRemoval ->
            True

        DisableSingleItemRemoval ->
            False


getDropdownStyle : SelectionConfig -> DropdownStyle
getDropdownStyle selectionConfig =
    case selectionConfig of
        SingleSelectConfig singleSelectOutputStyle _ _ ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    singleSelectCustomHtmlFields.dropdownStyle

                SingleSelectDatalist ->
                    NoFooter

        MultiSelectConfig multiSelectOutputStyle _ _ ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    multiSelectCustomHtmlFields.dropdownStyle

                MultiSelectDataList ->
                    NoFooter


showDropdownFooter : SelectionConfig -> Bool
showDropdownFooter selectionConfig =
    case getDropdownStyle selectionConfig of
        NoFooter ->
            False

        ShowFooter ->
            True


getDropdownState : SelectionConfig -> DropdownState
getDropdownState selectionConfig =
    case selectionConfig of
        SingleSelectConfig singleSelectOutputStyle _ _ ->
            case singleSelectOutputStyle of
                SingleSelectCustomHtml singleSelectCustomHtmlFields ->
                    singleSelectCustomHtmlFields.dropdownState

                SingleSelectDatalist ->
                    NotManagedByMe

        MultiSelectConfig multiSelectOutputStyle _ _ ->
            case multiSelectOutputStyle of
                MultiSelectCustomHtml multiSelectCustomHtmlFields ->
                    multiSelectCustomHtmlFields.dropdownState

                MultiSelectDataList ->
                    NotManagedByMe


showDropdown : SelectionConfig -> Bool
showDropdown selectionConfig =
    case getDropdownState selectionConfig of
        Expanded ->
            True

        Collapsed ->
            False

        NotManagedByMe ->
            False
