const code = `

$elm

$js

`;

const blob = new Blob([code], { type: "application/javascript" });
const worker = new Worker(URL.createObjectURL(blob));

export default worker;
