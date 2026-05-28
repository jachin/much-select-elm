# Example `elm-program-test` Coverage Plan

## Goal

Create a dedicated `elm-program-test` suite for **every demo example** in `examples/*.html` so behavior shown on the docs/demo site is covered by executable Elm tests.

- Total demo examples: **94**
- Current `elm-program-test` suites: **6** (not one-to-one with examples)
- Gap to close for example-specific suites: **94 suites**

## Proposed structure

- New test namespace: `tests/Examples/`
- One module per example slug
  - Example: `examples/simple-example.html` -> `tests/Examples/SimpleExample.elm`
- Naming convention per suite:
  - `suite : Test`
  - `describe "Example: <slug>"`
  - 2-5 focused tests (start with one "first test" below, then expand)

## Priority phases

## Phase 1 — Core user flows and existing high-signal behavior

Focus: selection model, attributes, output style, key events, and cases already reflected by current tests.

1. `tests/Examples/SimpleExample.elm`
   - First test: `renders single-select with initial placeholder and available options`
2. `tests/Examples/MultiSelect.elm`
   - First test: `renders multi-select mode with selected-value container`
3. `tests/Examples/MultiSelectSingleItemRemoval.elm`
   - First test: `removes one selected item and emits expected deselection behavior`
4. `tests/Examples/SelectedValue.elm`
   - First test: `applies selected-value flag and renders selected option`
5. `tests/Examples/ChangeSelectAttributeChangesSelectedValueInMuchSelect.elm`
   - First test: `attributeChanged selected-value updates selection and reports value change`
6. `tests/Examples/EmptySelectedValueNoOptions.elm`
   - First test: `does not crash and keeps no selection when selected-value is empty with no options`
7. `tests/Examples/EmptySelectedValueEmptySelectInput.elm`
   - First test: `clears selected state when selected-value becomes empty string`
8. `tests/Examples/AllowCustomOptions.elm`
   - First test: `allows unknown typed value when allow-custom-options is enabled`
9. `tests/Examples/AllowCustomOptionsWithMinimumSearchStringLength.elm`
   - First test: `blocks custom option creation until minimum search length is reached`
10. `tests/Examples/EventsOnlyMode.elm`
    - First test: `suppresses internal value rendering while still emitting events`
11. `tests/Examples/LoadingIndicator.elm`
    - First test: `shows loading indicator when loading flag is true`
12. `tests/Examples/OverrideLoadingIndicator.elm`
    - First test: `renders custom loading slot content instead of default loading text`
13. `tests/Examples/DisabledMuchSelect.elm`
    - First test: `prevents interaction when component is disabled`
14. `tests/Examples/DisabledOptions.elm`
    - First test: `prevents selecting disabled options`
15. `tests/Examples/Placeholder.elm`
    - First test: `renders placeholder when no selection exists`
16. `tests/Examples/MinimumSearchStringLength.elm`
    - First test: `does not show filtered results before minimum length threshold`
17. `tests/Examples/MaxDropdownItems.elm`
    - First test: `limits visible dropdown options to max-dropdown-items`
18. `tests/Examples/MaxNumberOfDropdownItems.elm`
    - First test: `caps dropdown rendering using max-number-of-dropdown-items setting`
19. `tests/Examples/MaxNumberOfDropdownItemsBigList.elm`
    - First test: `keeps dropdown bounded with a large option set`
20. `tests/Examples/MoveSelectedItemToTop.elm`
    - First test: `reorders selected option to top when selected-item-stays-in-place is false`
21. `tests/Examples/OutputStyleDatalist.elm`
    - First test: `renders datalist output style class and expected datalist markup`
22. `tests/Examples/OutputStyleDatalistMultiSelect.elm`
    - First test: `renders datalist multi-select output with expected selected values`
23. `tests/Examples/OutputStyleDatalistMultiSelectWithSelectedValues.elm`
    - First test: `hydrates multi selected values in datalist output style`
