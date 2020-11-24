// noinspection ES6CheckImport
import { Elm } from "./Main.elm";

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
    }
    options.push(option);
  });
  return options;
};

// adapted from https://github.com/thread/elm-web-components

class MuchSelector extends HTMLElement {
  constructor() {
    super();
    this._selected = null;
    this._app = null;
  }

  static get observedAttributes() {
    return ["selected", "disabled", "placeholder", "loading"];
  }

  attributeChangedCallback(name, oldValue, newValue) {
    if (name === "selected") {
      if (oldValue !== newValue) {
        this.selected = newValue;
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

      parentDiv.innerHTML = "";
      parentDiv.appendChild(elmDiv);

      // noinspection JSUnresolvedVariable
      this._app = Elm.Main.init({
        flags,
        node: elmDiv,
      });

      // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
      this._app.ports.valueChanged.subscribe(
        this.valueChangedHandler.bind(this)
      );
    } catch (error) {
      // TODO Do something interesting here
      throw error;
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

  valueChangedHandler(valuesTuple) {
    // TODO perhaps this delimiter should be configurable
    this.selected = valuesTuple.map((valueTuple) => valueTuple[0]).join(",");
  }

  get selected() {
    return this._selected;
  }

  set selected(value) {
    this.setAttribute("selected", value);

    // TODO perhaps this delimiter should be configurable
    const values = value.split(",");

    // TODO Convert this._app to a function that get a promise that returns _app
    //  when it is ready.
    // noinspection JSUnresolvedVariable
    this._app.ports.valueChangedReceiver.send(values);
  }
}

export default MuchSelector;
