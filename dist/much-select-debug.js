// noinspection ES6CheckImport
import { Elm } from "./elm-main-debug.js";

import asciiFold from "./ascii-fold.js";

const buildOptionsFromSelectElement = (selectElement) => {
  const options = [];
  const optionElements = selectElement.querySelectorAll("option");
  optionElements.forEach((optionElement, optionIndex) => {
    let value;
    if (optionElement.hasAttribute("value")) {
      value = optionElement.getAttribute("value");
    } else {
      value = optionElement.innerText;
    }
    const option = { value };
    option.label = optionElement.innerText;
    option.labelClean = asciiFold(optionElement.innerText);
    option.index = optionIndex;
    if (optionElement.hasAttribute("selected")) {
      const optionSelectedValue = optionElement.getAttribute("selected");
      option.selected = optionSelectedValue !== "false";
    }
    if (optionElement.parentElement.tagName === "OPTGROUP") {
      option.group = optionElement.parentElement.getAttribute("label");
    }
    if (optionElement.dataset.description) {
      option.description = optionElement.dataset.description;
      option.descriptionClean = asciiFold(option.description);
    }
    option.disabled = optionElement.hasAttribute("disabled");
    options.push(option);
  });
  return options;
};

const notNullOrUndefined = (thing) => thing !== null && thing !== undefined;

const stringToOptionObject = (str) => ({
  value: str,
  label: str,
  labelClean: asciiFold(str),
});

const numberToOptionObject = (num) => ({
  value: `${num}`,
  label: `${num}`,
  labelClean: `${num}`,
});

const cleanUpOption = (option) => {
  if (typeof option === "string") {
    return stringToOptionObject(option);
  }
  if (typeof option === "number") {
    return numberToOptionObject(option);
  }
  if (typeof option === "object") {
    const optionMap = new Map();
    if (notNullOrUndefined(option.value)) {
      optionMap.set("value", `${option.value}`);
    }

    if (notNullOrUndefined(option.label)) {
      optionMap.set("label", `${option.label}`);
    }

    if (notNullOrUndefined(option.description)) {
      optionMap.set("description", option.description);
    }

    if (notNullOrUndefined(option.disabled)) {
      optionMap.set("disabled", !!option.disabled);
    }

    if (notNullOrUndefined(option.index)) {
      if (typeof option.index === "number") {
        optionMap.set("index", Math.floor(option.index));
      } else {
        throw new TypeError("option index in not a valid value");
      }
    }

    if (optionMap.has("value") && !optionMap.has("label")) {
      return {
        label: optionMap.get("value"),
        labelClean: asciiFold(optionMap.get("value")),
        value: optionMap.get("value"),
        description: optionMap.get("description"),
        descriptionClean: asciiFold(optionMap.get("description")),
        disabled: optionMap.get("disabled"),
        index: optionMap.get("index"),
      };
    }
    if (optionMap.has("label") && !optionMap.has("value")) {
      return {
        label: optionMap.get("label"),
        labelClean: asciiFold(optionMap.get("label")),
        value: optionMap.get("label"),
        description: optionMap.get("description"),
        descriptionClean: asciiFold(optionMap.get("description")),
        disabled: optionMap.get("disabled"),
        index: optionMap.get("index"),
      };
    }
    return {
      label: optionMap.get("label"),
      labelClean: asciiFold(optionMap.get("label")),
      value: optionMap.get("value"),
      description: optionMap.get("description"),
      descriptionClean: asciiFold(optionMap.get("description")),
      disabled: optionMap.get("disabled"),
      index: optionMap.get("index"),
    };
  }

  throw new TypeError("Invalid option");
};

const cleanUpOptions = (options) => options.map(cleanUpOption);

const makeDebouncedFunc = (func, timeout = 500) => {
  let timer;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => {
      func.apply(this, args);
    }, timeout);
  };
};

// adapted from https://github.com/thread/elm-web-components

