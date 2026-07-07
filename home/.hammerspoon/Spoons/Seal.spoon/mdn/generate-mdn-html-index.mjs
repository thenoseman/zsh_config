#!/usr/bin/env node

import { writeFile } from "node:fs/promises";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = dirname(fileURLToPath(import.meta.url));

const HTML_REFERENCE_URL =
  "https://api.github.com/repos/mdn/content/contents/files/en-us/web/html/reference?ref=main";
const MDN_ELEMENTS_BASE = "https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements";
const MDN_BASE = "https://developer.mozilla.org";
const OUTPUT_FILE = join(__dirname, "mdn-html-index.txt");
const CONCURRENCY = 8;

async function fetchJson(url) {
  const response = await fetch(url, {
    headers: {
      "User-Agent": "mdn-html-index-generator",
      Accept: "application/json",
    },
  });

  if (!response.ok) {
    throw new Error(`Failed to fetch ${url}: ${response.status} ${response.statusText}`);
  }

  return response.json();
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

async function fetchElementsTreeUrl(referenceUrl) {
  const entries = await fetchJson(referenceUrl);
  const elementsDir = entries.find((e) => e.type === "dir" && e.name === "elements");

  if (!elementsDir?.git_url) {
    throw new Error("Could not find elements directory in HTML reference");
  }

  return `${elementsDir.git_url}?recursive=1`;
}

async function fetchElementEntry(slug) {
  try {
    const payload = await fetchJson(`${MDN_ELEMENTS_BASE}/${slug}/index.json`);
    const tag = payload.doc.short_title;        // e.g. "<object>"
    const rawDescription = payload.doc.title;   // e.g. "<object> HTML external object element"
    const docUrl = `${MDN_BASE}${payload.url}`; // e.g. "https://developer.mozilla.org/en-US/..."
    // Strip the leading "<tag> " prefix that MDN includes in the title.
    const description = rawDescription.startsWith(`${tag} `)
      ? rawDescription.slice(tag.length + 1).replace(/^HTML\s+/, "")
      : rawDescription.replace(/^HTML\s+/, "");
    return `${tag}|${description}|${docUrl}`;
  } catch (error) {
    console.warn(`[MDN HTML] Skipping ${slug}: ${error.message}`);
    return null;
  }
}

async function main() {
  console.log("[MDN HTML] Fetching HTML elements tree");
  const treeUrl = await fetchElementsTreeUrl(HTML_REFERENCE_URL);
  const tree = await fetchJson(treeUrl);

  // Keep only top-level element directories: "{element}/index.md" (depth 1 — no sub-paths).
  // This includes <input> but excludes input/button, input/date, etc.
  const elementSlugs = tree.tree
    .filter(
      (entry) =>
        entry.type === "blob" &&
        entry.path.endsWith("/index.md") &&
        entry.path.split("/").length === 2,
    )
    .map((entry) => entry.path.split("/")[0])
    .sort();

  console.log(`[MDN HTML] Fetching MDN data for ${elementSlugs.length} elements`);
  const rows = await mapLimit(elementSlugs, CONCURRENCY, fetchElementEntry);

  const validRows = rows
    .filter(Boolean)
    .sort((a, b) => {
      // Sort by bare tag name, stripping angle brackets so <a> < <abbr> etc.
      const tagA = a.split("|")[0].replace(/[<>]/g, "");
      const tagB = b.split("|")[0].replace(/[<>]/g, "");
      return tagA.localeCompare(tagB);
    });

  await writeFile(OUTPUT_FILE, `${validRows.join("\n")}\n`, "utf8");
  console.log(`[MDN HTML] Wrote ${validRows.length} entries to mdn-html-index.txt`);
}

main().catch((error) => {
  console.error(`[MDN HTML] ${error.message}`);
  process.exitCode = 1;
});
