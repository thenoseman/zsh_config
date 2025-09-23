#!/usr/bin/env bash
#
# Writes a file containing all teraform AWS provider resources and data
#

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir" || exit 1

REMOTE=$(curl -qs -L "https://raw.githubusercontent.com/hashicorp/terraform-provider-aws/refs/heads/main/version/VERSION")
LOCAL=1.0.0
[[ -e "LOCAL_VERSION" ]] && LOCAL=$(cat LOCAL_VERSION)
echo "[AWS-TERRAFORM] Remote version ${REMOTE}, local version ${LOCAL}"

[[ "${LOCAL}" = "${REMOTE}" ]] && echo "[AWS-TERRAFORM] Versions are the same. Nothing to do" && exit 0

rm -rf terraform-provider-aws-index-*.txt terraform-provider-aws
echo "[AWS-TERRAFORM] Cloning AWS terraform provider docs"
git clone -q -n --depth=1 --filter=tree:0 https://github.com/hashicorp/terraform-provider-aws.git
cd terraform-provider-aws || exit 1
git sparse-checkout set --no-cone website/docs
git checkout &>/dev/null
cd ..

process() {
	local file=$1

	local type="resources"
	[[ $file == *"docs/d/"* ]] && type="data-sources"

	local element_name
	element_name=$(echo "$file" | sed -e "s/.*\/docs\/[rd]\///g" | sed -e "s/\.html.*//g")

	local subcategory
	subcategory=$(grep subcategory "${file}" | cut -d ":" -f 2 | sed -e 's/^[^"]"\(.*\)"/\1/g')

	local description
	description=$(grep -A 1 description: "${file}" | tail -n 1 | sed -e "s/^[ ]*//g")

	echo "${element_name}|$subcategory|$type|$description"
}

echo "[AWS-TERRAFORM] Processing documentation files ..."
find terraform-provider-aws/website \( -wholename "*/docs/r/*.markdown" -o -wholename "*/docs/d/*.markdown" \) -print0 | while read -r -d $'\0' file; do
	line=$(process "$file")
	echo "$line" >>terraform-provider-aws-index-unsorted.txt
done

echo "[AWS-TERRAFORM] Writing sorted index file terraform-provider-aws-index.txt"
sort terraform-provider-aws-index-unsorted.txt >terraform-provider-aws-index.txt

echo "${REMOTE}" >LOCAL_VERSION

echo "[AWS-TERRAFORM] aws-terraform cleanup"
rm -rf terraform-provider-aws-index-unsorted.txt terraform-provider-aws
