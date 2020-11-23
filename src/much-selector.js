// noinspection ES6CheckImport
import { Elm } from "./Main.elm";

// adapted from https://github.com/thread/elm-web-components

class MuchSelector extends HTMLElement {
  // noinspection JSUnusedGlobalSymbols
  connectedCallback() {
    // eslint-disable-next-line no-useless-catch
    try {
      const flags = { name: "Jachin" };

      // User shadow DOM.
      const parentDiv = this.attachShadow({ mode: "open" });

      const elmDiv = document.createElement("div");

      parentDiv.innerHTML = "";
      parentDiv.appendChild(elmDiv);

      // noinspection JSUnresolvedVariable
      Elm.Main.init({
        flags,
        node: elmDiv,
      });
    } catch (error) {
      // TODO Do something interesting here
      throw error;
    }
  }
}

export default MuchSelector;