24. `tests/Examples/OutputStyleDatalistMultiSelectWithSelectedValuesJsonValueSelected.elm`
    - First test: `decodes JSON selected-value and marks options selected in datalist mode`
25. `tests/Examples/SwitchBetweenDatalistAndCustomHtml.elm`
    - First test: `switching output-style triggers option refresh effect and new output-style class`
26. `tests/Examples/ShowDropdownFooter.elm`
    - First test: `renders dropdown footer when show-dropdown-footer is true`
27. `tests/Examples/HiddenInputSlot.elm`
    - First test: `writes selected value to hidden input slot`
28. `tests/Examples/HiddenInputJsonEncodingSlot.elm`
    - First test: `writes JSON-encoded selected value to hidden input slot`
29. `tests/Examples/SearchKeyboardEvents.elm`
    - First test: `typing emits inputKeyUp with typed string`
30. `tests/Examples/SingleSelectValueChangedEvent.elm`
    - First test: `selection emits valueChangedSingleSelect`
31. `tests/Examples/MultiSelectValueChangedEvent.elm`
    - First test: `selection emits valueChangedMultiSelect`
32. `tests/Examples/DatalistSingleSelectValueChangedEvent.elm`
    - First test: `datalist single-select emits valueChangedSingleSelect`
33. `tests/Examples/DatalistMultiSelectValueChangedEvent.elm`
    - First test: `datalist multi-select emits valueChangedMultiSelect`
34. `tests/Examples/SingleSelectOptionSelectedEvent.elm`
    - First test: `selecting option emits optionSelected payload`
35. `tests/Examples/SingleSelectOptionDeselectedEvent.elm`
    - First test: `deselecting option emits optionDeselected payload`
36. `tests/Examples/MultiSelectOptionDeselectedEvent.elm`
    - First test: `deselecting one selected option emits optionDeselected payload`
37. `tests/Examples/MultiSelectValueCleared.elm`
    - First test: `clear action emits valueCleared and deselection events`
38. `tests/Examples/ReadyEvent.elm`
    - First test: `component init emits ready event exactly once`

## Phase 2 — Options lifecycle, selection edge cases, and state transitions

Focus: option updates, empty states, ordering, value formats, and mode switches.

1. `tests/Examples/AddOptionToAMuchSelect.elm`
   - First test: `addOptions port appends new option`
2. `tests/Examples/AddOptionsIncludingTheSelectedValue.elm`
   - First test: `newly added option matching selected-value is marked selected`
3. `tests/Examples/AddOptionsNotIncludingTheSelectedValue.elm`
   - First test: `selected value remains synthetic/selected when options update excludes it`
4. `tests/Examples/AddOptionsToAMultiSelectNotIncludingTheSelectedValue.elm`
   - First test: `multi selected values stay selected when update payload omits selected entries`
5. `tests/Examples/AddPossibleDuplicateOptionToAMuchSelect.elm`
   - First test: `duplicate option value is not added twice`
6. `tests/Examples/RemoveAnOptionFromAMuchSelect.elm`
   - First test: `remove option updates option list and selected state`
7. `tests/Examples/SelectAndDeselectOptionFromAMuchSelect.elm`
   - First test: `programmatic select then deselect updates value and emits events`
8. `tests/Examples/SelectMultipleOptionsInAMultiMuchSelect.elm`
   - First test: `programmatic multi selection marks all requested values selected`
9. `tests/Examples/UpdateOptionsAddOptionsToAMuchSelect.elm`
   - First test: `update-options merges added options into existing list`
10. `tests/Examples/UpdateOptionsAddOptionsToAnEmptyMuchSelect.elm`
    - First test: `update-options populates empty list`
11. `tests/Examples/ChangeTheOptionsWithTheDom.elm`
    - First test: `light DOM option changes are re-read and reflected in model`
12. `tests/Examples/AnInitialValue.elm`
    - First test: `initial value with populated options is selected at startup`
