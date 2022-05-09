const getMuchSelectTemplate = (styleTag) => {
  const templateTag = document.createElement("template");
  templateTag.innerHTML = `
    <div>
      $${styleTag}
      <slot name="select-input"></slot>
      <div id="mount-node"></div>
      <script id="filter-worker" type="javascript/worker">
        $elm

        $js
      </script>
    </div>
  `;
  return templateTag;
};

export default getMuchSelectTemplate;
