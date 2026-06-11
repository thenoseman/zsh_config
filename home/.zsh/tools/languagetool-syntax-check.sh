#!/usr/bin/env bash
#
# Syntax check a text and returns the result
#

# shellcheck disable=SC2086,SC1091
TEXT="${*:-}"

# Via git commit ?
if [[ $TEXT == *"COMMIT_EDITMSG"* ]]; then
	# First line only
	TEXT=$(cat ${TEXT} | head -n 1)
fi

[[ -z "${LANGUAGE_TOOL_URL}" ]] && echo "Please set LANGUAGE_TOOL_URL!" && exit 1
[[ -z "${TEXT}" ]] && exit 0

declare -a DISABLED_RULES=(
	COMMA_PARENTHESIS_WHITESPACE
)

# shellcheck disable=SC2128
OUTPUT=$(curl --max-time 5 -qs --data-urlencode "text=${TEXT}" --data "language=en-US&level=default&disabledRules=$(echo ${DISABLED_RULES} | tr ' ' ',')" \
	"${LANGUAGE_TOOL_URL}/v2/check" |
	jq -r '.matches[] | "\"\(.context.text)\": \(.message)"')

[[ -z "${OUTPUT}" ]] && exit 0

echo -e "\e[38;5;9mLanguagetool syntax check failed!\e[0m"
while read -r line; do
	left=$(echo "${line}" | cut -d ":" -f 1)
	right=$(echo "${line}" | cut -d ":" -f 2)
	echo -e "${left}:\e[38;5;11m${right}\e[0m"
done <<<"${OUTPUT}"

exit 1
