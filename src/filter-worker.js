// eslint-disable-next-line no-undef
importScripts("filter-worker-elm.js");

const app = Elm.FilterWorker.init();

onmessage = function ({ data }) {
  app.ports.receiveOptions.send(data);
};

app.ports.sendCount.subscribe((int) => {
  console.log(int);
});
