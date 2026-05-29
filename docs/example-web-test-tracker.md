# Example Web Test Tracker

Originally generated during Phase 0 inventory from `examples/*.html` and existing `tests/**/*.test.html`.


## Summary (final status)

- Total examples: **94**
- `CoveredByExistingSuite`: **0**
- `NeedsExistingSuiteExpansion`: **0**
- `NeedsDedicatedSuite`: **0**
- `Done`: **94**

> Note: Tracker is finalized for this rollout. Every example row is marked `Done` with explicit test-suite evidence.

| example slug | status | existing tests | planned tests | skip reason |
|---|---|---|---|---|
| `add-and-remove-button-slots` | `Done` | `tests/ExamplesWeb/add-and-remove-button-slots.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `add-custom-options` | `Done` | `tests/ExamplesWeb/add-custom-options.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `add-custom-options-2` | `Done` | `tests/ExamplesWeb/add-custom-options-2.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `add-option-to-a-much-select` | `Done` | `tests/ExamplesWeb/add-option-to-a-much-select.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `add-options-including-the-selected-value` | `Done` | `tests/ExamplesWeb/add-options-including-the-selected-value.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `add-options-not-including-the-selected-value` | `Done` | `tests/ExamplesWeb/add-options-not-including-the-selected-value.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `add-options-to-a-multi-select-not-including-the-selected-value` | `Done` | `tests/ExamplesWeb/add-options-to-a-multi-select-not-including-the-selected-value.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `add-possible-duplicate-option-to-a-much-select` | `Done` | `tests/ExamplesWeb/add-possible-duplicate-option-to-a-much-select.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `allow-custom-options` | `Done` | `tests/Attributes/allow-custom-options.test.html` | Validated existing attribute suite coverage; no expansion required | Existing suite already provides robust JS-facing attribute/behavior assertions |
| `allow-custom-options-with-minimum-search-string-length` | `Done` | `tests/Attributes/search-string-minimum-length.test.html` | Expanded mapped attribute suite with combined allow-custom-options + minimum-length contract assertions | Phase 2 batch complete |
| `an-initial-value` | `Done` | `tests/Attributes/selected-value.test.html` | Expanded mapped selected-value suite with initial selected-value contract assertions | Phase 2 batch complete |
| `an-initial-value-with-no-options` | `Done` | `tests/Attributes/selected-value.test.html` | Expanded mapped selected-value suite with no-options initial value contract assertions | Phase 2 batch complete |
| `change-select-attribute-changes-selected-value-in-much-select` | `Done` | `tests/Attributes/selected-value.test.html` | Expanded mapped selected-value suite with select DOM selected-attribute sync assertions | Phase 2 batch complete |
| `change-the-options-with-the-dom` | `Done` | `tests/ExamplesWeb/change-the-options-with-the-dom.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `custom-element-options` | `Done` | `tests/Slots/select-input-slot.test.html` | Expanded mapped slot suite with much-select-option element contract assertions | Phase 2 batch complete |
| `custom-option-label-text` | `Done` | `tests/ExamplesWeb/custom-option-label-text.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `custom-option-label-text-2` | `Done` | `tests/ExamplesWeb/custom-option-label-text-2.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `custom-option-label-text-3` | `Done` | `tests/ExamplesWeb/custom-option-label-text-3.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `custom-options-that-persist` | `Done` | `tests/ExamplesWeb/custom-options-that-persist.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `datalist-multi-select-value-changed-event` | `Done` | `tests/Events/selecting-options.test.html` | Expanded mapped event suite with datalist multi-select valueChanged contract assertions | Phase 2 batch complete |
| `datalist-single-select-value-changed-event` | `Done` | `tests/Events/selecting-options.test.html` | Expanded mapped event suite with datalist single-select valueChanged contract assertions | Phase 2 batch complete |
| `default-clear-button` | `Done` | `tests/ExamplesWeb/default-clear-button.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `default-option-group-ordering` | `Done` | `tests/Attributes/option-sorting.test.html` | Expanded mapped sorting suite with optgroup ordering/contents assertions | Phase 2 batch complete |
| `disabled-much-select` | `Done` | `tests/Attributes/disabled.test.html` | Validated existing attribute suite coverage; no expansion required | Existing suite already provides robust JS-facing disabled behavior assertions |
| `disabled-options` | `Done` | `tests/Attributes/disabled.test.html` | Expanded mapped disabled suite with disabled option selection-blocking assertions | Phase 2 batch complete |
| `empty-option` | `Done` | `tests/ExamplesWeb/empty-option.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `empty-option-with-label-and-other-options` | `Done` | `tests/ExamplesWeb/empty-option-with-label-and-other-options.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `empty-option-with-label-and-other-options-2` | `Done` | `tests/ExamplesWeb/empty-option-with-label-and-other-options-2.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `empty-options-multi-select` | `Done` | `tests/ExamplesWeb/empty-options-multi-select.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `empty-selected-value-empty-select-input` | `Done` | `tests/Attributes/selected-value.test.html` | Expanded mapped selected-value suite with empty selected-value + empty select-input assertions | Phase 2 batch complete |
| `empty-selected-value-no-options` | `Done` | `tests/Attributes/selected-value.test.html` | Expanded mapped selected-value suite with empty selected-value + no-options assertions | Phase 2 batch complete |
| `events-only-mode` | `Done` | `tests/Attributes/events-only.test.html` | Validated existing attribute suite coverage; no expansion required | Existing suite already provides robust JS-facing events-only assertions |
| `focus-on-demand` | `Done` | `tests/ExamplesWeb/focus-on-demand.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `hidden-input-json-encoding-slot` | `Done` | `tests/Slots/hidden-input-slot.test.html` | Expanded mapped hidden-input slot suite with JSON encoding mirror assertions | Phase 2 batch complete |
| `hidden-input-slot` | `Done` | `tests/Slots/hidden-input-slot.test.html` | Validated existing slot suite coverage; no expansion required | Existing suite already provides robust JS-facing hidden input sync assertions |
| `labels-and-values` | `Done` | `tests/Slots/select-input-slot.test.html` | Expanded mapped slot suite with label/value differentiation assertions | Phase 2 batch complete |
| `loading-indicator` | `Done` | `tests/Attributes/loading.test.html` | Validated existing attribute suite coverage; no expansion required | Existing suite already provides robust JS-facing loading assertions |
| `max-dropdown-items` | `Done` | `tests/Attributes/max-dropdown-items.test.html` | Validated existing attribute suite coverage; no expansion required | Existing suite already provides robust JS-facing max-dropdown-items assertions |
| `max-number-of-dropdown-items` | `Done` | `tests/Attributes/max-dropdown-items.test.html` | Expanded mapped max-dropdown-items suite with capped visible dropdown assertions | Phase 2 batch complete |
| `max-number-of-dropdown-items-big-list` | `Done` | `tests/Attributes/max-dropdown-items.test.html` | Expanded mapped max-dropdown-items suite with big-list cap assertions | Phase 2 batch complete |
| `minimum-search-string-length` | `Done` | `tests/Attributes/search-string-minimum-length.test.html` | Validated existing attribute suite coverage; no expansion required | Existing suite already provides robust JS-facing minimum length assertions |
| `move-selected-item-to-top` | `Done` | `tests/Attributes/selected-option-goes-to-top.test.html` | Expanded mapped selected-option-goes-to-top suite with selection contract assertions under move-to-top mode | Phase 2 batch complete |
| `multi-select` | `Done` | `tests/Attributes/muli-select.test.html` | Validated existing attribute suite coverage; no expansion required | Existing suite already provides robust JS-facing multi-select assertions |
| `multi-select-all-options-selected` | `Done` | `tests/Attributes/muli-select.test.html` | Expanded mapped attribute suite with all-options-selected assertions | Phase 2 batch complete |
| `multi-select-blur-or-unfocused-value-change` | `Done` | `tests/Attributes/muli-select.test.html` | Expanded mapped attribute suite with blurOrUnfocusedValueChanged assertions | Phase 2 batch complete |
| `multi-select-comma-seperated-values` | `Done` | `tests/Attributes/selected-value-encoding.test.html` | Expanded mapped encoding suite with comma-encoded multi-select contract assertions | Phase 2 batch complete |
| `multi-select-json-seperated-values` | `Done` | `tests/Attributes/selected-value-encoding.test.html` | Expanded mapped encoding suite with JSON-encoded multi-select contract assertions | Phase 2 batch complete |
| `multi-select-option-deselected-event` | `Done` | `tests/Events/selecting-options.test.html` | Expanded mapped event suite with multi-select optionDeselected contract assertions | Phase 2 batch complete |
| `multi-select-single-item-removal` | `Done` | `tests/Attributes/multi-select-single-item-removal.test.html`, `tests/Attributes/muli-select.test.html` | Validated existing attribute suite coverage; no expansion required | Existing suite already provides robust JS-facing single-item-removal assertions |
| `multi-select-value-changed-event` | `Done` | `tests/Events/selecting-options.test.html` | Expanded mapped event suite with multi-select valueChanged payload assertions | Phase 2 batch complete |
| `multi-select-value-cleared` | `Done` | `tests/Events/selecting-options.test.html` | Expanded mapped event suite with valueCleared + selectedValue reset assertions | Phase 2 batch complete |
| `no-value-no-options` | `Done` | `tests/ExamplesWeb/no-value-no-options.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `not-just-english-options` | `Done` | `tests/ExamplesWeb/not-just-english-options.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `one-empty-option-with-a-label` | `Done` | `tests/ExamplesWeb/one-empty-option-with-a-label.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `option-groups` | `Done` | `tests/Attributes/option-sorting.test.html`, `tests/Dropdown/dropdown-ordering.test.html` | Validated existing suite coverage; no expansion required | Existing suites already provide robust JS-facing option-group/sorting assertions |
| `options-with-descriptions` | `Done` | `tests/ExamplesWeb/options-with-descriptions.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `output-style-datalist` | `Done` | `tests/Attributes/output-style.test.html` | Validated existing attribute suite coverage; no expansion required | Existing suite already provides robust JS-facing output-style assertions |
| `output-style-datalist-multi-select` | `Done` | `tests/Attributes/output-style.test.html` | Expanded mapped output-style suite with datalist multi-select assertions | Phase 2 batch complete |
| `output-style-datalist-multi-select-with-selected-values` | `Done` | `tests/Attributes/output-style.test.html` | Expanded mapped output-style suite with comma selected-values assertions | Phase 2 batch complete |
| `output-style-datalist-multi-select-with-selected-values-json-value-selected` | `Done` | `tests/Attributes/output-style.test.html` | Expanded mapped output-style suite with JSON selected-values assertions | Phase 2 batch complete |
| `override-loading-indicator` | `Done` | `tests/Attributes/loading.test.html` | Expanded mapped loading suite with loading-indicator slot/toggle assertions | Phase 2 batch complete |
| `override-no-filtered-options-slot` | `Done` | `tests/ExamplesWeb/override-no-filtered-options-slot.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `override-no-options-slot` | `Done` | `tests/ExamplesWeb/override-no-options-slot.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `override-the-clear-button` | `Done` | `tests/ExamplesWeb/override-the-clear-button.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `override-the-clear-button-with-an-svg` | `Done` | `tests/ExamplesWeb/override-the-clear-button-with-an-svg.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `placeholder` | `Done` | `tests/Attributes/placeholder.test.html` | Validated existing attribute suite coverage; no expansion required | Existing suite already provides robust JS-facing placeholder assertions |
| `ready-event` | `Done` | `tests/ExamplesWeb/ready-event.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `remote-api-example` | `Done` | `tests/ExamplesWeb/remote-api-example.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `remove-an-option-from-a-much-select` | `Done` | `tests/ExamplesWeb/remove-an-option-from-a-much-select.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `search-keyboard-events` | `Done` | `tests/Dropdown/dropdown-highlighted-option.test.html` | Expanded mapped dropdown keyboard suite with inputKeyUp/inputKeyUpDebounced assertions | Phase 2 batch complete |
| `select-and-deselect-option-from-a-much-select` | `Done` | `tests/ExamplesWeb/select-and-deselect-option-from-a-much-select.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `select-multiple-options-in-a-multi-much-select` | `Done` | `tests/ExamplesWeb/select-multiple-options-in-a-multi-much-select.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `selected-option-with-async-options` | `Done` | `tests/ExamplesWeb/selected-option-with-async-options.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `selected-option-with-async-options-small` | `Done` | `tests/ExamplesWeb/selected-option-with-async-options-small.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `selected-option-with-multi-select-with-async-options-small` | `Done` | `tests/ExamplesWeb/selected-option-with-multi-select-with-async-options-small.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `selected-value` | `Done` | `tests/Attributes/selected-value.test.html`, `tests/Option/initial-options.test.html` | Validated existing suite coverage; no expansion required | Existing suites already provide robust JS-facing selected-value assertions |
| `show-dropdown-footer` | `Done` | `tests/Attributes/show-dropdown-footer.test.html` | Validated existing attribute suite coverage; no expansion required | Existing suite already provides robust JS-facing dropdown-footer assertions |
| `simple-example` | `Done` | `tests/ExamplesWeb/simple-example.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `single-select-blur-or-unfocused-value-change` | `Done` | `tests/ExamplesWeb/single-select-blur-or-unfocused-value-change.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `single-select-json-seperated-values` | `Done` | `tests/Attributes/selected-value-encoding.test.html` | Expanded mapped encoding suite with single-select JSON contract assertions | Phase 2 batch complete |
| `single-select-option-deselected-event` | `Done` | `tests/Events/selecting-options.test.html` | Expanded mapped event suite with single-select optionDeselected contract assertions | Phase 2 batch complete |
| `single-select-option-selected-event` | `Done` | `tests/Events/selecting-options.test.html` | Expanded mapped event suite with single-select optionSelected contract assertions | Phase 2 batch complete |
| `single-select-value-changed-event` | `Done` | `tests/Events/selecting-options.test.html` | Expanded mapped event suite with single-select valueChanged payload assertions | Phase 2 batch complete |
| `styling-dropdown-options-with-part` | `Done` | `tests/ExamplesWeb/styling-dropdown-options-with-part.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `switch-between-datalist-and-custom-html` | `Done` | `tests/Attributes/output-style.test.html` | Expanded mapped output-style suite with style-switch + selection persistence assertions | Phase 2 batch complete |
| `switch-between-multi-select-and-single-select` | `Done` | `tests/ExamplesWeb/switch-between-multi-select-and-single-select.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `ten-thousand-options` | `Done` | `tests/ExamplesWeb/ten-thousand-options.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `update-options-add-options-to-a-much-select` | `Done` | `tests/ExamplesWeb/update-options-add-options-to-a-much-select.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `update-options-add-options-to-an-empty-much-select` | `Done` | `tests/ExamplesWeb/update-options-add-options-to-an-empty-much-select.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `validation-and-transformation-slot-custom-validation` | `Done` | `tests/ExamplesWeb/validation-and-transformation-slot-custom-validation.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `validation-and-transformation-slot-multi-custom-html` | `Done` | `tests/ExamplesWeb/validation-and-transformation-slot-multi-custom-html.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `validation-and-transformation-slot-multi-datalist` | `Done` | `tests/ExamplesWeb/validation-and-transformation-slot-multi-datalist.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `validation-and-transformation-slot-single-custom-html` | `Done` | `tests/ExamplesWeb/validation-and-transformation-slot-single-custom-html.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
| `validation-and-transformation-slot-single-datalist` | `Done` | `tests/ExamplesWeb/validation-and-transformation-slot-single-datalist.test.html` | Implemented dedicated JS-focused example suite | Phase 1 batch complete |
