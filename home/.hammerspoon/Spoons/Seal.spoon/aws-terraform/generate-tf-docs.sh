#!/usr/bin/env bash
#
# Writes a file containing all teraform AWS provider resources and data
#
TERRAFORM_VERSION="1.14"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

trim() {
	local var="$1"
	# remove leading whitespace
	var="${var#"${var%%[![:space:]]*}"}"
	# remove trailing whitespace
	var="${var%"${var##*[![:space:]]}"}"
	printf '%s' "$var"
}

cd "$script_dir" || exit 1
rm -rf terraform-docs-index-*.txt web-unified-docs
echo "[AWS-TERRAFORM] Cloning AWS terraform docs"
git clone -q -n --depth 1 --filter=blob:none --sparse "https://github.com/hashicorp/web-unified-docs.git"
cd web-unified-docs || exit 1

BASE="content/terraform/v${TERRAFORM_VERSION}.x/docs/language/functions/"

git sparse-checkout set --no-cone "${BASE}"
git checkout &>/dev/null
cd ..
# ### Numeric functions
# | [ceil](/terraform/language/functions/ceil)         | .hcl,<br/>.tfcomponent.hcl,<br/>.tfdeploy.hcl | Returns the closest whole number that is greater than or equal to the given value, which may be a fraction. |
mapfile -t function_lines < <(grep -E "\| \[[[:alpha:]]|###.*functions" "web-unified-docs/${BASE}/index.mdx")
ftype="unknown"

for line in "${function_lines[@]}"; do
	IFS='|' read -r group name_and_file _ description <<<"$line"

	if [[ ${group} == *"### "* ]]; then
		ftype=$(echo "${group}" | sed -E 's/### //g' | sed -E 's/ fun.*//g')
		continue
	fi

	name_and_file=$(trim "${name_and_file}")
	name=$(echo "${name_and_file}" | sed -E 's/.*\[([^]]+)\].*/\1/')
	description=$(trim "${description}")
	echo "${name}|${ftype}|function|${description}" >>terraform-docs-index-unsorted.txt
done

sort -u terraform-docs-index-unsorted.txt >>terraform-docs-index-functions.txt
rm -rf terraform-docs-index-unsorted.txt web-unified-docs