class MuchSelect extends HTMLElement {
  constructor() {
    super();

    /**
     * Used in the CSS and elsewhere to determine what the
     *  minimum width should be.
     * TODO Perhaps this should be a property or attribute.
     * @type {number}
     * @private
     */
    this._minimumWidth = 200;

    /**
     * @type {string|null}
     * @private
     */
    this._selectedValue = null;

    /**
     * This is controlled by the events-only attribute.
     * If this is true, no changes to the light DOM should
     * happen automatically.
     *
     * @type {boolean}
     * @private
     */
    this._eventsOnlyMode = false;

    /**
     * @type {string|null}
     * @private
     */
    this._placeholder = null;

    /**
     * @type {boolean}
     * @private
     */
    this._disabled = false;

    /**
     * @type {boolean}
     * @private
     */
    this._loading = false;

    /**
     * @type {number}
     * @private
     */
    this._maxDropdownItems = 10000;

    /**
     * @type {boolean}
     * @private
     */
    this._isInMulitSelectMode = false;

    /**
     * @type {boolean}
     * @private
     */
    this._allowCustomOptions = false;

    /**
     * @type {boolean}
     * @private
     */
    this._selectedItemStaysInPlace = true;

    /**
     * Depending on what you've got going on, you may want different
     * schemes for encoding the selected values. There are some choices.
     *  - comma (default) - just make the values comma separated (problematic if you have commas in your values)
     *  - json
     * @type {string}
     * @private
     */
    this._selectedValueEncoding = "comma";

    /**
     * @type {null|object}
     * @private
     */
    this._app = null;

    /**
     * @type {boolean}
     * @private
     */
    this._connected = false;

    this._onSlotChange = this._onSlotChange.bind(this);

    this._inputKeypressDebounceHandler = makeDebouncedFunc((searchString) => {
      this.dispatchEvent(
        new CustomEvent("inputKeyUpDebounced", {
          bubbles: true,
          detail: { searchString },
        })
      );
    });

    // noinspection JSUnresolvedFunction
    this._resizeObserver = new ResizeObserver(() => {
      // When the size changes we need to tell Elm so it can
      //  adjust things like the width of the dropdown.
      this.updateDimensions();
    });
  }

  static get observedAttributes() {
    return [
      "allow-custom-options",
      "disabled",
      "events-only",
      "loading",
      "max-dropdown-items",
      "multi-select",
      "placeholder",
      "selected-option-goes-to-top",
      "selected-value",
      "selected-value-encoding",
    ];
  }

  // noinspection JSUnusedGlobalSymbols
  attributeChangedCallback(name, oldValue, newValue) {
    if (name === "allow-custom-options") {
      if (oldValue !== newValue) {
        this.allowCustomOptions = newValue;
      }
    } else if (name === "disabled") {
      if (oldValue !== newValue) {
        this.disabled = newValue;
      }
    } else if (name === "events-only") {
      if (oldValue !== newValue) {
        this.eventsOnlyMode = newValue;
      }
    } else if (name === "loading") {
      if (oldValue !== newValue) {
        this.loading = newValue;
      }
    } else if (name === "max-dropdown-items") {
      if (oldValue !== newValue) {
        this.maxDropdownItems = newValue;
      }
    } else if (name === "multi-select") {
      if (oldValue !== newValue) {
        this.multiSelect = newValue;
      }
    } else if (name === "placeholder") {
      if (oldValue !== newValue) {
        this.updateDimensions();
        this.placeholder = newValue;
      }
    } else if (name === "selected-option-goes-to-top") {
      if (oldValue !== newValue) {
        this.selectedItemGOesToTop = newValue;
      }
    } else if (name === "selected-value") {
      if (oldValue !== newValue) {
        this.updateDimensions();
        this.selectedValue = newValue;
      }
    } else if (name === "selected-value-encoding") {
      if (oldValue !== newValue) {
        this.updateDimensions();
        this.selectedValueEncoding = newValue;
      }
    }
  }

