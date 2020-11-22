import MuchSelector from "./much-selector";

if (!customElements.get("much-selector")) {
  // Putting guard rails around this because browsers do not like
  //  having the same custom element defined more than once.
  window.customElements.define("much-selector", MuchSelector);
}
