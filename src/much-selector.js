import { Elm } from './Main.elm';

// adapted from https://github.com/thread/elm-web-components

class MuchSelector extends HTMLElement {
  connectedCallback() {
    try {
      const flags = {name: "Jachin"};

      // User shadow DOM.
      const parentDiv = this.attachShadow({mode: 'open'});

      const elmDiv = document.createElement('div');

      parentDiv.innerHTML = '';
      parentDiv.appendChild(elmDiv);

      const elmElement = Elm.Main.init({
        flags,
        node: elmDiv,
      });

    } catch (error) {
      console.error(
        `Error from elm-web-components registering ${name}`,
        'You can pass an `onSetupError` to handle these.',
        error
      )
    }
  }
}

export default MuchSelector;