13. `tests/Examples/AnInitialValueWithNoOptions.elm`
    - First test: `initial value with empty options creates/selects synthetic option`
14. `tests/Examples/NoValueNoOptions.elm`
    - First test: `shows no options empty state when list and value are empty`
15. `tests/Examples/EmptyOption.elm`
    - First test: `supports selecting empty-string option value`
16. `tests/Examples/OneEmptyOptionWithALabel.elm`
    - First test: `renders label for empty value option and preserves empty value semantics`
17. `tests/Examples/EmptyOptionWithLabelAndOtherOptions.elm`
    - First test: `empty option with label coexists with standard options`
18. `tests/Examples/EmptyOptionWithLabelAndOtherOptions2.elm`
    - First test: `second empty-option variant maintains label/value mapping`
19. `tests/Examples/EmptyOptionsMultiSelect.elm`
    - First test: `multi-select with no options shows generic empty dropdown message`
20. `tests/Examples/MultiSelectAllOptionsSelected.elm`
    - First test: `shows all-options-selected message when every option is selected`
21. `tests/Examples/MultiSelectBlurOrUnfocusedValueChange.elm`
    - First test: `value change while blurred updates selection without focus-only assumptions`
22. `tests/Examples/SingleSelectBlurOrUnfocusedValueChange.elm`
    - First test: `single-select value change while unfocused still updates model/view`
23. `tests/Examples/SingleSelectJsonSeperatedValues.elm`
    - First test: `single-select parses JSON encoded selected-value`
24. `tests/Examples/MultiSelectCommaSeperatedValues.elm`
    - First test: `multi-select parses comma-separated selected-value`
25. `tests/Examples/MultiSelectJsonSeperatedValues.elm`
    - First test: `multi-select parses JSON encoded selected-value`
26. `tests/Examples/SwitchBetweenMultiSelectAndSingleSelect.elm`
    - First test: `switching selection mode recalculates selected values correctly`
27. `tests/Examples/DefaultOptionGroupOrdering.elm`
    - First test: `option groups render in default ordering`
28. `tests/Examples/OptionGroups.elm`
    - First test: `renders grouped options with group labels`
29. `tests/Examples/OptionsWithDescriptions.elm`
    - First test: `renders option descriptions in dropdown`
30. `tests/Examples/CustomElementOptions.elm`
    - First test: `custom element-provided options are decoded and displayed`
31. `tests/Examples/LabelsAndValues.elm`
    - First test: `uses label for display and value for emitted payload`
32. `tests/Examples/NotJustEnglishOptions.elm`
    - First test: `unicode option labels/values render and search correctly`

## Phase 3 — Slots, visual customization, async/remote, and advanced validation

Focus: customization surfaces, async option hydration, remote data, and transform/validate pipeline.

1. `tests/Examples/AddAndRemoveButtonSlots.elm`
   - First test: `custom add/remove button slots render and trigger expected actions`
2. `tests/Examples/DefaultClearButton.elm`
   - First test: `default clear button is visible when selection exists`
3. `tests/Examples/OverrideTheClearButton.elm`
   - First test: `custom clear button slot replaces default clear control`
4. `tests/Examples/OverrideTheClearButtonWithAnSvg.elm`
   - First test: `SVG clear button slot renders and clears selection`
5. `tests/Examples/OverrideNoOptionsSlot.elm`
   - First test: `custom no-options slot content appears for empty option list`
6. `tests/Examples/OverrideNoFilteredOptionsSlot.elm`
   - First test: `custom no-filtered-options content appears when search yields no matches`
7. `tests/Examples/StylingDropdownOptionsWithPart.elm`
   - First test: `dropdown options expose expected part hooks/class markers for styling`
8. `tests/Examples/FocusOnDemand.elm`
   - First test: `focusInput effect/port focuses component on demand`
9. `tests/Examples/SelectedOptionWithAsyncOptions.elm`
   - First test: `selected value remains selected after async options arrive`
