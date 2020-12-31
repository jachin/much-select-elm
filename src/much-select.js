// noinspection ES6CheckImport
import { Elm } from "./Main.elm";

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

const stringToOptionObject = (str) => {
  return {
    value: str,
    label: str,
    labelClean: asciiFold(str),
  };
};

const numberToOptionObject = (num) => {
  return {
    value: `${num}`,
    label: `${num}`,
    labelClean: `${num}`,
  };
};

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

// adapted from https://github.com/thread/elm-web-components

class MuchSelect extends HTMLElement {
  constructor() {
    super();

    /**
     * @type {string|null}
     * @private
     */
    this._selected = null;

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
     * @type {null|object}
     * @private
     */
    this._app = null;

    this._onSlotChange = this._onSlotChange.bind(this);
  }

  static get observedAttributes() {
    return [
      "selected",
      "disabled",
      "placeholder",
      "loading",
      "max-dropdown-items",
    ];
  }

  // noinspection JSUnusedGlobalSymbols
  attributeChangedCallback(name, oldValue, newValue) {
    if (name === "selected") {
      if (oldValue !== newValue) {
        this.selected = newValue;
      }
    } else if (name === "placeholder") {
      if (oldValue !== newValue) {
        this.placeholder = newValue;
      }
    } else if (name === "disabled") {
      if (oldValue !== newValue) {
        this.disabled = newValue;
      }
    } else if (name === "max-dropdown-items") {
      if (oldValue !== newValue) {
        this.maxDropdownItems = newValue;
      }
    } else if (name === "loading") {
      if (oldValue !== newValue) {
        this.loading = newValue;
      }
    }
  }

  // noinspection JSUnusedGlobalSymbols
  connectedCallback() {
    // eslint-disable-next-line no-useless-catch
    try {
      const flags = this.buildFlags();

      // User shadow DOM.
      const parentDiv = this.attachShadow({ mode: "open" });

      const elmDiv = document.createElement("div");
      const selectMenuInputSlot = document.createElement("slot");
      selectMenuInputSlot.setAttribute("name", "select-input");

      parentDiv.innerHTML = "";
      parentDiv.appendChild(this.styleTag);
      parentDiv.appendChild(elmDiv);
      parentDiv.appendChild(selectMenuInputSlot);

      // noinspection JSUnresolvedVariable
      this._app = Elm.Main.init({
        flags,
        node: elmDiv,
      });

      // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
      this._app.ports.errorMessage.subscribe(this.errorHandler.bind(this));

      // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
      this._app.ports.valueChanged.subscribe(
        this.valueChangedHandler.bind(this)
      );

      // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
      this._app.ports.blurInput.subscribe(() => {
        const inputFilterElement = this.shadowRoot.getElementById(
          "input-filter"
        );
        if (inputFilterElement) {
          inputFilterElement.blur();
        }
      });

      // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
      this._app.ports.focusInput.subscribe(() => {
        window.requestAnimationFrame(() => {
          const inputFilterElement = this.shadowRoot.getElementById(
            "input-filter"
          );
          if (inputFilterElement) {
            this.shadowRoot.getElementById("input-filter").focus();
          }
        });
      });

      const slot = this.shadowRoot.querySelector("slot[name=select-input]");
      if (slot) {
        slot.addEventListener("slotchange", this._onSlotChange);
      }
    } catch (error) {
      // TODO Do something interesting here
      throw error;
    }
  }

  _onSlotChange() {
    const selectElement = this.querySelector("select");
    if (selectElement) {
      const optionsJson = buildOptionsFromSelectElement(selectElement);

      // noinspection JSUnresolvedVariable
      this._app.ports.optionsChangedReceiver.send(optionsJson);
      this.updateWidth();
    }
  }

  // eslint-disable-next-line class-methods-use-this
  errorHandler(error) {
    // eslint-disable-next-line no-console
    console.error(error);
  }

