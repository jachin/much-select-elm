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
    options.push(option);
  });
  return options;
};

// adapted from https://github.com/thread/elm-web-components

class MuchSelector extends HTMLElement {
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
      const app = Elm.Main.init({
        flags,
        node: elmDiv,
      });

      // noinspection JSUnresolvedVariable,JSIgnoredPromiseFromCall
      app.ports.valueChanged.subscribe(this.valueChangedHandler.bind(this));
    } catch (error) {
      // TODO Do something interesting here
      throw error;
    }
  }

  buildFlags() {
    const flags = {};
    if (this.hasAttribute("value")) {
      flags.value = this.getAttribute("value").trim();
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
    const value = valuesTuple.map((valueTuple) => valueTuple[0]).join();
    this.setAttribute("value", value);
  }
}

export default MuchSelector;
