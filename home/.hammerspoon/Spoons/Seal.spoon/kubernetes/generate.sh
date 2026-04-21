#!/usr/bin/env bash
#
# Writes a file containing kubernetes 1.33 docs
#
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir" || exit 1

TMP=$(mktemp)
ALL_DOCS_JS="https://devdocs.io$(curl -qsL "https://devdocs.io/" | grep -ohE "/assets/docs.*?\.js")"
curl -sqL -o "${TMP}" "${ALL_DOCS_JS}"
KUBERNETES_VERSION=$(node --eval "const fs = require('fs'); const c = fs.readFileSync('${TMP}'); const app={}; eval(c.toString()); console.log(app.DOCS.find(d => d.slug === 'kubernetes').release);")
rm "${TMP}"

SOURCE_DATA_URL="https://devdocs.io/docs/kubernetes/index.json"

echo "[K8S] Prepare kubernetes API docs ($KUBERNETES_VERSION)"
rm -rf index.txt

curl -qs -L "${SOURCE_DATA_URL}" | jq ".entries" | jq -r "sort_by(.name)[] | \"\(.name)|\(.path)|\(.type)\"" >index.txt