  // noinspection JSUnusedGlobalSymbols
  connectedCallback() {
    this.parentDivPromise.then((parentDiv) => {
      const wrapperDiv = parentDiv.querySelector("#wrapper");
      this._resizeObserver.observe(wrapperDiv);

      parentDiv.addEventListener("mousedown", (evt) => {
        // This stops the dropdown from flashes when the user clicks
        //  on a optgroup. And it kinda makes sense. we don't want
        //  mousedown events escaping and effecting the DOM.
        evt.stopImmediatePropagation();
        evt.preventDefault();
      });

      this.dispatchEvent(new CustomEvent("muchSelectReady"));
    });

    // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
    this.appPromise.then((app) =>
      app.ports.muchSelectIsReady.subscribe(() => {
        this.dispatchEvent(new CustomEvent("ready", { bubbles: true }));
      })
    );

    // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
    this.appPromise.then((app) =>
      app.ports.errorMessage.subscribe(this.errorHandler.bind(this))
    );

    // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
    this.appPromise.then((app) =>
      app.ports.valueChanged.subscribe(this.valueChangedHandler.bind(this))
    );

    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.optionSelected.subscribe((valueLabelPair) => {
        this.dispatchEvent(
          new CustomEvent("optionSelected", {
            bubbles: true,
            detail: {
              value: valueLabelPair[0],
              label: valueLabelPair[1],
            },
          })
        );
        // The addItem event is for backwards compatibility.
        this.dispatchEvent(
          new CustomEvent("addItem", {
            bubbles: true,
            detail: {
              value: valueLabelPair[0],
              label: valueLabelPair[1],
            },
          })
        );
      })
    );

    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.inputKeyUp.subscribe((searchString) => {
        this.dispatchEvent(
          new CustomEvent("inputKeyUp", {
            bubbles: true,
            detail: { searchString },
          })
        );

        this._inputKeypressDebounceHandler(searchString);
      })
    );

    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.valueCleared.subscribe(() => {
        this.dispatchEvent(
          new CustomEvent("valueCleared", {
            bubbles: true,
          })
        );
        // The cleared event is for backwards compatibility.
        this.dispatchEvent(
          new CustomEvent("cleared", {
            bubbles: true,
          })
        );
      })
    );

    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.customOptionSelected.subscribe(
        this.customOptionSelected.bind(this)
      )
    );

    // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
    this.appPromise.then((app) =>
      app.ports.blurInput.subscribe(() => {
        const inputFilterElement =
          this.shadowRoot.getElementById("input-filter");
        if (inputFilterElement) {
          inputFilterElement.blur();
        }
      })
    );

    // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
    this.appPromise.then((app) =>
      app.ports.focusInput.subscribe(() => {
        window.requestAnimationFrame(() => {
          const inputFilterElement =
            this.shadowRoot.getElementById("input-filter");
          if (inputFilterElement) {
            this.shadowRoot.getElementById("input-filter").focus();
          }
        });
      })
    );

    // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
    this.appPromise.then((app) =>
      app.ports.optionDeselected.subscribe((deselectedValue) => {
        const formattedValue = {
          label: deselectedValue[0][1],
          value: deselectedValue[0][0],
        };
        this.dispatchEvent(
          new CustomEvent("optionDeselected", {
            bubbles: true,
            detail: formattedValue,
          })
        );
        this.dispatchEvent(
          new CustomEvent("deselectItem", {
            bubbles: true,
            detail: formattedValue,
          })
        );
      })
    );

    // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
    this.appPromise.then((app) =>
      app.ports.scrollDropdownToElement.subscribe(() => {
        const dropdown = this.shadowRoot.getElementById("dropdown");
        const highlightedOption = this.shadowRoot.querySelector(
          "#dropdown .option.highlighted"
        );

        // If we found the highlight option AND there are vertical scroll bars
        //  then scroll the dropdown to the highlighted option.
        if (highlightedOption) {
          if (dropdown.scrollHeight > dropdown.clientHeight) {
            const optionHeight = highlightedOption.clientHeight;
            const optionTop = highlightedOption.offsetTop - optionHeight;
            const optionBottom = optionTop + optionHeight + optionHeight;
            const dropdownTop = dropdown.scrollTop;
            const dropdownBottom = dropdownTop + dropdown.clientHeight;

            if (!(optionTop >= dropdownTop && optionBottom <= dropdownBottom)) {
              dropdown.scrollTop = optionTop;
            }
          }
        }
      })
    );

    const slot = this.shadowRoot.querySelector("slot[name=select-input]");
    if (slot) {
      slot.addEventListener("slotchange", this._onSlotChange);
    }

    this._connected = true;
  }

  // noinspection JSUnusedGlobalSymbols
  disconnectedCallback() {
    this._resizeObserver.disconnect();
    this._connected = false;
  }

  _onSlotChange() {
    const selectElement = this.querySelector("select");
    if (selectElement) {
      const optionsJson = buildOptionsFromSelectElement(selectElement);

      this.appPromise.then((app) => {
        // noinspection JSUnresolvedVariable
        app.ports.optionsChangedReceiver.send(optionsJson);
        this.updateDimensions();
      });
    }
  }

  // eslint-disable-next-line class-methods-use-this
  errorHandler(error) {
    // eslint-disable-next-line no-console
    console.error(error);
  }

  /**
   * This method updates the width this widget when it's not selected, so when
   *  it is selected it matches the input element.
   * This needs to be called very time the options or the values change (or
   *  anything else that might change the height or width of the much-select.
   * It waits for 1 frame before doing calculating what the height and width
   *  should be.
   */
  updateDimensions() {
    window.requestAnimationFrame(() => {
      const valueCasingElement = this.shadowRoot.getElementById("value-casing");
      if (valueCasingElement) {
        let width = valueCasingElement.offsetWidth;
        let height = valueCasingElement.offsetHeight;

        // Prevent the width from falling below some threshold.
        if (width < this._minimumWidth) {
          width = this._minimumWidth;
        }

        // Clamp the width between some min and max.
        // TODO this min and max should probably not be hard coded here.
        if (height < 20) {
          height = 20;
        }

        this.appPromise.then((app) => {
          // noinspection JSUnresolvedVariable
          app.ports.valueCasingDimensionsChangedReceiver.send({
            width,
            height,
          });
        });
      }
    });
  }

  buildFlags() {
    const flags = {};
    if (this.selectedValue) {
      flags.value = JSON.stringify(this.parsedSelectedValue);
    } else {
      flags.value = "[]";
    }

    if (this.hasAttribute("placeholder")) {
      flags.placeholder = this.getAttribute("placeholder").trim();
    } else {
      flags.placeholder = "";
    }

    if (this.hasAttribute("size")) {
      flags.size = this.getAttribute("size").trim();
    } else {
      flags.size = "";
    }

    flags.disabled = this.disabled;
    flags.loading = this.loading;
    flags.allowMultiSelect = this.mulitSelect;
    flags.selectedItemStaysInPlace = this.selectedItemStaysInPlace;
    flags.maxDropdownItems = this.maxDropdownItems;
    flags.allowCustomOptions = this.allowCustomOptions;

    const selectElement = this.querySelector("select");
    if (selectElement) {
      flags.optionsJson = JSON.stringify(
        buildOptionsFromSelectElement(selectElement)
      );
    } else {
      flags.optionsJson = JSON.stringify([]);
    }

    return flags;
  }

  /**
   * This method gets called any time the Elm app changes the value of this much select.
   * An "outgoing port" if you will.
   *
   * The selected values always come in an array of tuples, the first part of the tuple
   * being the value, and the second part being the label.
   */
  valueChangedHandler(valuesTuple) {
    this.parsedSelectedValue = valuesTuple.map((valueTuple) => valueTuple[0]);

    this.updateDimensions();
    if (
      this.hasAttribute("multi-select") &&
      this.getAttribute("multi-select") !== "false"
    ) {
      // If we are in multi select mode put the list of values in the event.
      const valuesObj = valuesTuple.map((valueTuple) => ({
        value: valueTuple[0],
        label: valueTuple[1],
      }));
      this.dispatchEvent(
        new CustomEvent("valueChanged", {
          bubbles: true,
          detail: { values: valuesObj },
        })
      );
      // The change event is for backwards compatibility.
      this.dispatchEvent(
        new CustomEvent("change", {
          bubbles: true,
          detail: { values: valuesObj },
        })
      );
    } else if (valuesTuple.length === 0) {
      // If we are in single select mode and the value is empty.
      this.dispatchEvent(
        new CustomEvent("valueChanged", {
          bubbles: true,
          detail: { value: null },
        })
      );
      // The change event is for backwards compatibility.
      this.dispatchEvent(
        new CustomEvent("change", {
          bubbles: true,
          detail: { value: null },
        })
      );
    } else if (valuesTuple.length === 1) {
      // If we are in single select mode put the list of values in the event.
      const valueObj = { value: valuesTuple[0][0], label: valuesTuple[0][1] };
      this.dispatchEvent(
        new CustomEvent("valueChanged", {
          bubbles: true,
          detail: { value: valueObj },
        })
      );
      // The change event is for backwards compatibility.
      this.dispatchEvent(
        new CustomEvent("changed", {
          bubbles: true,
          detail: { value: valueObj },
        })
      );
    } else {
      // If we are in single select mode and there is more than one value then something is wrong.
      throw new TypeError(
        `In single select mode we are expecting a single value, instead we got ${valuesTuple.length}`
      );
    }

    if (!this.eventsOnlyMode) {
      const hiddenValueInput = this.querySelector(
        "[slot='hidden-value-input']"
      );
      if (hiddenValueInput) {
        hiddenValueInput.setAttribute("value", this.parsedSelectedValue);
      }
    }
  }

  customOptionSelected(values) {
    if (
      this.hasAttribute("multi-select") &&
      this.getAttribute("multi-select") !== "false" &&
      values.length > 0
    ) {
      // If we are in multi select mode put the list of values in the event.
      this.dispatchEvent(
        new CustomEvent("customValueSelected", {
          bubbles: true,
          detail: {
            values,
          },
        })
      );
    } else if (values.length === 1) {
      // If we are in single select mode put the list of values in the event.
      this.dispatchEvent(
        new CustomEvent("customValueSelected", {
          bubbles: true,
          detail: {
            value: values[0],
          },
        })
      );
    } else {
      // If we are in single select mode and there is not one value then something is wrong.
      throw new TypeError(
        `In single select mode we are expecting a single custom option, instead we got ${values.length}`
      );
    }
  }

  get appPromise() {
    if (this._appPromise) {
      return this._appPromise;
    }
    this._appPromise = new Promise((resolve, reject) => {
      if (this._app) {
        resolve(this._app);
      } else {
        try {
          const flags = this.buildFlags();

          // User shadow DOM.
          this._parentDiv = this.attachShadow({ mode: "open" });

          const html = this.templateTag.content.cloneNode(true);
          this._parentDiv.append(html);

          const elmDiv = this._parentDiv.querySelector("#mount-node");

          // noinspection JSUnresolvedVariable
          this._app = Elm.Main.init({
            flags,
            node: elmDiv,
          });
          resolve(this._app);
        } catch (error) {
          reject(error);
        }
      }
    });
    return this._appPromise;
  }

  get parentDivPromise() {
    return this.appPromise.then(() => this._parentDiv);
  }

  get selectedValue() {
    return this._selectedValue;
  }

  get parsedSelectedValue() {
    if (this.selectedValueEncoding === "comma") {
      if (this.selectedValue) {
        return this.selectedValue.split(",");
      }
      return [];
    }
    if (this.selectedValueEncoding === "json") {
      return JSON.parse(decodeURIComponent(this.selectedValue));
    }
    throw new Error(
      `Unknown selected value encoding, something is very wrong: ${this.selectedValueEncoding}`
    );
  }

  set selectedValue(value) {
    if (value === null) {
      this._selectedValue = null;
    } else if (value === undefined) {
      this._selectedValue = null;
    } else if (value === "") {
      this._selectedValue = "";
    } else {
      this._selectedValue = value;
    }

    if (!this.eventsOnlyMode) {
      this.setAttribute("selected-value", value);
    }

    if (value) {
      // noinspection JSUnresolvedVariable
      this.appPromise.then((app) =>
        app.ports.valueChangedReceiver.send(this.parsedSelectedValue)
      );
    } else {
      // noinspection JSUnresolvedVariable
      this.appPromise.then((app) => app.ports.valueChangedReceiver.send([]));
    }
  }

  set parsedSelectedValue(values) {
    if (this.selectedValueEncoding === "comma") {
      this.selectedValue = values.join(",");
    } else if (this.selectedValueEncoding === "json") {
      this.selectedValue = encodeURIComponent(JSON.stringify(values));
    }
  }

  get placeholder() {
    return this._placeholder;
  }

  set placeholder(placeholder) {
    if (!this.eventsOnlyMode) {
      this.setAttribute("placeholder", placeholder);
    }

    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.placeholderChangedReceiver.send(placeholder)
    );

    this._placeholder = placeholder;
  }

  get disabled() {
    return this._disabled;
  }

  set disabled(value) {
    if (value === "false") {
      this._disabled = false;
    } else if (value === "") {
      this._disabled = true;
    } else {
      this._disabled = !!value;
    }

    if (!this.eventsOnlyMode) {
      if (this._disabled) {
        this.setAttribute("disabled", "disabled");
      } else {
        this.removeAttribute("disabled");
      }
    }

    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.disableChangedReceiver.send(this._disabled)
    );
  }

  get eventsOnlyMode() {
    return this._eventsOnlyMode;
  }

  set eventsOnlyMode(value) {
    if (value === "false") {
      this._eventsOnlyMode = false;
    } else if (value === "") {
      this._eventsOnlyMode = true;
    } else {
      this._eventsOnlyMode = !!value;
    }
  }

  get maxDropdownItems() {
    return this._maxDropdownItems;
  }

  set maxDropdownItems(value) {
    let newValue;
    if (typeof value === "number") {
      newValue = Math.floor(value);
    } else if (typeof value === "string") {
      newValue = Math.floor(parseInt(value, 10));
    } else {
      throw new TypeError("Max dropdown items must be a number!");
    }
    if (newValue < 3) {
      this._maxDropdownItems = 3;
    } else {
      this._maxDropdownItems = newValue;

      if (!this.eventsOnlyMode) {
        this.setAttribute("max-dropdown-items", newValue);
      }
    }
    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.maxDropdownItemsChangedReceiver.send(this._maxDropdownItems)
    );
  }

  get mulitSelect() {
    return this._isInMulitSelectMode;
  }

  set multiSelect(value) {
    if (value === "false") {
      this._isInMulitSelectMode = false;
    } else if (value === "") {
      this._isInMulitSelectMode = true;
    } else {
      this._isInMulitSelectMode = !!value;
    }

    if (!this.eventsOnlyMode) {
      if (this._isInMulitSelectMode) {
        this.setAttribute("multi-select", value);
      } else {
        this.removeAttribute("multi-select");
      }
    }

    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.multiSelectChangedReceiver.send(this._isInMulitSelectMode)
    );
  }

  get loading() {
    return this._loading;
  }

  set loading(value) {
    if (value === "false") {
      this._loading = false;
    } else if (value === "") {
      this._loading = true;
    } else {
      this._loading = !!value;
    }
    if (!this.eventsOnlyMode) {
      if (this._loading) {
        this.setAttribute("loading", "loading");
      } else {
        this.removeAttribute("loading");
      }
      // noinspection JSUnresolvedVariable
      this.appPromise.then((app) =>
        app.ports.loadingChangedReceiver.send(this._loading)
      );
    }
  }

  get allowCustomOptions() {
    return this._allowCustomOptions;
  }

  set allowCustomOptions(value) {
    if (value === "false") {
      this._allowCustomOptions = false;
    } else if (value === "") {
      this._allowCustomOptions = true;
    } else {
      this._allowCustomOptions = !!value;
    }
    if (!this.eventsOnlyMode) {
      if (this._allowCustomOptions) {
        this.setAttribute("allow-custom-options", "true");
      } else {
        this.removeAttribute("allow-custom-options");
      }
    }

    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.allowCustomOptionsReceiver.send(this._allowCustomOptions)
    );
  }

  get selectedItemStaysInPlace() {
    return this._selectedItemStaysInPlace;
  }

  set selectedItemGOesToTop(value) {
    if (value === "") {
      this.selectedItemStaysInPlace = false;
    } else if (value === null) {
      this.selectedItemStaysInPlace = true;
    } else {
      this.selectedItemStaysInPlace = !value;
    }
  }

  set selectedItemStaysInPlace(value) {
    if (value === "false") {
      this._selectedItemStaysInPlace = false;
    } else {
      this._selectedItemStaysInPlace = !!value;
    }

    if (!this.eventsOnlyMode) {
      if (!this._selectedItemStaysInPlace) {
        this.setAttribute("selected-option-goes-to-top", "");
      } else {
        this.removeAttribute("selected-option-goes-to-top");
      }
    }

    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.selectedItemStaysInPlaceChangedReceiver.send(
        this._selectedItemStaysInPlace
      )
    );
  }

  get selectedValueEncoding() {
    return this._selectedValueEncoding;
  }

  /**
   * Do not allow this value to be anything but:
   *  - json
   *  - comma (default)
   *
   * In addition to actually changing the private property, it also (re)encodes
   *  the current selected value, but ONLY IF the web component is connected,
   *  meaning the connected callback has been called, if that has not been called
   *  we are still initializing.
   * */
  set selectedValueEncoding(value) {
    const currentValue = this.parsedSelectedValue;
    if (value === "json") {
      this._selectedValueEncoding = "json";
    } else if (value === "comma") {
      this._selectedValueEncoding = "comma";
    } else {
      throw new Error(`Invalid selected value encoding: ${value}`);
    }
    if (this._connected) {
      this.parsedSelectedValue = currentValue;
    }
  }

  // eslint-disable-next-line class-methods-use-this
  get styleTag() {
    // noinspection CssInvalidPropertyValue
    return `<style>
      :host {
        /*
        This web components should take up some space on the page.

        TODO: Do we really have to set this by hand? Can't we do something so that
        this gets calculated automatically? If it must be set by hand we should probably
        do something a bit more clever here to not hard code these values so much.
        */

        min-height: 40px;
        min-width: ${this._minimumWidth}px;
      }

      /*
      If we are using a select element in the select-input slot to manage the
      the options do not show it.
      */
      slot[name='select-input'] {
        display: none;
      }

      #wrapper {
        margin-top: auto;
        margin-bottom: auto;
        position: relative;
        min-width: ${this._minimumWidth}px;
      }

      /*
        This value casing (and what's inside of it) is supposed to be the
        "main event".
      */
      #value-casing {
        min-height: 34px;
        cursor: pointer;
        -moz-appearance: textfield;
        -webkit-appearance: textfield;
        background-color: white;
        background-color: -moz-field;
        border: 1px solid darkgray;
        box-shadow: 1px 1px 1px 0 lightgray inset;
        font: -moz-field;
        font: -webkit-small-control;
        padding: 4px 3px 2px 3px;
        display: flex;
        flex-flow: row nowrap;
      }

      #value-casing:hover, #value-casing:focus {
        /*
        TODO: I'm not sure this is the best place or the best way to indicate this
        "input" is focused.
        */
        outline: none;
        border-color: blue;
      }

      #value-casing.multi {
        flex-flow: row wrap;
      }

      #value-casing.disabled {
        border: 1px solid lightgray;
        cursor: pointer;
      }

      #value-casing .placeholder {
        color: silver;
        font-size: 25px;
        white-space: nowrap;
        text-overflow: ellipsis;
        overflow: hidden;
        flex-basis: auto;
      }

      #value-casing #input-filter {
        /*
        TODO, seems like the height and font-size should not be hardcoded.
        */
        height: 36px;
        font-size: 25px;
        /* The min-width let's the input shrink down as far as it needs to.
        The with width lets it grow as much as it can.
        */
        min-width: 10px;
        /* Let's give the input a bit more room than the selected values.
        */
        flex-grow: 3;
        flex-shrink: 0;
        flex-basis: 10%;

        /* We don't want a border because the value-casing will supply the border for
          this input.
        */
        border: none;

        /*
        We do not want an outline on the input (filter) because we want everything
        inside of the #value-casing to (kinda) act like a text input.
        */
        outline: none;
        background: none;
      }

      #input-filter:hover, #input-filter:focus {
        /*
        We do not want an outline on the input (filter) because we want everything
        inside of the #value-casing to (kinda) act like a text input.
        */
        outline: none;
        background: white;
      }

      #input-filter:disabled {
        /*
        Removing the default background color on the disabled input.
        We might want to do some additional styling for "disabled"
        much-selects but that should probably happen on the value-casing
        div.
        */
        background: none;
      }

      #value-casing.single {
        background-image: linear-gradient(to bottom, #fefefe, #f2f2f2);
        background-repeat: repeat-x;
      }

      #value-casing.single.disabled {
        background-image: none;
      }

      #value-casing.single.has-option-selected #selected-value {
        padding: 3px;
        font-size: 20px;
        margin: 2px 2px;
        min-width: 10px;
      }

      #value-casing.multi .value {
        padding: 3px;
        font-size: 20px;
        color: white;
        background-image: linear-gradient(to bottom, #4f6a8f, #88a2bc);
        background-repeat: repeat-x;
        margin: 2px 2px;
        border-radius: 5px;
        border: 3px solid #d99477;
        min-width: 10px;

        flex-grow: 0;
        flex-shrink: 1;
        flex-basis: auto;
      }

      #value-casing.multi .value.highlighted-value {
        background-image: linear-gradient(to bottom, #d99477, #efb680);
        background-repeat: repeat-x;
      }

      #dropdown-indicator {
        position: absolute;
        right: 5px;
        top: 15px;
        cursor: pointer;
        display: block;
        transition: transform 0.25s;
        font-family: "Times New Roman" serif;
      }

      #dropdown-indicator.down {
        transform: rotate(180deg);
      }

      #dropdown-indicator.up {
        transform: rotate(0deg);
      }

      slot[name='loading-indicator'] {
        display: block;
        position: absolute;
        right: 5px;
        top: 10px;
      }

      #clear-button-wrapper {
        display: block;
        position: absolute;
        right: 3px;
        top: 7px;
        cursor: pointer;
      }

      #dropdown {
        background-color: #EEEEEE;
        visibility: hidden;
        position: absolute;
        left: 0;
        font-size: 20px;
        display: inline-block;
        z-index: 10;
        max-height: 300px;
        overflow-y: auto;
        cursor: default;
      }
      #dropdown.showing {
        visibility: visible;
      }
      #dropdown.hiding {
        visibility: hidden;
      }

      #dropdown-footer {
        font-size: 50%;
        text-align: center;
        color: gray;
        background-color: lightgray;
        padding: 5px;
      }

      .optgroup {
        background-color: gray;
        font-size: 0.85rem;
        font-weight: 300;
        padding: 5px;
      }
      .option {
        background-color: silver;
        padding: 5px;
        cursor: pointer;
      }

      .option.selected {
        background-color: darkslategrey;
        color: ghostwhite;
        cursor: pointer;
      }

      .option.highlighted {
        background-color: indigo;
        color: ghostwhite;
      }

      .option.disabled {
        background-color: LightGray;
        color: silver;
        cursor: default;
      }

      .description {
        font-size: 0.85rem;
        padding: 3px;
      }

      .highlight { color: blue }

      /* This loading indicator was copied (almost exactly)
        from this article.
        https://dev.to/devmount/learn-css-animation-by-creating-pure-css-loaders-3lm6

        It was chosen because it was so simple and short.
      */
      .default-loading-indicator {
        height: 18px;
        width: 18px;
        border: 5px solid rgba(150, 150, 150, 0.2);
        border-radius: 50%;
        border-top-color: rgb(150, 150, 150);
        animation: rotate 1s 0s infinite ease-in-out alternate;
      }
      @keyframes rotate {
        0%   { transform: rotate(0);      }
        100% { transform: rotate(360deg); }
      }
    </style>`;
  }

  get templateTag() {
    const templateTag = document.createElement("template");
    templateTag.innerHTML = `
      <div>
        ${this.styleTag}
        <slot name="select-input"></slot>
        <div id="mount-node"></div>
      </div>
    `;
    return templateTag;
  }

  updateOptions(options) {
    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.optionsChangedReceiver.send(cleanUpOptions(options))
    );
    this.updateDimensions();
  }

  addOption(option) {
    this.addOptions([option]);
  }

  addOptions(options) {
    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.addOptionsReceiver.send(cleanUpOptions(options))
    );
    this.updateDimensions();
  }

  removeOption(option) {
    this.removeOptions([option]);
  }

  removeOptions(options) {
    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.removeOptionsReceiver.send(cleanUpOptions(options))
    );
    this.updateDimensions();
  }

  selectOption(option) {
    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.selectOptionReceiver.send(cleanUpOption(option))
    );
  }

  deselectOption(option) {
    // noinspection JSUnresolvedVariable
    this.appPromise.then((app) =>
      app.ports.deselectOptionReceiver.send(cleanUpOption(option))
    );
  }
}

// noinspection JSUnusedGlobalSymbols
export default MuchSelect;
