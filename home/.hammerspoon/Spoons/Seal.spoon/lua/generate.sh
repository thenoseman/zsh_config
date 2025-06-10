#!/usr/bin/env bash
#
# Writes a file containing the latest LUA 5.4 docs
#
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir" || exit 1

SOURCE_DATA_URL="https://devdocs.io/docs/lua~5.4/index.json"

echo "[DOM] Prepare LUA API generation"
rm -rf index.txt

echo "[DOM] Downloading LUA API docs as JSON"
curl -qs -L "$SOURCE_DATA_URL" | jq ".entries" | jq -r "sort_by(.name)[] | \"\(.name)|\(.path)|\(.type)\"" >index.txt
