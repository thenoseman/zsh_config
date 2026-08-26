#!/usr/bin/env bash
#
# Writes a file containing the latest mdn docs
#
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir" || exit 1

SOURCE_DATA_URL="https://documents.devdocs.io/dom/index.json"

echo "[MDN] cleanup"
rm -rf index.txt

echo "[MDN] Downloading DOM docs as JSON"
curl -qs -L "$SOURCE_DATA_URL" | jq ".entries" | jq -r "sort_by(.name)[] | \"\(.name)|\(.path)|\(.type)\"" >index.txt
