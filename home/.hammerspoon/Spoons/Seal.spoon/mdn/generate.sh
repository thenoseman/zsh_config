#!/usr/bin/env bash
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[MDN] Generating JavaScript index"
node "$dir/generate-mdn-index.js"

echo "[MDN] Generating HTML index"
node "$dir/generate-mdn-html-index.mjs"

echo "[MDN] Combining and sorting indexes"
sort "$dir/mdn-index.txt" "$dir/mdn-html-index.txt" > "$dir/index.txt"

echo "[MDN] Cleaning up intermediate files"
rm "$dir/mdn-index.txt" "$dir/mdn-html-index.txt"

echo "[MDN] Done — $(wc -l < "$dir/index.txt") entries written to index.txt"
