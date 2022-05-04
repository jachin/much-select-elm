const elmStr = (function () {
  $elm;
})().toString();

const code = `
$js
`;

const blob = new Blob([code + elmStr], { type: "application/javascript" });
const worker = new Worker(URL.createObjectURL(blob));

export default worker;
