//
// Generate index for kubernetes docs
//
import { parse } from "node-html-parser";
import { openSync, writeFileSync, closeSync } from "node:fs";

const __dirname = dirname(fileURLToPath(import.meta.url));

const KUBERNETES_VERSION = "1-34";
const DOCS_URL = `https://v${KUBERNETES_VERSION}.docs.kubernetes.io/docs/reference/kubernetes-api/_print`;

console.log(`[kubernetes] Loading kubernetes ${KUBERNETES_VERSION} docs`);
const response = await fetch(DOCS_URL);
const html = await response.text();

const root = parse(html);

// Collect resource nodes
const resourceNodes = root.querySelectorAll(".td-content > ul > ul > li > a");
const indexFile = openSync(__dirname + "/index.txt", "w");

console.log(`[kubernetes] Writing kubernetes ${KUBERNETES_VERSION} index`);
resourceNodes.forEach((node) => {
  const summaryNode = root.querySelector(`h1#${node.attributes["href"].replace("#", "")} + .lead`);
  const summaryNodeText = summaryNode ? summaryNode.text : "";
  const indexLine = `${node.text}|${DOCS_URL}/${node.attributes["href"]}|${summaryNodeText}`;
  writeFileSync(indexFile, `${indexLine}\n`);
});

closeSync(indexFile);
