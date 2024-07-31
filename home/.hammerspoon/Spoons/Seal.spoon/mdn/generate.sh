#!/usr/bin/env bash
#
# Writes a file containing the latest MDN searchindex
#
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir" || exit 1

SOURCE_DATA_URL="https://developer.mozilla.org/en-US/search-index.json"

echo "[MDN] Preparing MDN index"
rm -rf mdn-index.txt

echo "[MDN] Downloading MDN search index JSON"
curl -qs -L "$SOURCE_DATA_URL" | jq -r '.[] | "\(.title)|\(.url)|\(.title | split(".")[0])"' >mdn-index.txt
