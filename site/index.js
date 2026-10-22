import MuchSelect from "./much-select.js";

import makeLogEventHandler from "./event-logger.js";

class ExampleMuchSelect extends MuchSelect {
  get styleTag() {
    return `${super.styleTag}<link rel="stylesheet" href="${
      new URL("./much-select-example.css", import.meta.url).href
    }">`;
  }
}

if (!customElements.get("much-select")) {
  // Putting guard rails around this because browsers do not like
  //  having the same custom element defined more than once.
  window.customElements.define("much-select", ExampleMuchSelect);
}

window.makeLogEventHandler = makeLogEventHandler;
