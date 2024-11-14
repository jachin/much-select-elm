const makeLogEventHandler = (logElementId) => (event) => {
  const detailStr = JSON.stringify(event.detail, null, 2);
  const tr = document.createElement("tr");
  const eventElementId = `${event.type}-${event.timeStamp}`;

  // eslint-disable-next-line no-console
  console.info(event);

  tr.setAttribute("id", eventElementId);
  tr.innerHTML = `
    <td>
      <strong><pre><code>${event.type}</code></pre></strong>
    </td>
    <td><pre><code>${detailStr}</code></pre></td>`;
  document.getElementById(logElementId).querySelector("tbody").prepend(tr);
  document
    .getElementById(logElementId)
    .querySelector(".event-log-empty-row").style.display = "none";

  window.setTimeout(() => {
    const logItemNode = document.getElementById(eventElementId);
    const parentElement = logItemNode.parentNode;
    if (logItemNode.parentNode) {
      logItemNode.parentNode.removeChild(logItemNode);
    }

    const noRecentEventsToShow =
      parentElement.querySelectorAll("tr:not(.event-log-empty-row)").length < 1;
    if (noRecentEventsToShow) {
      document
        .getElementById(logElementId)
        .querySelector(".event-log-empty-row").style.display = "block";
    }
  }, 10000);
};

export default makeLogEventHandler;
