# Example Web Test Coverage Plan (JavaScript-first)

## Goal

Add robust `web-test-runner` coverage for **all `examples/*.html` behaviors**, with emphasis on the web component JavaScript layer (API, attributes, events, DOM/slot sync, worker integration), not Elm internals.

This plan intentionally differs from the Elm program-test effort:

- **Primary target:** runtime behavior of `src/much-select.js` and browser integration.
- **Secondary target:** confidence that each documented example behavior works in real DOM usage.

---

## Current baseline (as of now)

- Example files: **94** (`examples/*.html`)
- Web test files: **23** (`tests/**/*.test.html`)
- Existing web tests are mostly feature/attribute-oriented and already include several high-value API/event assertions.

Current web test counts by suite (approx.):

- `tests/Attributes/*`: 3–8 tests each
- `tests/Dropdown/*`: 3–5 tests each
- `tests/Events/*`: 4 tests
- `tests/Option/*`: 2–3 tests
- `tests/Slots/*`: 3 tests each

---

## Definition of “already covered enough” (skip criteria)

An example may be skipped **only if all are true**:

1. Its behavior is already covered by existing web tests with at least **4 focused assertions**.
2. Coverage is JS-facing (events, attributes, methods, slots, DOM sync), not only rendered text checks.
3. The tracker maps that example to specific existing test cases.

If any of these are missing, add a dedicated example test file or extend an existing one.

---

## Test design principles (JS-focused)

For each example, prefer these assertion types:

1. **Public API behavior**
   - `addOption`, `addOptions`, `updateOptions`, `selectOption`, `deselectOption`, `getAllOptions`, `selectedValue`.
2. **Attribute ↔ behavior sync**
   - changing attributes updates behavior; removing attributes resets behavior.
3. **Custom events and detail payloads**
   - `optionSelected`, `optionDeselected`, `valueChanged`, `invalidValueChange`, `customValueSelected`, `muchSelectReady`, etc.
4. **Slot integration**
   - `select-input`, `hidden-value-input`, transformation/validation slots, custom validation result slot.
5. **DOM/observer behavior**
   - light DOM changes reflected in options and selected value.
6. **Output mode behavior**
   - `customHtml` vs `datalist` differences in interaction and emitted results.

Avoid overfitting tests to Elm implementation details or private internals.

---

## Proposed structure

- Keep existing feature suites.
- Add example-focused suites under:
  - `tests/ExamplesWeb/<example-slug>.test.html`

Each new example file should usually contain **3–6 tests**:

- 1 render/initialization behavior
- 1 interaction behavior
- 1 event/API contract behavior
- + optional edge case(s)

---

## Shared helper work (do this first)

Create `tests/helpers/example-test-utils.js` with:

- `makeExampleFixture(attrs, slottedHtml)`
- `waitForReady(el)`
- `listenOnce(el, eventName)`
- `getShadow(el, selector)` and `getAllShadow(el, selector)`
- `typeSearch(el, value)` (for customHtml and datalist variants)

This keeps each example suite concise and consistent.

---

## Phased rollout

## Phase 0 — Inventory + mapping (required)

Build a tracker mapping each of the 94 examples to one of:

- `CoveredByExistingSuite`
- `NeedsDedicatedSuite`
- `NeedsExistingSuiteExpansion`

Output file: `docs/example-web-test-tracker.md`

No implementation guesses; every row must reference concrete test file(s).

## Phase 1 — Highest-risk JS integration examples

Prioritize examples that exercise JS-heavy integration points:

- `change-the-options-with-the-dom`
- `add-option-to-a-much-select`
- `remove-an-option-from-a-much-select`
- `add-options-*`
- `custom-options-that-persist`
- `ready-event`
- `focus-on-demand`
- `remote-api-example`
- `selected-option-with-async-options*`
- validation/transformation slot examples

Target: 20–30 examples covered/expanded.

## Phase 2 — Event and encoding contracts

Focus on examples emitting/depending on event payload contracts:

- `*-value-changed-event`
- `*-option-selected-event`
- `*-option-deselected-event`
- `*-value-cleared`
- `*-blur-or-unfocused-value-change`
- `*-json-seperated-values`
- `*-comma-seperated-values`
- hidden-input encoding examples

Target: 20–25 more examples.

## Phase 3 — Slots, styling, and view customization

Focus examples where JS integration with slots/DOM structure matters:

- clear button overrides
- loading/no-options/no-filtered-options slot overrides
- add/remove button slots
- custom element options
- styling with `part`
- switch mode/output-style examples

Target: 20+ examples.

## Phase 4 — Long tail + gap closure

Finish remaining examples and close tracker gaps.

- Ensure every example is either dedicated-tested or explicitly mapped to sufficient existing tests.
- Add missing edge tests where behavior is nuanced.

---

## Minimum per-example assertions

For each dedicated example suite:

- **At least 3 tests** for simple examples.
- **At least 5 tests** for complex examples (async, custom validation, or mode switching).

Complex examples include:

- remote/async options
- transformation+validation slot
- multi/single mode switching
- datalist/customHtml switching

---

## Validation workflow

Use devbox tasks:

- `devbox run web-test-runner`
- `devbox run test`
- `devbox run review`
- `devbox run biome-check`

Run web tests after each batch; keep batches small enough to debug quickly.

---

## Suggested tracker format

`docs/example-web-test-tracker.md` table:

| example slug | status | existing tests | planned tests | skip reason |
|---|---|---|---|---|
| allow-custom-options | CoveredByExistingSuite | `tests/Attributes/allow-custom-options.test.html` | +1 event payload check (optional) | already >=4 JS tests |
| custom-options-that-persist | NeedsDedicatedSuite | — | `tests/ExamplesWeb/custom-options-that-persist.test.html` (5 tests) | localStorage + custom event flow |

Statuses:

- `CoveredByExistingSuite`
- `NeedsDedicatedSuite`
- `NeedsExistingSuiteExpansion`
- `Done`

---

## Initial likely skip candidates (verify in tracker)

These are likely already close to sufficient coverage and may be skip candidates after mapping:

- allow-custom-options
- disabled
- events-only
- loading
- max-dropdown-items
- multi-select
- multi-select-single-item-removal
- option-sorting
- output-style
- placeholder
- search-string-minimum-length
- selected-value
- selected-value-encoding
- show-dropdown-footer
- hidden-input-slot

Note: “likely” means no automatic skip until tracker evidence is recorded.

---

## Definition of done

1. Every `examples/*.html` row is `Done` or `CoveredByExistingSuite` with explicit evidence.
2. Complex examples have 5+ JS-focused tests.
3. `devbox run web-test-runner` passes.
4. Existing Elm tests remain green (`devbox run test`).
5. Lint/review/biome checks pass (`devbox run review`, `devbox run biome-check`).
