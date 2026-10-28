---
sessionId: session-261028-103757-mham
---

# Requirements

### Goal
Make the control’s visual styling configurable through CSS custom properties, preserving its current appearance when no overrides are supplied.

### Scope
- Cover built-in styles in `src/much-select.js` and control styling in `site/much-select-example.css`.
- Expose colors, backgrounds, dimensions, spacing, border appearance, typography, shadows, opacity, and animation timing.
- Include selected pills, removal separators, loading indicators, dropdown options/groups/messages/footer, error messages, and disabled/hover/focus/highlight states.
- Keep structural rules such as display, flex behavior, visibility, cursor behavior, positioning modes, and animation keyframes fixed. Visual offsets and stacking order may be configurable.
- Exclude surrounding website layout, palette definitions in `site/demo-styles.css`, and consumer-provided slotted content.

### Compatibility
Existing custom-property names, example themes, `::part()` customization, disabled behavior, and programmatic APIs remain supported. Overrides must work on individual hosts or through inheritance and update without recreating the component.

# Technical Design

### Existing Pattern
`MuchSelect.styleTag` in `src/much-select.js` supplies shadow-root defaults. The example subclass appends `site/much-select-example.css`, which already uses `--much-select-*` and `--much-select-example-*` properties. Extend these layers in place; do not introduce a theme engine or change stylesheet loading.

### Variable Contract
- Use semantic, component-specific `--much-select-*` names rather than palette names or generic size scales.
- Reuse existing properties wherever their meaning matches, including `--much-select-border-color`, `--much-select-height`, option-state colors, and error styling.
- Preserve existing `--much-select-example-*` hooks; use them as compatibility fallbacks when adding shared component-level hooks.
- Supply defaults at each declaration using `var(--name, current-value)`, not public property assignments on `:host`, so ancestor values continue to inherit.
- Preserve distinct built-in and example fallback values. Sharing a property does not require making their default appearances identical.
- Use separate hooks for independently styled states and subcomponents; use shorthand properties for cohesive spacing/shadow values, and individual border width/style/color hooks where independent control is useful.

Representative additions:
```css
min-height: var(--much-select-min-height, 40px);
opacity: var(--much-select-disabled-opacity, 0.65);
max-height: var(--much-select-dropdown-max-height, 300px);
border-radius: var(--much-select-selected-value-border-radius, 40px);
```
The complete property inventory will record each selector/declaration, property name, fallback, and applicable style layer. Remaining literals must be either documented defaults or intentional structural constants.

### Dimensions and Cascade
`updateDimensions()` currently clamps measured sizes using `_minimumWidth` (200) and `_minimumHeight` (20). Reconcile these safeguards with CSS-controlled minima so smaller valid overrides are not silently defeated; retain measured dropdown alignment and existing default geometry. Keep Elm’s measured dropdown positioning intact rather than replacing runtime measurements with static variables.

The example stylesheet must consume the same applicable hooks as built-in styles so its later declarations do not mask consumer overrides. Retain its existing disabled cursor rules and state-selector precedence.

### Files
- Modify `src/much-select.js`: variable-backed built-in styling and any necessary minimum-size measurement adjustment.
- Modify `site/much-select-example.css`: variable-backed remaining visual declarations, with existing hooks preserved.
- Modify `README.md`: grouped property reference with defaults for both layers, host/inherited override examples, and scope limitations.
- Add `tests/Styles/css-variables.test.html`: plain-library computed-style and sizing coverage.
- Extend `tests/ExamplesWeb/encapsulated-styles.test.html`: shared-stylesheet overrides and compatibility coverage.

No changes to generated bundles by hand.

# Testing

### Browser Validation
Follow the existing `fixture`, `oneEvent`, `waitUntil`, and computed-style patterns in `tests/ExamplesWeb/encapsulated-styles.test.html`.

- Assert representative current default values separately for plain and example components.
- Exercise all newly exposed properties through grouped/table-driven computed-style checks where practical, including pseudo-elements.
- Verify inherited values, per-instance isolation, live updates, and removal restoring defaults.
- Cover colors, typography, spacing, borders, dimensions, opacity, and spinner timing across normal and state-specific selectors.
- Check disabled pills/casing retain the default cursor and enabled controls retain their current interactions.
- Test smaller/larger minimum dimensions, multi-line pills, dropdown alignment, and existing measured/max-item dropdown constraints.
- Preserve existing example-theme, light/dark, and legacy-variable regressions.

### Commands
Run `devbox run web-test-runner` for the build and browser suite. Run `devbox run test` if dimension handling or Elm-related behavior is affected. No tests are executed during planning.

# Delivery Steps

### ✓ Step 1: Expose built-in control styling variables
Plain library instances support visual overrides while retaining their current defaults.
- Inventory visual declarations in `MuchSelect.styleTag` and assign reusable semantic property names.
- Replace hard-coded visual values in `src/much-select.js` with variable fallbacks, including states, pills, loading indicators, and dropdown styling.
- Reconcile minimum-size safeguards in `updateDimensions()` with CSS-controlled sizing without changing measured dropdown positioning.
- Add `tests/Styles/css-variables.test.html` coverage for defaults, overrides, inheritance, live updates, and size/alignment behavior.

### ✓ Step 2: Extend shared example styling without breaking existing themes
Example controls honor the variable API even when their later stylesheet overrides built-in declarations.
- Refactor remaining visual literals in `site/much-select-example.css` using the agreed property inventory.
- Preserve existing example-specific properties as supported compatibility hooks and retain each layer’s defaults.
- Extend `tests/ExamplesWeb/encapsulated-styles.test.html` for sizing, state-specific styling, legacy hooks, and disabled cursor regressions.
- Run `devbox run web-test-runner` and resolve regressions in existing theme and interaction tests.

### ✓ Step 3: Document the complete styling contract
Consumers have an accurate reference for configuring both plain and example controls.
- Expand `README.md` with grouped property names, affected elements/states, and built-in versus example defaults.
- Include host-level and inherited override examples plus dynamic-update behavior.
- Audit both stylesheets against the inventory to ensure remaining fixed values are intentional structural constants or documented fallbacks.
- Complete browser validation and run `devbox run test` when dimension-related changes warrant it.