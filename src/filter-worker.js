// eslint-disable-next-line no-undef
const app = Elm.FilterWorker.init();

onmessage = ({ data }) => {
  const { portName, jsonBlob } = data;

  if (portName === "receiveOptions") {
    app.ports.receiveOptions.send(jsonBlob);
  } else if (portName === "receiveSearchString") {
    app.ports.receiveSearchString.send(jsonBlob);
  }
};

app.ports.sendSearchResults.subscribe((searchResultData) => {
  console.log("searchResultData", searchResultData);
});
