// noinspection ES6CheckImport
import { Elm } from "./Demo.elm";

const demoDiv = document.getElementById("elm-demo");

Elm.Demo.init({
  flags: {},
  node: demoDiv,
});
