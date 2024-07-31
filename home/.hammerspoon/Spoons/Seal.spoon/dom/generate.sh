#!/usr/bin/env bash
#
# Writes a file containing the latest DOM docs
#
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir" || exit 1

SOURCE_DATA_URL="https://devdocs.io/docs/dom/index.json"

echo "[DOM] Prepare DOM API generation"
rm -rf dom-index.txt

echo "[DOM] Downloading DOM API docs as JSON"
curl -qs -L "$SOURCE_DATA_URL" | jq ".entries" | jq -r "sort_by(.name)[] | \"\(.name)|\(.path)|\(.type)\"" >dom-index.txt
