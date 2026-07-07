#!/usr/bin/env node

const fs = require("fs/promises");
const path = require("path");

const CONTENTS_URL =
  "https://api.github.com/repos/mdn/content/contents/files/en-us/web/javascript?ref=main";
const MDN_DOCS_PREFIX = "https://developer.mozilla.org/en-US/docs/";
const JS_REFERENCE_PATH = "Web/JavaScript/Reference";
const OUTPUT_FILE = path.join(__dirname, "mdn-index.txt");
const CONCURRENCY = 8;

async function fetchJson(url) {
  const response = await fetch(url, {
    headers: {
      "User-Agent": "mdn-index-generator",
      Accept: "application/json",
    },
  });

  if (!response.ok) {
    throw new Error(`Failed to fetch ${url}: ${response.status} ${response.statusText}`);
  }

  return response.json();
}

async function fetchTreeUrlFromContents(contentsUrl) {
  const entries = await fetchJson(contentsUrl);
  const reference = entries.find((entry) => entry.type === "dir" && entry.name === "reference");

  if (!reference || !reference.git_url) {
    throw new Error("Could not find the JavaScript reference tree in the MDN content repository");
  }

  return `${reference.git_url}?recursive=1`;
}

async function mapLimit(items, limit, mapper) {
  const results = [];
  let nextIndex = 0;

  async function worker() {
    while (nextIndex < items.length) {
      const currentIndex = nextIndex;
      nextIndex += 1;
      results[currentIndex] = await mapper(items[currentIndex]);
    }
  }

  await Promise.all(Array.from({ length: Math.min(limit, items.length) }, worker));
  return results;
}

function stripTags(value) {
  return value.replace(/<[^>]*>/g, "");
}

function decodeHtml(value) {
  return value
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&amp;/g, "&")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&#x([0-9a-f]+);/gi, (_, hex) => String.fromCodePoint(parseInt(hex, 16)))
    .replace(/&#(\d+);/g, (_, decimal) => String.fromCodePoint(parseInt(decimal, 10)));
}

function cleanObjectName(title, urlPath) {
  const withoutSuffix = title
    .replace(/\s*-\s*JavaScript\s*\|\s*MDN$/i, "")
    .replace(/\(\) constructor$/i, "");

  if (withoutSuffix && !withoutSuffix.includes(":")) {
    return withoutSuffix;
  }

  return decodeURIComponent(urlPath.split("/").filter(Boolean).at(-1));
}

function cleanMethodName(codeText) {
  // Keep leading bracket so Symbol methods stay as [Symbol.foo] for location building.
  return codeText
    .replace(/^async\s+/, "")
    .replace(/\(\)$/, "")
    .trim();
}

function buildLocation(objectName, methodName, isInstance) {
  const base = isInstance ? `${objectName}.prototype` : objectName;

  // Symbol / bracket notation: Array.prototype[Symbol.iterator]()
  if (methodName.startsWith("[")) {
    return `${base}${methodName}()`;
  }

  return `${base}.${methodName}()`;
}

function parseMethodsFromSidebar(doc, url) {
  const sidebar = doc.sidebarHTML || "";
  const ownEntriesOnly = sidebar.split('<li class="section"><span>Inheritance</span>')[0];
  const objectPath = url.replace(/\/$/, "");
  const objectPathLower = objectPath.toLowerCase();
  const objectName = cleanObjectName(doc.title || "", objectPath);
  const rows = [];

  // Walk each <details> section so we can distinguish "Static methods" from
  // "Instance methods" and build the correct location string.
  const sectionPattern = /<summary><span>(.*?)<\/span>[\s\S]*?<\/details>/g;
  let sectionMatch;

  while ((sectionMatch = sectionPattern.exec(ownEntriesOnly))) {
    const sectionTitle = stripTags(sectionMatch[1]).trim();
    const isInstance = sectionTitle === "Instance methods";
    const isStatic = sectionTitle === "Static methods";

    if (!isInstance && !isStatic) {
      continue;
    }

    const sectionContent = sectionMatch[0];
    const linkPattern = /<a href="([^"]+)">([\s\S]*?)<\/a>/g;
    let linkMatch;

    while ((linkMatch = linkPattern.exec(sectionContent))) {
      const href = decodeHtml(linkMatch[1]).replace(/\/$/, "");
      const html = linkMatch[2];

      if (!href.toLowerCase().startsWith(`${objectPathLower}/`)) {
        continue;
      }

      const codeMatch = html.match(/<code>([\s\S]*?)<\/code>/);
      const codeText = decodeHtml(stripTags(codeMatch ? codeMatch[1] : html)).trim();

      if (!codeText.includes("()")) {
        continue;
      }

      const methodName = cleanMethodName(codeText);

      if (!methodName || methodName === objectName || methodName === "constructor") {
        continue;
      }

      rows.push({
        location: buildLocation(objectName, methodName, isInstance),
        objectName,
        url: `${MDN_DOCS_PREFIX}${href.replace(/^\/en-US\/docs\//, "")}`,
      });
    }
  }

  return rows;
}

function findObjectDocumentPaths(tree) {
  const documentDirs = new Set();
  const dirsWithChildDocuments = new Set();

  for (const entry of tree.tree) {
    if (
      entry.type !== "blob" ||
      !entry.path.startsWith("global_objects/") ||
      !entry.path.endsWith("/index.md")
    ) {
      continue;
    }

    const documentDir = path.posix.dirname(entry.path);
    documentDirs.add(documentDir);

    const parentDir = path.posix.dirname(documentDir);
    if (parentDir !== "." && parentDir !== "global_objects") {
      dirsWithChildDocuments.add(parentDir);
    }
  }

  return [...documentDirs].filter((documentDir) => dirsWithChildDocuments.has(documentDir)).sort();
}

async function fetchObjectMethods(objectPath) {
  const docPath = `${JS_REFERENCE_PATH}/${objectPath}`;
  const payload = await fetchJson(`${MDN_DOCS_PREFIX}${docPath}/index.json`);

  return parseMethodsFromSidebar(payload.doc, payload.url);
}

async function main() {
  console.log("[MDN] Fetching JavaScript reference document tree");
  const treeUrl = await fetchTreeUrlFromContents(CONTENTS_URL);
  const tree = await fetchJson(treeUrl);
  const objectPaths = findObjectDocumentPaths(tree);

  console.log(`[MDN] Reading method links from ${objectPaths.length} object documents`);
  const methodGroups = await mapLimit(objectPaths, CONCURRENCY, fetchObjectMethods);
  const seen = new Set();
  const rows = methodGroups
    .flat()
    .filter((entry) => {
      const key = `${entry.location}|${entry.url}`;

      if (seen.has(key)) {
        return false;
      }

      seen.add(key);
      return true;
    })
    .sort(
      (a, b) => a.objectName.localeCompare(b.objectName) || a.location.localeCompare(b.location),
    )
    .map((entry) => `${entry.location}|${entry.objectName}|${entry.url}`);

  await fs.writeFile(OUTPUT_FILE, `${rows.join("\n")}\n`, "utf8");

  console.log(`[MDN] Wrote ${rows.length} entries to ${path.basename(OUTPUT_FILE)}`);
}

main().catch((error) => {
  console.error(`[MDN] ${error.message}`);
  process.exitCode = 1;
});