10. `tests/Examples/SelectedOptionWithAsyncOptionsSmall.elm`
    - First test: `small async option payload still preserves selected option`
11. `tests/Examples/SelectedOptionWithMultiSelectWithAsyncOptionsSmall.elm`
    - First test: `multi-select selected values are preserved after async hydration`
12. `tests/Examples/RemoteApiExample.elm`
    - First test: `remote options response updates list and supports selection`
13. `tests/Examples/TenThousandOptions.elm`
    - First test: `large option list initializes and filters without incorrect truncation`
14. `tests/Examples/CustomOptionLabelText.elm`
    - First test: `custom option label text is rendered for synthetic/custom options`
15. `tests/Examples/CustomOptionLabelText2.elm`
    - First test: `second label-text variant applies configured custom label`
16. `tests/Examples/CustomOptionLabelText3.elm`
    - First test: `third label-text variant preserves configured label semantics`
17. `tests/Examples/AddCustomOptions.elm`
    - First test: `new custom option can be created and selected`
18. `tests/Examples/AddCustomOptions2.elm`
    - First test: `second custom-option flow creates option with expected label/value`
19. `tests/Examples/CustomOptionsThatPersist.elm`
    - First test: `custom option persists across subsequent filtering/updates`
20. `tests/Examples/ValidationAndTransformationSlotSingleDatalist.elm`
    - First test: `single datalist applies transform before validation`
21. `tests/Examples/ValidationAndTransformationSlotSingleCustomHtml.elm`
    - First test: `single custom-html applies transform/validate pipeline`
22. `tests/Examples/ValidationAndTransformationSlotMultiDatalist.elm`
    - First test: `multi datalist validates each selected value through pipeline`
23. `tests/Examples/ValidationAndTransformationSlotMultiCustomHtml.elm`
    - First test: `multi custom-html transform/validate flow updates validity state`
24. `tests/Examples/ValidationAndTransformationSlotCustomValidation.elm`
    - First test: `custom validation request/response controls selected option validity`

## Implementation order inside each phase

For each suite in phase order:

1. Create module and minimal `flags` fixture mirroring the example.
2. Add the single **first test** listed above and get green.
3. Expand to 2-5 tests:
   - render state
   - interaction
   - effect/port assertion
4. Extract shared fixtures/helpers only after 3+ suites duplicate logic.

## Definition of done

- [ ] `tests/Examples/` contains 94 suites (one per example)
- [ ] Each suite has at least one passing `elm-program-test` test
- [ ] Each suite expanded to 2-5 focused tests
- [ ] Existing non-example unit/integration suites still pass
- [ ] CI runs include the new suites

## Suggested tracking file format

Add a progress checklist (can be this file or a separate tracking file):

- [ ] Phase 1 complete
- [ ] Phase 2 complete
- [ ] Phase 3 complete
- [ ] 94/94 example suites implemented

## Current status

- [x] Created `tests/Examples/` namespace
- [x] Scaffolded all 38 Phase 1 modules with compiling placeholder `suite` tests
- [ ] Replace placeholder tests with real program-test assertions for each Phase 1 example
- [x] Implemented first real program-test assertions for 20 Phase 1 suites (`SimpleExample`, `MultiSelect`, `SelectedValue`, `OutputStyleDatalist`, `SearchKeyboardEvents`, `Placeholder`, `DisabledMuchSelect`, `DisabledOptions`, `ShowDropdownFooter`, `ReadyEvent`, `AllowCustomOptions`, `MinimumSearchStringLength`, `MaxDropdownItems`, `OutputStyleDatalistMultiSelect`, `SingleSelectValueChangedEvent`, `MultiSelectValueChangedEvent`, `DatalistSingleSelectValueChangedEvent`, `DatalistMultiSelectValueChangedEvent`, `SingleSelectOptionSelectedEvent`, `SingleSelectOptionDeselectedEvent`)
