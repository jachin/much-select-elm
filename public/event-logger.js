const makeLogEventHandler = (logElementId) => {
  const logEvent = (event) => {
    const detailStr = JSON.stringify(event.detail);
    const tr = document.createElement("tr");
    const eventElementId = `${event.type}-${event.timeStamp}`;
    tr.setAttribute("id", eventElementId);
    tr.innerHTML = `
    <td>
      <strong><code>${event.type}</code></strong>
    </td>
    <td><code>${detailStr}</code></td>`;
    document.getElementById(logElementId).querySelector("tbody").prepend(tr);

    window.setTimeout(() => {
      const logItemNode = document.getElementById(eventElementId);
      if (logItemNode.parentNode) {
        logItemNode.parentNode.removeChild(logItemNode);
      }
    }, 5000);
  };
  return logEvent;
};

export default makeLogEventHandler;
