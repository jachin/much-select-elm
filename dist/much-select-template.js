const getMuchSelectTemplate = (styleTag) => {
  const templateTag = document.createElement("template");
  templateTag.innerHTML = `
    <div>
      ${styleTag}
      <slot name="select-input"></slot>
      <div id="mount-node"></div>
      <script id="filter-worker" type="javascript/worker">
        const app=Elm.FilterWorker.init();onmessage=({data:e})=>{const{portName:s,jsonBlob:r}=e;"receiveOptions"===s?app.ports.receiveOptions.send(r):"receiveSearchString"===s&&app.ports.receiveSearchString.send(r)},app.ports.sendSearchResults.subscribe((e=>{postMessage({messageName:"searchResults",searchResultData:e})})),app.ports.sendErrorMessage.subscribe((e=>{postMessage({messageName:"errorMessage",errorMessage:e})}));
      </script>
    </div>
  `;
  return templateTag;
};

export default getMuchSelectTemplate;