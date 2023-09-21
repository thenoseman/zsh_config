#!/usr/bin/env bash
#
# Writes a file containing the latest node.js docs
#
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir" || exit 1

SOURCE_DATA_URL="https://devdocs.io/docs/node/index.json"

echo "> Cleanup"
rm -rf node-js-index.txt

echo "> Downloading node-js docs as JSON"
curl -qs -L "$SOURCE_DATA_URL" | jq ".entries" | jq -r "sort_by(.name)[] | \"\(.name)|\(.path)|\(.type)\"" >node-js-index.txt