  /**
   * This method updates the width this widget when it's not selected, so when it is selected it matches the
   *  input element.
   * This needs to be called very time the options change.
   */
  updateWidth() {
    const dropdownElement = this.shadowRoot.getElementById("dropdown");
    if (dropdownElement) {
      let width = dropdownElement.offsetWidth;

      // Clamp the width between some min and max.
      // TODO this min and max should probably not be hard coded here.
      if (width < 300) {
        width = 300;
      } else if (width > 500) {
        width = 500;
      }

      // noinspection JSUnresolvedVariable
      this._app.ports.valueCasingWidthChangedReceiver.send(width);
    }
  }

  buildFlags() {
    const flags = {};
    if (this.selected) {
      flags.value = this.selected;
    } else {
      flags.value = "";
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

    if (this.hasAttribute("multi-select")) {
      flags.allowMultiSelect = this.getAttribute("multi-select") !== "false";
    } else {
      flags.allowMultiSelect = false;
    }

    flags.disabled = this.disabled;
    flags.loading = this.loading;
    flags.maxDropdownItems = this.maxDropdownItems;

    const selectElement = this.querySelector("select");
    if (selectElement) {
      flags.optionsJson = JSON.stringify(
        buildOptionsFromSelectElement(selectElement)
      );
    } else {
      flags.optionsJson = JSON.stringify([]);
    }

    if (this.hasAttribute("selected")) {
      flags.value = this.getAttribute("selected");
    }

    return flags;
  }

  valueChangedHandler(valuesTuple) {
    // TODO perhaps this delimiter should be configurable
    this.selected = valuesTuple.map((valueTuple) => valueTuple[0]).join(",");
    this.updateWidth();
    if (
      this.hasAttribute("multi-select") &&
      this.getAttribute("multi-select") !== "false"
    ) {
      // If we are in mulit select mode put the list of values in the event.
      const valuesObj = valuesTuple.map((valueTuple) => {
        return { value: valueTuple[0], label: valueTuple[1] };
      });
      this.dispatchEvent(
        new CustomEvent("valueChanged", {
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
    } else if (valuesTuple.length === 1) {
      // If we are in single select mode put the list of values in the event.
      const valueObj = { value: valuesTuple[0][0], label: valuesTuple[0][1] };
      this.dispatchEvent(
        new CustomEvent("valueChanged", {
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
  }

  get selected() {
    return this._selected;
  }

  set selected(value) {
    this.setAttribute("selected", value);

    if (value) {
      // TODO perhaps this delimiter should be configurable
      const values = value.split(",");

      // TODO Convert this._app to a function that get a promise that returns _app
      //  when it is ready.
      // noinspection JSUnresolvedVariable
      this._app.ports.valueChangedReceiver.send(values);
    } else {
      // TODO Convert this._app to a function that get a promise that returns _app
      //  when it is ready.
      // noinspection JSUnresolvedVariable
      this._app.ports.valueChangedReceiver.send([]);
    }
  }

  get placeholder() {
    return this._placeholder;
  }

  set placeholder(placeholder) {
    this.setAttribute("placeholder", placeholder);
    // TODO Convert this._app to a function that get a promise that returns _app
    //  when it is ready.
    // noinspection JSUnresolvedVariable
    this._app.ports.placeholderChangedReceiver.send(placeholder);

    this._placeholder = placeholder;
  }

  get disabled() {
    return this._disabled;
  }

  set disabled(value) {
    if (value === "false") {
      this._disabled = false;
    } else {
      this._disabled = !!value;
    }

    if (this._disabled) {
      this.setAttribute("disabled", "disabled");
    } else {
      this.removeAttribute("disabled");
    }
    // noinspection JSUnresolvedVariable
    this._app.ports.disableChangedReceiver.send(this._disabled);
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
      this.setAttribute("max-dropdown-items", newValue);
    }
    // noinspection JSUnresolvedVariable
    this._app.ports.maxDropdownItemsChangedReceiver.send(
      this._maxDropdownItems
    );
  }

  get loading() {
    return this._loading;
  }

  set loading(value) {
    if (value === "false") {
      this._loading = false;
    } else {
      this._loading = !!value;
    }
    if (this._loading) {
      this.setAttribute("loading", "loading");
    } else {
      this.removeAttribute("loading");
    }
    // noinspection JSUnresolvedVariable
    this._app.ports.loadingChangedReceiver.send(this._loading);
  }

  // eslint-disable-next-line class-methods-use-this
  get styleTag() {
    const styleTag = document.createElement("style");
    styleTag.innerHTML = `


      :host {
        /*
        This web components should take up some space on the page.

        TODO: Do we really have to set this by hand? Can't we do something so that
        this gets calculated automatically? If it must be set by hand we should probably
        do something a bit more clever here to not hard code these values so much.
        */

        min-height: 40px;
        min-width: 200px;
        margin: 10px;
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
        max-width: 400px;
        min-width: 200px;
      }

      /*
        This value casing (and what's inside of it) is supposed to be the
        "main event".
      */
      #value-casing {
        min-height: 34px;
        cursor: pointer;
        overflow: hidden;
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
        vertical-align: middle;
        white-space: nowrap;
        text-overflow: ellipsis;
        overflow: hidden;
        flex-basis: 1;
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
        width: 100%;
        /* Let's give the input a bit more room than the selected values.
        */
        flex-grow: 3;
        flex-shrink: 0;
        flex-basis: 10%;
        /* We don't want a border because the value-casing will supply the border for
          this input.
        */
        border: none;
      }

      #value-casing.single {
        background-image: linear-gradient(to bottom, #fefefe, #f2f2f2);
        background-repeat: repeat-x;
      }

      #value-casing.single.disabled {
        background-image: none;
      }

      #value-casing.multi .value {
        padding: 3px;
        font-size: 20px;
        color: white;
        background-image: linear-gradient(to bottom, #4f6a8f, #88a2bc);
        background-repeat: repeat-x;
        margin: 2px 2px;
        border-radius: 5px;
        border: 3px solid;
        border-color: #d99477;
        min-width: 10px;

        flex-grow: 0;
        flex-shrink: 1;
        flex-basis: auto;
      }

      #select-indicator {
        position: absolute;
        right: 3px;
        top: 3px;
        cursor: pointer;
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
        padding: 5px;
        position: absolute;
        top: 45px;
        left: 0px;
        font-size: 20px;
        min-width: 200px;
        display: inline-block;
        z-index: 10;
        max-height: 300px;
        overflow-y: auto;
      }
      #dropdown.showing {
        visibility: visible;
      }
      #dropdown.hiding {
        visibility: hidden;
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
        display: none;
      }

      .description {
        font-size: 0.85rem;
        padding: 3px;
      }
      .highlight { color: blue }`;

    return styleTag;
  }

  updateOptions(options) {
    // noinspection JSUnresolvedVariable
    this._app.ports.optionsChangedReceiver.send(cleanUpOptions(options));
    this.updateWidth();
  }

  addOption(option) {
    this.addOptions([option]);
  }

  addOptions(options) {
    // noinspection JSUnresolvedVariable
    this._app.ports.addOptionsReceiver.send(cleanUpOptions(options));
    this.updateWidth();
  }

  removeOption(option) {
    this.removeOptions([option]);
  }

  removeOptions(options) {
    // noinspection JSUnresolvedVariable
    this._app.ports.removeOptionsReceiver.send(cleanUpOptions(options));
    this.updateWidth();
  }

  selectOption(option) {
    // noinspection JSUnresolvedVariable
    this._app.ports.selectOptionReceiver.send(cleanUpOption(option));
  }

  deselectOption(option) {
    // noinspection JSUnresolvedVariable
    this._app.ports.deselectOptionReceiver.send(cleanUpOption(option));
  }
}

export default MuchSelect;
